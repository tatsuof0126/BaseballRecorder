//
//  ShowGameResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import "ShowGameResultController.h"
#import "GameResultListController.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "BattingResult.h"
#import "BattingStatistics.h"
#import "InputViewController.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "NADInterstitial.h"
#import "TrackingManager.h"

#define ALERT_DELETE 1

@interface ShowGameResultController ()

@end

@implementation ShowGameResultController

@synthesize adg = adg_;
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
	// Do any additional setup after loading the view.
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"試合結果参照画面"];
    
    // ScrollViewの高さを定義＆iPhone5対応
    _scrollview.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:_scrollview];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollview];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        NSDictionary *adgparam = @{@"locationid" : @"21680", @"adtype" : @(kADG_AdType_Sp),
                                   @"originx" : @(0), @"originy" : @(630), @"w" : @(320), @"h" : @(50)};
        ADGManagerViewController *adgvc = [[ADGManagerViewController alloc]initWithAdParams :adgparam :self.view];
        self.adg = adgvc;
        adg_.delegate = self;
        [adg_ loadRequest];
    }
    
    [self showGameResult];    
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    // 読み込みに成功したら広告を見える場所に移動
    self.adg.view.frame = CGRectMake(0, 430, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    [AppDelegate adjustOriginForBeforeiOS6:self.adg.view];
    
    // Scrollviewの大きさ定義＆iPhone5対応
    _scrollview.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:_scrollview];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showGameResult {
    // AppDelegateからresultidを取得して読み込み直し
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    int resultid = appDelegate.targetGameResult.resultid;
    
    GameResult* gameResult = [GameResultManager loadGameResult:resultid];
    appDelegate.targetGameResult = gameResult;
    
    // 矢印の表示有無を決定
    [self setArrowImage];
    
    // 試合成績
    _date.text = [gameResult getDateString];
    _place.text = gameResult.place;
    _result.text = [gameResult getGameResultStringWithTeam];
    _tagText.text = gameResult.tagtext;
    
    // 打撃成績
    int baseAdjust = 90;
    BOOL battingResultFlg = NO;
    if( (gameResult.battingResultArray != nil && gameResult.battingResultArray.count >= 1) ||
       gameResult.daten >= 1 || gameResult.tokuten >= 1 || gameResult.steal >= 1){
        battingResultFlg = YES;
    }
    
    NSArray* viewArray = [_scrollview subviews];
    for(int i=0;i<viewArray.count;i++){
        UIView* view = [viewArray objectAtIndex:i];
        if(view.tag == 1){
            [view removeFromSuperview];
        }
    }
    
    for(int i=0;i<gameResult.battingResultArray.count;i++){
        BattingResult* battingResult = [gameResult.battingResultArray objectAtIndex:i];
        
        UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,baseAdjust+65+i*30,90,30)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        titlelabel.tag = 1;
        
        UILabel* resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(125,baseAdjust+65+i*30,200,30)];
        resultlabel.text = [battingResult getResultSemiLongString];
        resultlabel.tag = 1;
        resultlabel.textColor = [battingResult getResultColor];
        
        [_scrollview addSubview:titlelabel];
        [_scrollview addSubview:resultlabel];
    }
    
    _battingResultLabel.hidden = !battingResultFlg;
    _datenLabel.hidden = !battingResultFlg;
    _daten.hidden = !battingResultFlg;
    _tokutenLabel.hidden = !battingResultFlg;
    _tokuten.hidden = !battingResultFlg;
    _stealLabel.hidden = !battingResultFlg;
    _steal.hidden = !battingResultFlg;
    
    if(battingResultFlg == YES){
        _daten.text = [NSString stringWithFormat:@"%d",gameResult.daten];
        _tokuten.text = [NSString stringWithFormat:@"%d",gameResult.tokuten];
        _steal.text = [NSString stringWithFormat:@"%d",gameResult.steal];
    }
 
    // 投手成績
    BOOL pitchingResultFlg = NO;
    if(gameResult.inning != 0 || gameResult.inning2 != 0){
        pitchingResultFlg = YES;
    }
    
    // 投球数
    BOOL tamakazuFlg = NO;
    if(gameResult.tamakazu != TAMAKAZU_NONE){
        tamakazuFlg = YES;
    }
    
    _pitchingResultLabel.hidden = !pitchingResultFlg;
    _inningLabel.hidden = !pitchingResultFlg;
    _inning.hidden = !pitchingResultFlg;
    _sekinin.hidden = !pitchingResultFlg;
    _hiandaLabel.hidden = !pitchingResultFlg;
    _hianda.hidden = !pitchingResultFlg;
    _hihomerunLabel.hidden = !pitchingResultFlg;
    _hihomerun.hidden = !pitchingResultFlg;
    _dassanshinLabel.hidden = !pitchingResultFlg;
    _dassanshin.hidden = !pitchingResultFlg;
    _yoshikyuLabel.hidden = !pitchingResultFlg;
    _yoshikyu.hidden = !pitchingResultFlg;
    _yoshikyu2Label.hidden = !pitchingResultFlg;
    _yoshikyu2.hidden = !pitchingResultFlg;
    _shittenLabel.hidden = !pitchingResultFlg;
    _shitten.hidden = !pitchingResultFlg;
    _jisekitenLabel.hidden = !pitchingResultFlg;
    _jisekiten.hidden = !pitchingResultFlg;

    _tamakazuLabel.hidden = !tamakazuFlg;
    _tamakazu.hidden = !tamakazuFlg;
    
    if(pitchingResultFlg == YES){
        _inning.text = [NSString stringWithFormat:@"%@%@",[gameResult getInningString],gameResult.kanto ? @" (完投)" : @""];
        NSAttributedString *sekininText = [[NSAttributedString alloc]
            initWithString:[gameResult getSekininString]
            attributes:@{NSForegroundColorAttributeName : [gameResult getSekininColor]}];
        _sekinin.attributedText = sekininText;
        // _sekinin.text = [NSString stringWithFormat:@"%@",[gameResult getSekininString]];
        _hianda.text = [NSString stringWithFormat:@"%d",gameResult.hianda];
        _hihomerun.text = [NSString stringWithFormat:@"%d",gameResult.hihomerun];
        _dassanshin.text = [NSString stringWithFormat:@"%d",gameResult.dassanshin];
        _yoshikyu.text = [NSString stringWithFormat:@"%d",gameResult.yoshikyu];
        _yoshikyu2.text = [NSString stringWithFormat:@"%d",gameResult.yoshikyu2];
        _shitten.text = [NSString stringWithFormat:@"%d",gameResult.shitten];
        _jisekiten.text = [NSString stringWithFormat:@"%d",gameResult.jisekiten];
        _tamakazu.text = [NSString stringWithFormat:@"%d",gameResult.tamakazu];
    }
    
    // タグが空なら非表示
    int tagAdjust = 0;
    if ([gameResult.tagtext isEqualToString:@""] == YES){
        _tagText.hidden = YES;
        _tagTextLabel.hidden = YES;
    } else {
        _tagText.hidden = NO;
        _tagTextLabel.hidden = NO;
        tagAdjust = 35;
    }
    
    // タグが長い場合は少し左に寄せる
    if ([gameResult.tagtext lengthOfBytesUsingEncoding:NSShiftJISStringEncoding] >= 23){
        [self setFrameOriginX:_tagText originX:80];
    } else {
        [self setFrameOriginX:_tagText originX:90];
    }
    
    // メモ欄
    BOOL memoFlg = ![@"" isEqualToString:gameResult.memo];
    _memoLabel.hidden = !memoFlg;
    _memo.hidden = !memoFlg;
    
    if(memoFlg == YES){
        _memo.text = gameResult.memo;
        
        // TextViewを整形
        _memo.font = [UIFont systemFontOfSize:14];
        _memo.layer.borderWidth = 1;
        _memo.layer.borderColor = [[UIColor grayColor] CGColor];
        _memo.layer.cornerRadius = 8;
        
        CGRect f = _memo.frame;
        f.size.height = _memo.contentSize.height > 90.0f ? _memo.contentSize.height : 90.0f;
        _memo.frame = f;
    }
    
    // 表示の高さを調整
    int battingAdjust = battingResultFlg ? 70+[Utility convert2int:gameResult.battingResultArray.count]*30 : 0;
    int pitchingAdjust = pitchingResultFlg ? 160 : 0;
    int tamakazuAdjust = tamakazuFlg ? 30 : 0;
    int memoAdjust = memoFlg ? 45+_memo.frame.size.height : 0;
    
    int adjust1 = baseAdjust;
    int adjust2 = baseAdjust+battingAdjust;
    int adjust3 = baseAdjust+tagAdjust+battingAdjust+pitchingAdjust+tamakazuAdjust;
    int adjust4 = baseAdjust+tagAdjust+battingAdjust+pitchingAdjust+tamakazuAdjust+memoAdjust;
    
//    [self setFrameOriginY:_resultLabel originY:adjust1];
//    [self setFrameOriginY:_result originY:adjust1];
//    [self setFrameOriginX:_tweetButton originX:adjust4 == baseAdjust ? 120 : 150];
    [self setFrameOriginY:_tweetButton originY:adjust1+35];
    [self setFrameOriginY:_battingResultLabel originY:adjust1+40];
    
    [self setFrameOriginY:_datenLabel originY:adjust2];
    [self setFrameOriginY:_daten originY:adjust2];
    [self setFrameOriginY:_tokutenLabel originY:adjust2];
    [self setFrameOriginY:_tokuten originY:adjust2];
    [self setFrameOriginY:_stealLabel originY:adjust2];
    [self setFrameOriginY:_steal originY:adjust2];
    
    [self setFrameOriginY:_pitchingResultLabel originY:adjust2+40];
    [self setFrameOriginY:_inningLabel originY:adjust2+70];
    [self setFrameOriginY:_inning originY:adjust2+70];
    [self setFrameOriginY:_sekinin originY:adjust2+70];
    [self setFrameOriginY:_hiandaLabel originY:adjust2+100];
    [self setFrameOriginY:_hianda originY:adjust2+100];
    [self setFrameOriginY:_hihomerunLabel originY:adjust2+100];
    [self setFrameOriginY:_hihomerun originY:adjust2+100];
    [self setFrameOriginY:_dassanshinLabel originY:adjust2+130];
    [self setFrameOriginY:_dassanshin originY:adjust2+130];
    [self setFrameOriginY:_yoshikyuLabel originY:adjust2+130];
    [self setFrameOriginY:_yoshikyu originY:adjust2+130];
    [self setFrameOriginY:_yoshikyu2Label originY:adjust2+130];
    [self setFrameOriginY:_yoshikyu2 originY:adjust2+130];
    [self setFrameOriginY:_shittenLabel originY:adjust2+160];
    [self setFrameOriginY:_shitten originY:adjust2+160];
    [self setFrameOriginY:_jisekitenLabel originY:adjust2+160];
    [self setFrameOriginY:_jisekiten originY:adjust2+160];
    [self setFrameOriginY:_tamakazuLabel originY:adjust2+190];
    [self setFrameOriginY:_tamakazu originY:adjust2+190];
    
    [self setFrameOriginY:_tagTextLabel originY:adjust3+5];
    [self setFrameOriginY:_tagText originY:adjust3+5];
    
    [self setFrameOriginY:_memoLabel originY:adjust3+40];
    [self setFrameOriginY:_memo originY:adjust3+67];
    
    [self setFrameOriginY:_mailButton originY:adjust4 == baseAdjust ? adjust4+75 : adjust4+45];
    [self setFrameOriginY:_deleteButton originY:adjust4 == baseAdjust ? adjust4+130 : adjust4+100];
    _scrollview.contentSize = CGSizeMake(320, adjust4+310);
}

- (void)setFrameOriginX:(UIView*)view originX:(int)originX {
    view.frame = CGRectMake(originX, view.frame.origin.y, view.frame.size.width, view.frame.size.height);
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (void)setArrowImage {
    // 「←」「→」ボタンを出すかの判定
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    BOOL leftMoveFlg = NO;
    BOOL rightMoveFlg = NO;
    
    int nowIndex = -999;
    for (int i=0;i<gameResultList.count;i++){
        GameResult* tmpResult = [gameResultList objectAtIndex:i];
        if(gameResult.resultid == tmpResult.resultid){
            nowIndex = i;
            break;
        }
    }
    
    if(nowIndex+1 < gameResultList.count){
        leftMoveFlg = YES;
    }
    if(nowIndex > 0){
        rightMoveFlg = YES;
    }
    
    _rightBtn.hidden = !rightMoveFlg;
    _leftBtn.hidden = !leftMoveFlg;
}

- (IBAction)backButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―一覧へ" value:nil screen:@"試合結果参照画面"];
    
    [self backToResultList];
}

- (void)backToResultList {
    UIViewController* controller = self;
    while (true){
        //        NSLog(@"Class : %@", NSStringFromClass([controller.presentingViewController class]));
        if([controller.presentingViewController isKindOfClass:[UITabBarController class]]){
            [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        controller = controller.presentingViewController;
    }
}

- (IBAction)editButton:(id)sender {
    // 処理なし
}

- (IBAction)arrowButton:(id)sender {
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    int nowIndex = -999;
    int newIndex = -999;
    
    for (int i=0;i<gameResultList.count;i++){
        GameResult* tmpResult = [gameResultList objectAtIndex:i];
        if(gameResult.resultid == tmpResult.resultid){
            nowIndex = i;
            break;
        }
    }
    
    if(sender == _leftBtn){
        if(nowIndex+1 < gameResultList.count){
            newIndex = nowIndex+1;
        }
    } else if(sender == _rightBtn){
        if(nowIndex > 0){
            newIndex = nowIndex-1;
        }
    }
    
    if (newIndex != -999) {
        appDelegate.targetGameResult = [gameResultList objectAtIndex:newIndex];
        [self showGameResult];
    }
}

- (IBAction)tweetButton:(id)sender {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Twitterにつぶやく"];
    [actionSheet addButtonWithTitle:@"Facebookに投稿"];
    [actionSheet addButtonWithTitle:@"Lineに送る"];
    [actionSheet addButtonWithTitle:@"キャンセル"];
    actionSheet.cancelButtonIndex = 3;
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self postToTwitter];
            break;
        case 1:
            [self postToFacebook];
            break;
        case 2:
            [self postToLine];
            break;
    }
}

- (void)postToTwitter {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―Twitterシェア" value:nil screen:@"試合結果参照画面"];
    
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_TWITTER];
    
    SLComposeViewController* vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultDone:
                posted = YES;
                break;
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if(posted == YES){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                    message:@"つぶやきました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
    
    [vc setInitialText:shareString];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)postToFacebook {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―Facebookシェア" value:nil screen:@"試合結果参照画面"];
    
    NSString* shareString = [self makeShareString:POST_FACEBOOK];
    
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"https://itunes.apple.com/jp/app/id578136103"];
    content.hashtag = [FBSDKHashtag hashtagWithString:@"#ベボレコ"];
    content.quote = shareString;
    [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
}

/*
- (void)postToFacebook {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―Facebookシェア" value:nil screen:@"試合結果参照画面"];
    
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_FACEBOOK];
    
    SLComposeViewController *vc = [SLComposeViewController
                                   composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultDone:
                posted = YES;
                break;
            default:
                break;
        }
        if(posted == YES){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                message:@"投稿しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [vc setInitialText:shareString];
    [vc addURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/id578136103"]];
    
    [self presentViewController:vc animated:YES completion:nil];
}
*/

- (void)postToLine {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―Lineシェア" value:nil screen:@"試合結果参照画面"];
    
    posted = NO;
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://msg/text/test"]] == NO) {
        [Utility showAlert:@"Lineがインストールされていません。"];
    }
    
    NSString* shareString = [self makeShareString:POST_LINE];
    NSString* encodedString = [shareString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *LINEUrlString = [NSString stringWithFormat:@"line://msg/text/%@", encodedString];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINEUrlString]];
}

- (NSString*)makeShareString:(int)type {
    // 試合結果の文言を作る
    NSMutableString* tweetString = [NSMutableString string];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    // 今日の試合だったら日付ではなく「今日の試合」と表示する
    NSString* dateString = @"";
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
    
    if (gameResult.year == todayComps.year && gameResult.month == todayComps.month
        && gameResult.day == todayComps.day) {
        //        dateString = [NSString stringWithFormat:@"今日(%d/%d)",gameResult.month, gameResult.day];
        dateString = @"今日";
    } else if(gameResult.year == todayComps.year){
        // 年だけ一緒の場合
        dateString = [NSString stringWithFormat:@"%d月%d日",gameResult.month, gameResult.day];
    } else {
        // 年も違う場合
        dateString = [NSString stringWithFormat:@"%d年%d月%d日",gameResult.year, gameResult.month, gameResult.day];
    }
    
    NSString* resultString = @"";
    if (gameResult.myscore > gameResult.otherscore) {
        resultString = @"勝ちました。";
    } else if (gameResult.myscore == gameResult.otherscore) {
        resultString = @"引き分けでした。";
    } else {
        resultString = @"負けました。";
    }
    
    [tweetString appendFormat:@"%@の試合は %@ %d-%d %@ で%@",dateString, gameResult.myteam, gameResult.myscore,gameResult.otherscore, gameResult.otherteam,resultString];
    
    BOOL hasBatting = (gameResult.battingResultArray.count > 0);
    BOOL hasPitching = (gameResult.inning != 0 || gameResult.inning2 != 0);
    
    // 打撃成績の文言をつける
    if(hasBatting){
        NSArray* array = [NSArray arrayWithObjects:gameResult, nil];
        BattingStatistics* stats = [BattingStatistics calculateBattingStatistics:array];
        
        [tweetString appendFormat:@"打撃成績は %d打数%d安打",stats.atbats, stats.hits];
        
        if(stats.daten != 0){
            [tweetString appendFormat:@"%d打点",stats.daten];
        }
        if(stats.steal != 0){
            [tweetString appendFormat:@"%d盗塁",stats.steal];
        }
        
        NSMutableString* battingString = [NSMutableString string];
        for (BattingResult* battingResult in gameResult.battingResultArray){
            [battingString appendString:[battingResult getResultShortString]];
            [battingString appendString:@"、"];
        }
        [battingString deleteCharactersInRange:NSMakeRange([battingString length]-1, 1)];
        [tweetString appendFormat:@"(%@)",battingString];
    }
    
    // 投手成績の文言をつける
    if(hasPitching){
        if(hasBatting){
            [tweetString appendString:@"、"];
        }
        
        [tweetString appendFormat:@"投手成績は %@ %d失点 自責点%d %@",
         [gameResult getInningString], gameResult.shitten, gameResult.jisekiten, [gameResult getSekininString]];
        
        if(gameResult.sekinin != 0){
            // 勝ち負けセーブホールドの場合はスペースを一つつける
            [tweetString appendString:@" "];
        }
    }
    
    if(hasBatting || hasPitching){
        [tweetString appendString:@"でした。"];
    }
    
    [tweetString appendString:@" #ベボレコ"];
    
    if(type == POST_LINE){
        [tweetString appendString:@" https://itunes.apple.com/jp/app/id578136103"];
    }
    
    return tweetString;
}

- (IBAction)mailButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―メール送信" value:nil screen:@"試合結果参照画面"];
    
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    NSString* sendto = [ConfigManager getDefaultSendTo];
    NSArray* sendtoArray = [sendto componentsSeparatedByString:@","];
    [mailPicker setToRecipients:sendtoArray];
    [mailPicker setSubject:[gameResult getMailSubject]];
    [mailPicker setMessageBody:[gameResult getMailBody] isHTML:NO];
    
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

- (IBAction)deleteButton:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果の削除"
                                                    message:@"削除してよろしいですか？" delegate:self
                                          cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    alert.tag = ALERT_DELETE;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 削除ボタンでOKを押した場合
    if(buttonIndex == 1){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果参照画面―削除" value:nil screen:@"試合結果参照画面"];
        
        // AppDelegateからresultidを取得して削除
        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        int resultid = appDelegate.targetGameResult.resultid;
        
        [GameResultManager removeGameResult:resultid];
        
        if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
            // インタースティシャル広告を表示
            [[NADInterstitial sharedInstance] showAd];
        }
        
        // 一覧画面に戻る
        [self backToResultList];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    NSString* segueStr = [segue identifier];
    
    if ([segueStr isEqualToString:@"updatesegue"] == YES) {
        InputViewController* controller = [segue destinationViewController];
        controller.inputtype = INPUT_TYPE_UPDATE;
    }
}

- (void)viewDidUnload {
    [self setDate:nil];
    [self setPlace:nil];
    [self setResult:nil];
    [self setScrollview:nil];
    [self setDatenLabel:nil];
    [self setTokutenLabel:nil];
    [self setStealLabel:nil];
    [self setDaten:nil];
    [self setTokuten:nil];
    [self setSteal:nil];
    [self setMailButton:nil];
    [self setPitchingResultLabel:nil];
    [self setInningLabel:nil];
    [self setInning:nil];
    [self setSekinin:nil];
    [self setHiandaLabel:nil];
    [self setHianda:nil];
    [self setHihomerunLabel:nil];
    [self setHihomerun:nil];
    [self setDassanshinLabel:nil];
    [self setDassanshin:nil];
    [self setYoshikyuLabel:nil];
    [self setYoshikyu:nil];
    [self setYoshikyu2Label:nil];
    [self setYoshikyu2:nil];
    [self setShittenLabel:nil];
    [self setShitten:nil];
    [self setJisekitenLabel:nil];
    [self setJisekiten:nil];
    [self setTamakazuLabel:nil];
    [self setTamakazu:nil];
    [self setBattingResultLabel:nil];
    [self setMemoLabel:nil];
    [self setMemo:nil];
    [self setTweetButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(adg_){
        [adg_ resumeRefresh];
    }
        
    [self showGameResult];
}

- (void)viewWillDisappear:(BOOL)animated {
    if(adg_){
        [adg_ pauseRefresh];
    }
}

- (void) dealloc {
    adg_.delegate = nil;
    adg_ = nil;
}

@end
