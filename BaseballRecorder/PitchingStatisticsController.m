//
//  PitchingStatisticsController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/13.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingStatisticsController.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "TeamStatistics.h"
#import "PitchingStatistics.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface PitchingStatisticsController ()

@end

@implementation PitchingStatisticsController

@synthesize scrollView;
@synthesize nadView;
@synthesize pitchingStatistics;
@synthesize tweeted;

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
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.contentSize = CGSizeMake(320, 520);
    scrollView.frame = CGRectMake(0, 44, 320, 416);
    [AppDelegate adjustForiPhone5:scrollView];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        // NADViewの作成（表示はこの時点ではしない）
        nadView = [[NADView alloc] initWithFrame:CGRectMake(0, 361, 320, 50)];
        [AppDelegate adjustOriginForiPhone5:nadView];
        
        [nadView setIsOutputLog:NO];
        [nadView setNendID:@"68035dec173da73f2cf1feb0e4e5863162af14c4" spotID:@"81174"];
        [nadView setDelegate:self];
        
        // NADViewの中身（広告）を読み込み
        [nadView load];
    }
}

-(void)nadViewDidFinishLoad:(NADView *)adView {
    // NADViewの中身（広告）の読み込みに成功した場合
    // ScrollViewの高さを調整＆iPhone5対応
    scrollView.frame = CGRectMake(0, 44, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
    
    // NADViewを表示
    [self.view addSubview:nadView];
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
    [self showTarget:_year team:_team];
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeButton:(id)sender {
    [self makeResultPicker];
}

- (IBAction)tweetButton:(id)sender {
    NSString* tweetString = [self makeTweetString];
    
    tweeted = NO;
    
    TWTweetComposeViewController* controller = [[TWTweetComposeViewController alloc] init];
    [controller setInitialText:tweetString];
    
    TWTweetComposeViewControllerCompletionHandler completionHandler
    = ^(TWTweetComposeViewControllerResult result) {
        switch (result) {
            case TWTweetComposeViewControllerResultDone:
                tweeted = YES;
                break;
            case TWTweetComposeViewControllerResultCancelled:
                break;
            default:
                break;
        }
        
        [self dismissViewControllerAnimated:YES completion:^{
            if(tweeted == YES){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                    message:@"つぶやきました" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    };
    
    [controller setCompletionHandler:completionHandler];
    [self presentModalViewController:controller animated:YES];
}

- (NSString*)makeTweetString {
    // 試合結果の文言を作る
    NSMutableString* tweetString = [NSMutableString string];
    
    NSString* targetYearStr = [ConfigManager getCalcTargetYear];
    NSString* targetTeamStr = [ConfigManager getCalcTargetTeam];
    
    NSString* tsusanStr = @"";
    if([targetYearStr isEqualToString:@"すべて"] != YES){
        [tweetString appendString:targetYearStr];
        [tweetString appendString:@"の"];
    } else {
        tsusanStr = @"通算";
    }
    
    if([targetTeamStr isEqualToString:@"すべて"] != YES){
        [tweetString appendString:targetTeamStr];
        [tweetString appendString:@"での"];
    }
    
    [tweetString appendFormat:@"%@投手成績は、",tsusanStr];
    
    [tweetString appendFormat:@"%d試合%d勝%d敗%dセーブ%dホールド 防御率%@ 勝率%@ 投球回%@ "
     ,pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose
     ,pitchingStatistics.save, pitchingStatistics.hold
     ,[Utility getFloatStr2:pitchingStatistics.era]
     ,[Utility getFloatStr:(float)(pitchingStatistics.win) / (float)(pitchingStatistics.win+pitchingStatistics.lose) appendBlank:NO]
     ,[pitchingStatistics getInningString]];
    
    if(pitchingStatistics.hianda != 0){
        [tweetString appendFormat:@"被安打%d ", pitchingStatistics.hianda];
    }
    if(pitchingStatistics.hihomerun != 0){
        [tweetString appendFormat:@"被本塁打%d ", pitchingStatistics.hihomerun];
    }
    if(pitchingStatistics.dassanshin != 0){
        [tweetString appendFormat:@"奪三振%d ", pitchingStatistics.dassanshin];
    }
    if(pitchingStatistics.yoshikyu != 0){
        [tweetString appendFormat:@"与四球%d ", pitchingStatistics.yoshikyu];
    }
    if(pitchingStatistics.yoshikyu2 != 0){
        [tweetString appendFormat:@"与死球%d ", pitchingStatistics.yoshikyu2];
    }
    
    [tweetString appendFormat:@"失点%d 自責点%d 完投%d WHIP%@ 奪三振率%@ "
     ,pitchingStatistics.shitten, pitchingStatistics.jisekiten, pitchingStatistics.kanto
     ,[Utility getFloatStr2:pitchingStatistics.whip]
     ,[Utility getFloatStr2:pitchingStatistics.k9]];
    
    [tweetString appendString:@"です。 #ベボレコ"];
    
    return tweetString;
}

- (IBAction)mailButton:(id)sender {
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
    
    [nadView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [nadView pause];
}

- (void)dealloc {
    [nadView setDelegate:nil];
    nadView = nil;
}

@end
