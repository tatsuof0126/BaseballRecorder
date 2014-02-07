//
//  BattingStatisticsViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingStatisticsViewController.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface BattingStatisticsViewController ()

@end

@implementation BattingStatisticsViewController

@synthesize scrollView;
@synthesize nadView;
@synthesize teamStatistics;
@synthesize battingStatistics;
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
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:scrollView];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        // NADViewの作成（表示はこの時点ではしない）
        nadView = [[NADView alloc] initWithFrame:CGRectMake(0, 381, 320, 50)];
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
    scrollView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
    
    // NADViewを表示
    [self.view addSubview:nadView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
    [self showTarget:_year team:_team];
    
    teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
    
    // 「99勝 99敗 99分  勝率 9.999」という文字列を作る
    NSMutableString* teamresultStr = [NSMutableString string];
    [teamresultStr appendFormat:@"%d勝 %d敗 %d分  ",
        teamStatistics.win, teamStatistics.lose,teamStatistics.draw];
    
    if( [teamresultStr length] <= 12 ){
        [teamresultStr appendString:@"勝率 "];
    }
    
    [teamresultStr appendString:[Utility getFloatStr:
        (float)(teamStatistics.win) / (float)(teamStatistics.win+teamStatistics.lose)
                                 appendBlank:NO]];
    
    if( [teamresultStr length] <= 19 ){
        [teamresultStr insertString:@" " atIndex:0];
    }
    
    _teamresult.text = teamresultStr;
    
    battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
    _battingresult.text = [NSString stringWithFormat:@"%d打席  %d打数  %d安打",
                           battingStatistics.boxs, battingStatistics.atbats, battingStatistics.hits];
    
    _doubles.text = [NSString stringWithFormat:@"%d",battingStatistics.doubles];
    _triples.text = [NSString stringWithFormat:@"%d",battingStatistics.triples];
    _homeruns.text = [NSString stringWithFormat:@"%d",battingStatistics.homeruns];
    _strikeouts.text = [NSString stringWithFormat:@"%d",battingStatistics.strikeouts];
    _walks.text = [NSString stringWithFormat:@"%d",battingStatistics.walks];
    _sacrifices.text = [NSString stringWithFormat:@"%d",battingStatistics.sacrifices];
    _daten.text = [NSString stringWithFormat:@"%d",battingStatistics.daten];
    _tokuten.text = [NSString stringWithFormat:@"%d",battingStatistics.tokuten];
    _steal.text = [NSString stringWithFormat:@"%d",battingStatistics.steal];
    
    _battingstat.text = [NSString stringWithFormat:@"打率 %@ 出塁率 %@ OPS %@",
                         [Utility getFloatStr:battingStatistics.average appendBlank:YES],
                         [Utility getFloatStr:battingStatistics.obp appendBlank:YES],
                         [Utility getFloatStr:battingStatistics.ops appendBlank:YES]];

    _battingstat2.text = [NSString stringWithFormat:@"長打率 %@",
                          [Utility getFloatStr:battingStatistics.slg appendBlank:YES]];
}

- (void)viewDidUnload {
    [self setTeamresult:nil];
    [self setBattingresult:nil];
    [self setBattingstat:nil];
    [self setTeam:nil];
    [self setYear:nil];
    [self setDoubles:nil];
    [self setTriples:nil];
    [self setHomeruns:nil];
    [self setStrikeouts:nil];
    [self setWalks:nil];
    [self setSacrifices:nil];
    [self setDaten:nil];
    [self setTokuten:nil];
    [self setSteal:nil];
    [self setScrollView:nil];
    [self setBattingstat2:nil];
    [super viewDidUnload];
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
                    message:@"つぶやきました" delegate:self cancelButtonTitle:@"OK"
                    otherButtonTitles:nil];
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
    
    [tweetString appendFormat:@"%@打撃成績は、",tsusanStr];
    
    [tweetString appendFormat:@"%d打席%d打数%d安打 打率%@ 出塁率%@ OPS%@ 長打率%@ "
     ,battingStatistics.boxs, battingStatistics.atbats, battingStatistics.hits
     ,[Utility getFloatStr:battingStatistics.average appendBlank:NO]
     ,[Utility getFloatStr:battingStatistics.obp appendBlank:NO]
     ,[Utility getFloatStr:battingStatistics.ops appendBlank:NO]
     ,[Utility getFloatStr:battingStatistics.slg appendBlank:NO]];
    
    if(battingStatistics.doubles != 0){
        [tweetString appendFormat:@"二塁打%d ", battingStatistics.doubles];
    }
    if(battingStatistics.triples != 0){
        [tweetString appendFormat:@"三塁打%d ", battingStatistics.triples];
    }
    if(battingStatistics.homeruns != 0){
        [tweetString appendFormat:@"本塁打%d ", battingStatistics.homeruns];
    }
    if(battingStatistics.strikeouts != 0){
        [tweetString appendFormat:@"三振%d ", battingStatistics.strikeouts];
    }
    if(battingStatistics.walks != 0){
        [tweetString appendFormat:@"四死球%d ", battingStatistics.walks];
    }
    if(battingStatistics.sacrifices != 0){
        [tweetString appendFormat:@"犠打%d ", battingStatistics.sacrifices];
    }
    if(battingStatistics.daten != 0){
        [tweetString appendFormat:@"打点%d ", battingStatistics.daten];
    }
    if(battingStatistics.tokuten != 0){
        [tweetString appendFormat:@"得点%d ", battingStatistics.tokuten];
    }
    if(battingStatistics.steal != 0){
        [tweetString appendFormat:@"盗塁%d ", battingStatistics.steal];
    }
    
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
    NSString* mailTitle = [super getMailTitle:BATTING_RESULT];
    
    // 本文を作る
    NSMutableString* bodyString = [NSMutableString string];

//    NSArray* gameResultListForCalc = [super getGameResultListForCalc];
//    TeamStatistics* teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
//    BattingStatistics* battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
    [bodyString appendString:mailTitle];
    [bodyString appendString:@"\n\n"];
    
    [bodyString appendString:[NSString stringWithFormat:@"試合成績：%@\n\n",[teamStatistics getMailBody]]];
    
    [bodyString appendString:@"打撃成績\n"];
    [bodyString appendString:[battingStatistics getMailBody]];
    
    
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

- (void)adjustGameResultListForRecent5:(NSMutableArray*)gameResultListForCalc {
    // 「最近５試合」の場合は直近の５件に絞る
    if(gameResultListForCalc.count > 5){
        [gameResultListForCalc removeObjectsInRange:
         NSMakeRange(5, gameResultListForCalc.count-5)];
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
