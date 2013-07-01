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
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface ShowGameResultController ()

@end

@implementation ShowGameResultController

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
    
    [self showGameResult];    
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
        resultlabel.text = [battingResult getResultLongString];
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
        _inning.text = [NSString stringWithFormat:@"%@%@",[GameResult getInningString:gameResult.inning inning2:gameResult.inning2],gameResult.kanto ? @" (完投)" : @""];
        _sekinin.text = [NSString stringWithFormat:@"%@",
                     [[GameResult getSekininPickerArray] objectAtIndex:gameResult.sekinin]];
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
    
    [self setFrameOriginY:_mailButton originY:battingAdjust+pitchingAdjust+memoAdjust+45];
    _scrollview.contentSize = CGSizeMake(320, battingAdjust+pitchingAdjust+memoAdjust+310);
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (IBAction)backButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)editButton:(id)sender {
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
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showGameResult];
}

@end
