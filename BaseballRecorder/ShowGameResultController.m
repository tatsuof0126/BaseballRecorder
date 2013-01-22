//
//  ShowGameResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ShowGameResultController.h"
#import "GameResult.h"
#import "BattingResult.h"
#import "GameResultManager.h"
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
        UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,225+i*30,90,30)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        titlelabel.tag = 1;
        
        UILabel* resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(125,225+i*30,200,30)];
        resultlabel.text = [[gameResult.battingResultArray objectAtIndex:i] getResultLongString];
        resultlabel.tag = 1;
        
        [_scrollview addSubview:titlelabel];
        [_scrollview addSubview:resultlabel];
    }
    
    _daten.text = [NSString stringWithFormat:@"%d",gameResult.daten];
    _tokuten.text = [NSString stringWithFormat:@"%d",gameResult.tokuten];
    _steal.text = [NSString stringWithFormat:@"%d",gameResult.steal];
    
    int bottomY = 240+gameResult.battingResultArray.count*30;
    _datenLabel.frame = CGRectMake(_datenLabel.frame.origin.x, bottomY,
                                   _datenLabel.frame.size.width, _datenLabel.frame.size.height);
    _daten.frame = CGRectMake(_daten.frame.origin.x, bottomY,
                              _daten.frame.size.width, _daten.frame.size.height);
    _tokutenLabel.frame = CGRectMake(_tokutenLabel.frame.origin.x, bottomY,
                                    _tokutenLabel.frame.size.width, _tokutenLabel.frame.size.height);
    _tokuten.frame = CGRectMake(_tokuten.frame.origin.x, bottomY,
                               _tokuten.frame.size.width, _tokuten.frame.size.height);
    _stealLabel.frame = CGRectMake(_stealLabel.frame.origin.x, bottomY,
                                   _stealLabel.frame.size.width, _stealLabel.frame.size.height);
    _steal.frame = CGRectMake(_steal.frame.origin.x, bottomY,
                              _steal.frame.size.width, _steal.frame.size.height);
    
    _mailButton.frame = CGRectMake(_mailButton.frame.origin.x, bottomY+45,
                                   _mailButton.frame.size.width, _mailButton.frame.size.height);
    
    CGSize size = CGSizeMake(320, 480+gameResult.battingResultArray.count*30);
    _scrollview.contentSize = size;
}
     
- (IBAction)mailButton:(id)sender {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    [mailPicker setSubject:[gameResult getMailSubject]];
    [mailPicker setMessageBody:[gameResult getMailBody] isHTML:NO];
    
    // メール送信用のモーダルビューを表示
    [self presentViewController:mailPicker animated:YES completion:nil];
}

- (IBAction)backButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)editButton:(id)sender {
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
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showGameResult];
}

@end
