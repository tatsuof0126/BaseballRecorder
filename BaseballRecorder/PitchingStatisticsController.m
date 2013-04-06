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

@interface PitchingStatisticsController ()

@end

@implementation PitchingStatisticsController

@synthesize scrollView;
// @synthesize gameResultList;
// @synthesize gameResultListOfYear;
// @synthesize yearList;
// @synthesize teamList;
// @synthesize targetyear;
// @synthesize targetteam;
// @synthesize targetPicker;
// @synthesize targetToolbar;

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
    
    [AppDelegate adjustForiPhone5:scrollView];
    scrollView.contentSize = CGSizeMake(320, 455);
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
    [self showTarget:_year team:_team];
    
    PitchingStatistics* pitchingStatistics
        = [PitchingStatistics calculatePitchingStatistics:gameResultListForCalc];
    _pitchingresult.text = [NSString stringWithFormat:@"%d試合 %d勝 %d敗 %dセーブ %dホールド",
                       pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose,
                       pitchingStatistics.save, pitchingStatistics.hold];
    
    _inning.text = [pitchingStatistics getInningString];
    _era.text = [PitchingStatistics getFloatStr:pitchingStatistics.era];
    _hianda.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hianda];
    _hihomerun.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hihomerun];
    _dassanshin.text = [NSString stringWithFormat:@"%d",pitchingStatistics.dassanshin];
    _yoshikyu.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu];
    _yoshikyu2.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu2];
    _shitten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.shitten];
    _jisekiten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.jisekiten];
    _kanto.text = [NSString stringWithFormat:@"%d",pitchingStatistics.kanto];
    _whip.text = [PitchingStatistics getFloatStr:pitchingStatistics.whip];
    _k9.text = [PitchingStatistics getFloatStr:pitchingStatistics.k9];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    NSString* mailTitle = [super getMailTitle:PITCHING_RESULT];
    
    // 本文を作る
    NSMutableString* bodyString = [NSMutableString string];
    
    NSArray* gameResultListForCalc = [super getGameResultListForCalc];
    PitchingStatistics* pitchingStatistics
        = [PitchingStatistics calculatePitchingStatistics:gameResultListForCalc];
    
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
    [super viewDidUnload];
}
@end
