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
#import "TrackingManager.h"

@interface InputConfigViewController ()

@end

@implementation InputConfigViewController

@synthesize adg = adg_;
@synthesize inputNavi;
@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"入力・表示設定画面"];
    
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
    self.adg.view.frame = CGRectMake(0, 430, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    
    // Scrollviewの大きさ定義＆iPhone5対応
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
    // iOS8未満でない（＝iOS8以上）なら
    if([[[UIDevice currentDevice] systemVersion] compare:@"8" options:NSNumericSearch] != NSOrderedAscending){
        [self.view endEditing:YES];
    }
}

- (IBAction)placeEdited:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"入力・表示設定画面―場所設定" value:nil screen:@"入力・表示設定画面"];
    
    UITextField* place = sender;
    [ConfigManager setDefaultPlace:place.text];
}

- (IBAction)myteamEdited:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"入力・表示設定画面―チーム設定" value:nil screen:@"入力・表示設定画面"];
    
    UITextField* myteam = sender;
    [ConfigManager setDefaultMyTeam:myteam.text];
}

- (IBAction)sendtoEdited:(id)sender {
    [self saveDefaultSendto];
}

- (void)saveDefaultSendto {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"入力・表示設定画面―メールアドレス設定" value:nil screen:@"入力・表示設定画面"];
    
    NSString* email = _sendto.text;
    [ConfigManager setDefaultSendTo:email];
}

- (void)checkBoxSelected:(UITapGestureRecognizer*)sender {
    if(sender.view == _calcInning7){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"入力・表示設定画面―７回計算" value:nil screen:@"入力・表示設定画面"];
        
        [_calcInning7 checkboxPush:_calcInning7];
        [ConfigManager setCalcInning7Flg:_calcInning7.selected];
    } else if(sender.view == _showMyteam){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"入力・表示設定画面―自チーム名表示" value:nil screen:@"入力・表示設定画面"];
        
        [_showMyteam checkboxPush:_showMyteam];
        [ConfigManager setShowMyteamFlg:_showMyteam.selected];
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
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

@end
