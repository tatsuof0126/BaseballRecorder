//
//  ShowGameResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "ShowGameResultController.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "BattingResult.h"
#import "BattingStatistics.h"
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface ShowGameResultController ()

@end

@implementation ShowGameResultController

@synthesize nadView;
@synthesize posted;
// @synthesize tweeted;

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
    
    // ←→ボタンを動作させるための初期設定
    _arrowleft.userInteractionEnabled = YES;
    _arrowright.userInteractionEnabled = YES;
    [_arrowleft addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(arrowButton:)]];
    [_arrowright addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(arrowButton:)]];
    
    // ←→ボタンが押せないときは空の四角にする。（両方押せないときはそもそも出さない）
    // あとで対応
    
    
    
    
    
    
    
    // ScrollViewの高さを定義＆iPhone5対応
    _scrollview.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:_scrollview];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollview];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        // NADViewの作成（表示はこの時点ではしない）
        nadView = [[NADView alloc] initWithFrame:CGRectMake(0, 430, 320, 50)];
        [AppDelegate adjustOriginForiPhone5:nadView];
        [AppDelegate adjustOriginForBeforeiOS6:nadView];
        
        [nadView setIsOutputLog:NO];
        [nadView setNendID:@"68035dec173da73f2cf1feb0e4e5863162af14c4" spotID:@"81174"];
        // [nadView setNendID:@"a6eca9dd074372c898dd1df549301f277c53f2b9" spotID:@"3172"]; // テスト用
        [nadView setDelegate:self];
        
        // NADViewの中身（広告）を読み込み
        [nadView load];
    }
    
    [self showGameResult];    
}

-(void)nadViewDidFinishLoad:(NADView *)adView {
    // NADViewの中身（広告）の読み込みに成功した場合
    // ScrollViewの高さを調整＆iPhone5対応
    _scrollview.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:_scrollview];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollview];
    
    // NADViewを表示
    [self.view addSubview:nadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showGameResult {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;

//    NSLog(@"targetResultid : %d",gameResult.resultid);
    
    _date.text = [gameResult getDateString];
    _place.text = gameResult.place;
    _myteam.text = gameResult.myteam;
    _otherteam.text = gameResult.otherteam;
    _result.text = [gameResult getGameResultString];
    
    NSArray* viewArray = [_scrollview subviews];
    for(int i=0;i<viewArray.count;i++){
        UIView* view = [viewArray objectAtIndex:i];
        if(view.tag == 1){
            [view removeFromSuperview];
        }
    }
    
    for(int i=0;i<gameResult.battingResultArray.count;i++){
        BattingResult* battingResult = [gameResult.battingResultArray objectAtIndex:i];
        
        UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,225+i*30,90,30)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        titlelabel.tag = 1;
        
        UILabel* resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(125,225+i*30,200,30)];
        resultlabel.text = [battingResult getResultSemiLongString];
        resultlabel.tag = 1;
        resultlabel.textColor = [battingResult getResultColor];
        
        [_scrollview addSubview:titlelabel];
        [_scrollview addSubview:resultlabel];
    }
    
    BOOL battingResultFlg = NO;
    if( (gameResult.battingResultArray != nil && gameResult.battingResultArray.count >= 1) ||
       gameResult.daten >= 1 || gameResult.tokuten >= 1 || gameResult.steal >= 1){
        battingResultFlg = YES;
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
 
    BOOL pitchingResultFlg = NO;
    if(gameResult.inning != 0 || gameResult.inning2 != 0){
        pitchingResultFlg = YES;
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
    }
    
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
    
//    int battingAdjust = 230+gameResult.battingResultArray.count*30;
//    if(battingResultFlg == NO){
//        battingAdjust -= 70;
//    }

    int battingAdjust = battingResultFlg ? 230+gameResult.battingResultArray.count*30 : 160;
    int pitchingAdjust = pitchingResultFlg ? 160 : 0;
    int memoAdjust = memoFlg ? 45+_memo.frame.size.height : 0;
    
    [self setFrameOriginY:_datenLabel originY:battingAdjust];
    [self setFrameOriginY:_daten originY:battingAdjust];
    [self setFrameOriginY:_tokutenLabel originY:battingAdjust];
    [self setFrameOriginY:_tokuten originY:battingAdjust];
    [self setFrameOriginY:_stealLabel originY:battingAdjust];
    [self setFrameOriginY:_steal originY:battingAdjust];
    
    [self setFrameOriginY:_pitchingResultLabel originY:battingAdjust+40];
    [self setFrameOriginY:_inningLabel originY:battingAdjust+70];
    [self setFrameOriginY:_inning originY:battingAdjust+70];
    [self setFrameOriginY:_sekinin originY:battingAdjust+70];
    [self setFrameOriginY:_hiandaLabel originY:battingAdjust+100];
    [self setFrameOriginY:_hianda originY:battingAdjust+100];
    [self setFrameOriginY:_hihomerunLabel originY:battingAdjust+100];
    [self setFrameOriginY:_hihomerun originY:battingAdjust+100];
    [self setFrameOriginY:_dassanshinLabel originY:battingAdjust+130];
    [self setFrameOriginY:_dassanshin originY:battingAdjust+130];
    [self setFrameOriginY:_yoshikyuLabel originY:battingAdjust+130];
    [self setFrameOriginY:_yoshikyu originY:battingAdjust+130];
    [self setFrameOriginY:_yoshikyu2Label originY:battingAdjust+130];
    [self setFrameOriginY:_yoshikyu2 originY:battingAdjust+130];
    [self setFrameOriginY:_shittenLabel originY:battingAdjust+160];
    [self setFrameOriginY:_shitten originY:battingAdjust+160];
    [self setFrameOriginY:_jisekitenLabel originY:battingAdjust+160];
    [self setFrameOriginY:_jisekiten originY:battingAdjust+160];
    
    [self setFrameOriginY:_memoLabel originY:battingAdjust+pitchingAdjust+40];
    [self setFrameOriginY:_memo originY:battingAdjust+pitchingAdjust+70];
    
    [self setFrameOriginY:_tweetButton originY:battingAdjust+pitchingAdjust+memoAdjust+50];
    [self setFrameOriginY:_mailButton originY:battingAdjust+pitchingAdjust+memoAdjust+115];
    _scrollview.contentSize = CGSizeMake(320, battingAdjust+pitchingAdjust+memoAdjust+310);
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)editButton:(id)sender {
}

- (void)arrowButton:(UITapGestureRecognizer*)sender{
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
    
    if(sender.view == _arrowright){
        if(nowIndex+1 < gameResultList.count){
            newIndex = nowIndex+1;
        }
    } else if(sender.view == _arrowleft){
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
    [actionSheet addButtonWithTitle:@"キャンセル"];
    actionSheet.cancelButtonIndex = 2;
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
    }
}

- (void)postToTwitter {
    posted = NO;
    
    NSString* shareString = [self makeShareString];
    
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
                    message:@"つぶやきました" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
    
    [vc setInitialText:shareString];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)postToFacebook {
    posted = NO;
    
    NSString* shareString = [self makeShareString];
    
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
                message:@"投稿しました" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [vc setInitialText:shareString];
    [vc addURL:[NSURL URLWithString:@"https://itunes.apple.com/jp/app/id578136103"]];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (NSString*)makeShareString {
    // 試合結果の文言を作る
    NSMutableString* tweetString = [NSMutableString string];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    // 今日の試合だったら日付ではなく「今日の試合」と表示する
    NSString* dateString = @"";
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComps
    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    if (gameResult.year == dateComps.year && gameResult.month == dateComps.month
        && gameResult.day == dateComps.day) {
        //        dateString = [NSString stringWithFormat:@"今日(%d/%d)",gameResult.month, gameResult.day];
        dateString = @"今日";
    } else {
        dateString = [NSString stringWithFormat:@"%d月%d日",gameResult.month, gameResult.day];
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
        
        NSMutableString* battingString = [NSMutableString string];
        for (BattingResult* battingResult in gameResult.battingResultArray){
            [battingString appendString:[battingResult getResultShortString]];
            [battingString appendString:@"、"];
        }
        [battingString deleteCharactersInRange:NSMakeRange([battingString length]-1, 1)];
        
        [tweetString appendFormat:@"打撃成績は %d打数%d安打%d打点%d盗塁（%@）",
         stats.atbats, stats.hits, gameResult.daten, gameResult.steal, battingString];
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
    
    return tweetString;
}

- (IBAction)mailButton:(id)sender {
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

- (void)viewDidUnload {
    [self setDate:nil];
    [self setPlace:nil];
    [self setMyteam:nil];
    [self setOtherteam:nil];
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
    [self setBattingResultLabel:nil];
    [self setMemoLabel:nil];
    [self setMemo:nil];
    [self setArrowleft:nil];
    [self setArrowright:nil];
    [self setTweetButton:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [nadView resume];
    
    [self showGameResult];
}

- (void)viewWillDisappear:(BOOL)animated {
    [nadView pause];
}

- (void) dealloc {
    [nadView setDelegate:nil];
    nadView = nil;
}

@end
