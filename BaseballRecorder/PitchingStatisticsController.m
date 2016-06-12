//
//  PitchingStatisticsController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/13.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingStatisticsController.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "TeamStatistics.h"
#import "PitchingStatistics.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "TrackingManager.h"

@interface PitchingStatisticsController ()

@end

@implementation PitchingStatisticsController

@synthesize scrollView;
@synthesize pitchingStatistics;

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
    [TrackingManager sendScreenTracking:@"投手成績参照画面"];
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.contentSize = CGSizeMake(320, 520);
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:scrollView];
    [AppDelegate adjustOriginForBeforeiOS6:scrollView];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        NSDictionary *adgparam = @{@"locationid" : @"21680", @"adtype" : @(kADG_AdType_Sp),
                                   @"originx" : @(0), @"originy" : @(581), @"w" : @(320), @"h" : @(50)};
        ADGManagerViewController *adgvc
            = [[ADGManagerViewController alloc] initWithAdParams:adgparam adView:self.view];
        self.adg = adgvc;
        adg_.delegate = self;
        [adg_ loadRequest];
    }
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    // 読み込みに成功したら広告を見える場所に移動
    self.adg.view.frame = CGRectMake(0, 381, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    [AppDelegate adjustOriginForBeforeiOS6:self.adg.view];
    
    // ScrollViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
    [AppDelegate adjustOriginForBeforeiOS6:scrollView];
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
//    [self showTarget:_year team:_team];
    [self showTarget:_year team:_team leftBtn:_leftBtn rightBtn:_rightBtn];
    
    // 投手成績
    pitchingStatistics
        = [PitchingStatistics calculatePitchingStatistics:gameResultListForCalc];
    
    _pitchingresult.text = [NSString stringWithFormat:@"%d試合 %d勝 %d敗 %dセーブ %dホールド",
                       pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose,
                       pitchingStatistics.save, pitchingStatistics.hold];
    
    _inning.text = [pitchingStatistics getInningString];
    _era.text = [Utility getFloatStr2:pitchingStatistics.era];
    _shoritsu.text = [Utility getFloatStr:
        (float)(pitchingStatistics.win) / (float)(pitchingStatistics.win+pitchingStatistics.lose)
                      appendBlank:NO];
    _hianda.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hianda];
    _hihomerun.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hihomerun];
    _dassanshin.text = [NSString stringWithFormat:@"%d",pitchingStatistics.dassanshin];
    _yoshikyu.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu];
    _yoshikyu2.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu2];
    _shitten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.shitten];
    _jisekiten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.jisekiten];
    _kanto.text = [NSString stringWithFormat:@"%d",pitchingStatistics.kanto];
    _whip.text = [Utility getFloatStr2:pitchingStatistics.whip];
    _k9.text = [Utility getFloatStr2:pitchingStatistics.k9];
    _kbb.text = [Utility getFloatStr2:pitchingStatistics.kbb];
    _fip.text = [Utility getFloatStr2:pitchingStatistics.fip];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)termChangeButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績参照画面―期間変更" value:nil screen:@"投手成績参照画面"];
    [self makeTermPicker];
}

- (IBAction)teamChangeButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績参照画面―チーム変更" value:nil screen:@"投手成績参照画面"];
    [self makeTeamPicker];
}

- (IBAction)tweetButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績参照画面―シェア" value:nil screen:@"投手成績参照画面"];
    
    // 親クラスのメソッドを呼び出してシェア
    [super shareStatistics:SHARE_TYPE_TEXT];
}

- (IBAction)imageShareButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績参照画面―画像でシェア" value:nil screen:@"投手成績参照画面"];
    
    // 親クラスのメソッドを呼び出してシェア
    [super shareStatistics:SHARE_TYPE_IMAGE];
}

- (NSString*)makeShareString:(int)type shareType:(int)shareType {
    // 試合結果の文言を作る
    NSMutableString* shareString = [NSMutableString string];
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    NSString* targetTeamStr = [ConfigManager getCalcTargetTeam];
    
    NSString* tsusanStr = @"";
    if(targetTerm.type == TERM_TYPE_ALL){
        tsusanStr = @"通算";
    } else {
        [shareString appendString:[targetTerm getTermStringForShare]];
        [shareString appendString:@"の"];
    }
    
    if([targetTeamStr isEqualToString:@"すべて"] != YES){
        [shareString appendString:targetTeamStr];
        [shareString appendString:@"での"];
    }
    [shareString appendFormat:@"%@投手成績は、",tsusanStr];
    
    if(shareType == SHARE_TYPE_TEXT){
        [shareString appendFormat:@"%d試合%d勝%d敗%dセーブ%dホールド 防御率%@ 勝率%@ 投球回%@ "
         ,pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose
         ,pitchingStatistics.save, pitchingStatistics.hold
         ,[Utility getFloatStr2:pitchingStatistics.era]
         ,[Utility getFloatStr:(float)(pitchingStatistics.win) / (float)(pitchingStatistics.win+pitchingStatistics.lose) appendBlank:NO]
         ,[pitchingStatistics getInningString]];
        
        if(pitchingStatistics.hianda != 0){
            [shareString appendFormat:@"被安打%d ", pitchingStatistics.hianda];
        }
        if(pitchingStatistics.hihomerun != 0){
            [shareString appendFormat:@"被本塁打%d ", pitchingStatistics.hihomerun];
        }
        if(pitchingStatistics.dassanshin != 0){
            [shareString appendFormat:@"奪三振%d ", pitchingStatistics.dassanshin];
        }
        if(pitchingStatistics.yoshikyu != 0){
            [shareString appendFormat:@"与四球%d ", pitchingStatistics.yoshikyu];
        }
        if(pitchingStatistics.yoshikyu2 != 0){
            [shareString appendFormat:@"与死球%d ", pitchingStatistics.yoshikyu2];
        }
        [shareString appendFormat:@"失点%d 自責点%d "
            ,pitchingStatistics.shitten, pitchingStatistics.jisekiten];
        if(pitchingStatistics.kanto != 0){
            [shareString appendFormat:@"完投%d ", pitchingStatistics.kanto];
        }
        NSString* whip = [NSString stringWithFormat:@"WHIP%@ ",
                          [Utility getFloatStr2:pitchingStatistics.whip]];
        if(type != POST_TWITTER || [shareString length] + [whip length] <= 131){
            [shareString appendString:whip];
        }
        NSString* k9 = [NSString stringWithFormat:@"奪三振率%@ ",
                        [Utility getFloatStr2:pitchingStatistics.k9]];
        if(type != POST_TWITTER || [shareString length] + [k9 length] <= 131){
            [shareString appendString:k9];
        }
        NSString* kbb = [NSString stringWithFormat:@"K/BB%@ ",
                         [Utility getFloatStr2:pitchingStatistics.kbb]];
        if(type != POST_TWITTER || [shareString length] + [kbb length] <= 131){
            [shareString appendString:kbb];
        }
        NSString* fip = [NSString stringWithFormat:@"FIP%@ ",
                         [Utility getFloatStr2:pitchingStatistics.fip]];
        if(type != POST_TWITTER || [shareString length] + [fip length] <= 131){
            [shareString appendString:fip];
        }
        
        [shareString appendString:@"です。 #ベボレコ"];
    } else if(shareType == SHARE_TYPE_IMAGE){
        [shareString appendFormat:@"%d試合%d勝%d敗%dセーブ%dホールド 防御率%@ 勝率%@ "
         ,pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose
         ,pitchingStatistics.save, pitchingStatistics.hold
         ,[Utility getFloatStr2:pitchingStatistics.era]
         ,[Utility getFloatStr:(float)(pitchingStatistics.win) / (float)(pitchingStatistics.win+pitchingStatistics.lose) appendBlank:NO]];

        [shareString appendString:@"です。 #ベボレコ"];
    }
    
    return shareString;
}

- (NSString*)getShareURLString:(int)type  shareType:(int)shareType {
    if (type == POST_FACEBOOK || type == POST_LINE){
        return @"https://itunes.apple.com/jp/app/id578136103";
//        return @"https://itunes.apple.com/jp/app/cao-ye-qiu-ri-ji-beboreko/id578136103";
    }
    return nil;
}

- (UIImage*)getShareImage:(int)type shareType:(int)shareType {
    if (shareType == SHARE_TYPE_IMAGE){
        return [self getScreenImage];
    }
    return nil;
}

- (UIImage*)getScreenImage {
    // 投稿用にScrollViewの大きさを調整・スクロールを戻す、項目を少し下に下げる、ボタンを消す
    CGRect scrollOldRect = scrollView.frame;
    scrollView.frame = CGRectMake(0, 64, 320, 480);
    [scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
    
    for (UIView* view in scrollView.subviews){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y+45,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    
    _changeBtn.hidden = YES;
    _shareBtn.hidden = YES;
    _imageShareBtn.hidden = YES;
    _mailBtn.hidden = YES;
    
    // 一時的にScrollViewにタイトルバーを配置
    UILabel* tmpbar = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
    tmpbar.backgroundColor = [UIColor darkGrayColor];
    tmpbar.textColor = [UIColor whiteColor];
    tmpbar.textAlignment = NSTextAlignmentCenter;
    tmpbar.font = [UIFont boldSystemFontOfSize:17];
    tmpbar.text = @"投手成績";
    [scrollView addSubview:tmpbar];
    
    // 一時的にラベルを貼る
    UILabel* tmplabel = [[UILabel alloc] initWithFrame:CGRectMake(190,445,120,20)];
    tmplabel.adjustsFontSizeToFitWidth = YES;
    tmplabel.text = @"草野球日記 ベボレコ";
    [scrollView addSubview:tmplabel];
    
    // ScrollViewの内容をContextに書き出し
    CGRect rect = scrollView.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);
    [scrollView.layer renderInContext:context];
    
    // Contextに書き出した内容をUIImageとして受け取る
    UIImage* capturedUIImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 一時的なタイトルバー・ラベルを削除
    [tmpbar removeFromSuperview];
    [tmplabel removeFromSuperview];
    
    // ScrollViewの大きさを元に戻す、ボタンを出す、項目の場所を戻す
    scrollView.frame = scrollOldRect;
    _changeBtn.hidden = NO;
    _shareBtn.hidden = NO;
    _imageShareBtn.hidden = NO;
    _mailBtn.hidden = NO;
    
    for (UIView* view in scrollView.subviews){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y-45,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    
    return capturedUIImage;
}

- (IBAction)mailButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績参照画面―メール送信" value:nil screen:@"投手成績参照画面"];
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    // TOを作る
    NSString* sendto = [ConfigManager getDefaultSendTo];
    NSArray* sendtoArray = [sendto componentsSeparatedByString:@","];
    
    // Subjectを作る
    NSString* mailTitle = [super getMailTitle:PITCHING_RESULT];
    
    // 本文を作る
    NSMutableString* bodyString = [NSMutableString string];
    
//    NSArray* gameResultListForCalc = [super getGameResultListForCalc];
//    PitchingStatistics* pitchingStatistics
//        = [PitchingStatistics calculatePitchingStatistics:gameResultListForCalc];
    
    [bodyString appendString:mailTitle];
    [bodyString appendString:@"\n\n"];
    
//    [bodyString appendString:@"投手成績\n"];
    [bodyString appendString:[pitchingStatistics getMailBody]];
    
    [mailPicker setToRecipients:sendtoArray];
    [mailPicker setSubject:[NSString stringWithFormat:@"【ベボレコ】%@ @ベボレコ",mailTitle]];
    [mailPicker setMessageBody:bodyString isHTML:NO];
    
    // メール送信用のモーダルビューを表示
    [self presentViewController:mailPicker animated:YES completion:nil];
}

// メール送信処理完了時のイベント
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        // キャンセル
        case MFMailComposeResultCancelled:
            break;
        // 保存
        case MFMailComposeResultSaved:
            break;
        // 送信成功
        case MFMailComposeResultSent: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                message:@"送信しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        // 送信失敗
        case MFMailComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                message:@"送信に失敗しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidUnload {
    [self setYear:nil];
    [self setTeam:nil];
    [self setPitchingresult:nil];
    [self setInning:nil];
    [self setEra:nil];
    [self setHianda:nil];
    [self setHihomerun:nil];
    [self setDassanshin:nil];
    [self setYoshikyu:nil];
    [self setYoshikyu2:nil];
    [self setShitten:nil];
    [self setJisekiten:nil];
    [self setKanto:nil];
    [self setWhip:nil];
    [self setK9:nil];
    [self setKbb:nil];
    [self setScrollView:nil];
    [self setShoritsu:nil];
    [super viewDidUnload];
}

- (void)adjustGameResultListForRecent5:(NSMutableArray*)gameResultListForCalc {
    // 「最近５試合」の場合は直近の５件に絞る（ただし投手成績がある試合のみ）
    int num = 0;
    int maxnum = 0;
    
    for (int i=0; i<gameResultListForCalc.count; i++) {
        GameResult* gameResult = [gameResultListForCalc objectAtIndex:i];
        
        if(gameResult.inning != 0 || gameResult.inning2 != 0){
            num++;
        }
        
        if(num >= 5){
            maxnum = i;
            break;
        }
    }
    
    if(maxnum != 0){
        [gameResultListForCalc removeObjectsInRange:
            NSMakeRange(maxnum+1, gameResultListForCalc.count-(maxnum+1))];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(adg_){
        [adg_ resumeRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(adg_){
        [adg_ pauseRefresh];
    }
}

- (void)dealloc {
    adg_.delegate = nil;
    adg_ = nil;
}

- (IBAction)leftButton:(id)sender {
    [self moveLeftTargetTerm];
}

- (IBAction)rightButton:(id)sender {
    [self moveRightTargetTerm];
}

@end
