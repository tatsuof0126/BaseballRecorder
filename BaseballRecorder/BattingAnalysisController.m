//
//  BattingAnalysisController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/02/24.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingAnalysisController.h"
#import "AppDelegate.h"
#import "ConfigManager.h"
#import "TrackingManager.h"

@interface BattingAnalysisController ()

@end

@implementation BattingAnalysisController

@synthesize gadView;
@synthesize scrollView;
@synthesize year;
@synthesize team;
@synthesize analysysView;
@synthesize posted;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"打撃分析画面"];
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.contentSize = CGSizeMake(320, 510);
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:scrollView];
    
    UIImage *backgroundImage  = [UIImage imageNamed:@"ground.png"];
    analysysView.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];
    
    // 広告表示（admob）
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        gadView = [AppDelegate makeGadView:self];
    }
}

- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    // 読み込みに成功したら広告を表示
    gadView.frame = CGRectMake(0, 381, 320, 50);
    [AppDelegate adjustOriginForiPhone5:gadView];
    [self.view addSubview:gadView];
    
    // TableViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
}

- (void)removeAdsBar {
    if(gadView != nil && [ConfigManager isRemoveAdsFlg] == YES){
        // 広告表示していて、広告削除した場合は表示を消す
        [gadView removeFromSuperview];
        gadView.delegate = nil;
        gadView = nil;
        
        // ScrollViewの大きさ定義＆iPhone5対応
        scrollView.frame = CGRectMake(0, 64, 320, 366);
        [AppDelegate adjustForiPhone5:scrollView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)leftButton:(id)sender {
    [self moveLeftTargetTerm];
}

- (IBAction)rightButton:(id)sender {
    [self moveRightTargetTerm];
}

- (IBAction)termChangeButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃分析画面―期間変更" value:nil screen:@"打撃分析画面"];
    [self makeTermPicker];
}

- (IBAction)teamChangeButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃分析画面―チーム変更" value:nil screen:@"打撃分析画面"];
    [self makeTeamPicker];
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
//    [self showTarget:year team:team];
    [self showTarget:year team:team leftBtn:_leftBtn rightBtn:_rightBtn];
    
    analysysView.gameResultListForAnalysis = gameResultListForCalc;
    [analysysView setNeedsDisplay];
}

- (IBAction)saveAnalysis:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃分析画面―保存" value:nil screen:@"打撃分析画面"];
    
    [_indView startAnimating];
    
    [NSThread detachNewThreadSelector:@selector(saveCapturedImage:) toTarget:self withObject:_indView];
}

- (void)saveCapturedImage:(id)obj {
    // UIImageでキャプチャを取得
    UIImage* capturedUIImage = [self getBattingAnalysisImage];
    
    // PNGに変換
    NSData* pngData = UIImagePNGRepresentation(capturedUIImage);
    UIImage *pngImage = [UIImage imageWithData:pngData];
    
    // 取得したPNG画像をカメラロールに保存する
    UIImageWriteToSavedPhotosAlbum(pngImage, self, @selector(completeCapture:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)completeCapture:(UIImage *)screenImage didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [_indView stopAnimating];
    NSString* message = @"カメラロールに保存しました";
    if(error){
        message = @"保存に失敗しました";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:message
        delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)shareAnalysis:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃分析画面―シェア" value:nil screen:@"打撃分析画面"];
    
    [super shareStatistics:SHARE_TYPE_IMAGE];
}

- (NSString*)makeShareString:(int)type shareType:(int)shareType {
    return @"「草野球日記ベボレコ」で打撃分析を行いました。 #ベボレコ";
}

- (NSString*)getShareURLString:(int)type shareType:(int)shareType {
    // 打撃傾向分析の場合はTwitter・Facebookの両方でアプリのURLをシェア
    return @"https://itunes.apple.com/jp/app/id578136103";
}

- (UIImage*)getShareImage:(int)type shareType:(int)shareType {
    return [self getBattingAnalysisImage];
}

- (UIImage*)getBattingAnalysisImage {
    // 一時的にScrollViewの大きさを調整・スクロールし、ボタンを消す
    CGRect oldRect = scrollView.frame;
    scrollView.frame = CGRectMake(0, 64, 320, 480);
//    [AppDelegate adjustForiPhone5:scrollView]; // iPhone5でも縦480にするのでコメントアウト
    [scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
    _changeBtn.hidden = YES;
    _saveBtn.hidden = YES;
    _shareBtn.hidden = YES;
    
    BOOL indBool = _indView.hidden;
    BOOL leftBool = _leftBtn.hidden;
    BOOL rightBool = _rightBtn.hidden;
    _indView.hidden = YES;
    _leftBtn.hidden = YES;
    _rightBtn.hidden = YES;
    
    // 一時的にラベルを貼る
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(190,445,120,20)];
    label.adjustsFontSizeToFitWidth = YES;
    label.text = @"ベボレコ 打撃分析";
    [scrollView addSubview:label];
    
    // ScrollViewの内容をContextに書き出し
    CGRect rect = scrollView.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);
    [scrollView.layer renderInContext:context];
    
    // 描画した内容をUIImageとして受け取る
    UIImage* capturedUIImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // 後処理
    UIGraphicsEndImageContext();
    
    // ScrollViewの大きさを元に戻し、ボタンを出す
    scrollView.frame = oldRect;
    _changeBtn.hidden = NO;
    _saveBtn.hidden = NO;
    _shareBtn.hidden = NO;
    _indView.hidden = indBool;
    _leftBtn.hidden = leftBool;
    _rightBtn.hidden = rightBool;
    
    // ラベルも削除
    [label removeFromSuperview];
    
    return capturedUIImage;
}

- (void)adjustGameResultListForRecent5:(NSMutableArray*)gameResultListForCalc {
    // 「最近５試合」の場合は直近の５件に絞る
    if(gameResultListForCalc.count > 5){
        [gameResultListForCalc removeObjectsInRange:
         NSMakeRange(5, gameResultListForCalc.count-5)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 広告が削除された場合の対応
    [self removeAdsBar];
}

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end
