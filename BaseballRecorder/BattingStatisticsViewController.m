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
#import "TeamStatistics.h"
#import "BattingStatistics.h"
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface BattingStatisticsViewController ()

@end

@implementation BattingStatisticsViewController

@synthesize scrollView;
//@synthesize yearList;
//@synthesize teamList;
//@synthesize targetyear;
//@synthesize targetteam;
 
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
    
    [AppDelegate adjustForiPhone5:scrollView];
    scrollView.contentSize = CGSizeMake(320, 455);
    
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
    [self showTarget:_year team:_team];
    
    TeamStatistics* teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
    
    _teamresult.text = [NSString stringWithFormat:@"%d勝 %d敗 %d分",
                        teamStatistics.win, teamStatistics.lose, teamStatistics.draw];
    
    BattingStatistics* battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
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
                         [BattingStatistics getFloatStr:battingStatistics.average],
                         [BattingStatistics getFloatStr:battingStatistics.obp],
                         [BattingStatistics getFloatStr:battingStatistics.ops]];
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
    [super viewDidUnload];
}

- (IBAction)changeButton:(id)sender {
    [self makeResultPicker];
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

    NSArray* gameResultListForCalc = [super getGameResultListForCalc];
    TeamStatistics* teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
    BattingStatistics* battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
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

/*
- (NSString*)getMailTitle {
    NSString* year = @"";
    NSString* team = @"";
    NSString* tsusan = @"";
    NSString* today = @"";
    
    // 今日の日付を取得する
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComps
    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    today = [NSString stringWithFormat:@"（%d年%d月%d日現在）",dateComps.year,dateComps.month,dateComps.day];
    
    if(super.targetyear != 0){
        year = [super.yearList objectAtIndex:super.targetyear];
        
        // 今日の年を取得する
        NSString* todayYear = [NSString stringWithFormat:@"%d年",dateComps.year];
        if([year isEqualToString:todayYear] == NO){
            // 年指定かつ去年以前の年なら「◯日現在」の文言は追加しない
            today = @"";
        }
    } else {
        tsusan = @"通算";
    }
    
    if(super.targetteam != 0){
        team = [super.teamList objectAtIndex:super.targetteam];
    }
    
    return [NSString stringWithFormat:@"%@%@%@打撃成績%@",year,team,tsusan,today];
}
 */
 
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

+ (NSString*)getFloatStr:(float)floatvalue {
    if(isnan(floatvalue) == YES){
        return @".---";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.03f",floatvalue];
    
    if(floatvalue < 1.0){
        floatStr = [[floatStr substringFromIndex:1] stringByAppendingString:@" "];
    }
    
    return floatStr;
}

@end
