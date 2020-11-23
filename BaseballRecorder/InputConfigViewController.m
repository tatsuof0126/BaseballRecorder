//
//  InputConfigViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/04.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "InputConfigViewController.h"
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface InputConfigViewController ()

@end

@implementation InputConfigViewController

@synthesize gadView;
@synthesize inputNavi;
@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _place.text = [ConfigManager getDefaultPlace];
    _myteam.text = [ConfigManager getDefaultMyTeam];
    _sendto.text = [ConfigManager getDefaultSendTo];
    
    _calcInning7.checkBoxSelected = [ConfigManager isCalcInning7Flg];
    [_calcInning7 setState];
    [_calcInning7 addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                        initWithTarget:self action:@selector(checkBoxSelected:)]];
    
    _showMyteam.checkBoxSelected = [ConfigManager isShowMyteamFlg];
    [_showMyteam setState];
    [_showMyteam addGestureRecognizer:[[UITapGestureRecognizer alloc]
                                       initWithTarget:self action:@selector(checkBoxSelected:)]];
    
    // ScrollViewの大きさ定義
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    scrollView.contentSize = CGSizeMake(320, 680);
    [AppDelegate adjustForiPhone5:scrollView];
    
    
    // 広告表示（admob）
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        gadView = [AppDelegate makeGadView:self];
    }
}

- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    // 読み込みに成功したら広告を表示
    gadView.frame = CGRectMake(0, 430, 320, 50);
    [AppDelegate adjustOriginForiPhone5:gadView];
    [self.view addSubview:gadView];
    
    // TableViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:scrollView];
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)viewDidUnload {
    [self setPlace:nil];
    [self setMyteam:nil];
    [self setInputNavi:nil];
    [self setSendto:nil];
    [self setScrollView:nil];
    [self setCalcInning7:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    // ちょうどいいところにスクロール
    if (textField == _sendto && scrollView.contentOffset.y < 125.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 125.0f) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)placeEdited:(id)sender {
    UITextField* place = sender;
    [ConfigManager setDefaultPlace:place.text];
}

- (IBAction)myteamEdited:(id)sender {
    UITextField* myteam = sender;
    [ConfigManager setDefaultMyTeam:myteam.text];
}

- (IBAction)sendtoEdited:(id)sender {
    [self saveDefaultSendto];
}

- (void)saveDefaultSendto {
    NSString* email = _sendto.text;
    [ConfigManager setDefaultSendTo:email];
}

- (void)checkBoxSelected:(UITapGestureRecognizer*)sender {
    if(sender.view == _calcInning7){
        [_calcInning7 checkboxPush:_calcInning7];
        [ConfigManager setCalcInning7Flg:_calcInning7.selected];
    } else if(sender.view == _showMyteam){
        [_showMyteam checkboxPush:_showMyteam];
        [ConfigManager setShowMyteamFlg:_showMyteam.selected];
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end
