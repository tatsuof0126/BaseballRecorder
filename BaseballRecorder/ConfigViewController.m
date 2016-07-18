//
//  ConfigViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "TrackingManager.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

@synthesize adg = adg_;
@synthesize inputNavi;
@synthesize scrollView;
@synthesize removeadsButton;
@synthesize appstoreLabel;
@synthesize otherappLabel;

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
    [TrackingManager sendScreenTracking:@"設定画面"];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionName.text = [NSString stringWithFormat:@"version%@",version];
    
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
    
    // AppStoreへリンクのタップを受け取るため
    appstoreLabel.userInteractionEnabled = YES;
    [appstoreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    otherappLabel.userInteractionEnabled = YES;
    [otherappLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    
    // iPhone5対応
    [AppDelegate adjustOriginForiPhone5:_apptitle];
    [AppDelegate adjustOriginForiPhone5:_versionName];
    [AppDelegate adjustOriginForiPhone5:appstoreLabel];
    [AppDelegate adjustOriginForiPhone5:otherappLabel];
    
    // すでに広告が非表示ならボタンを消す
    if([ConfigManager isRemoveAdsFlg] == YES){
        inputNavi.rightBarButtonItem = nil;
    }
    
    // ScrollViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    scrollView.contentSize = CGSizeMake(320, 580);
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
    self.adg.view.frame = CGRectMake(0, 381, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    
    // ScrollViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
    
    if([UIScreen mainScreen].bounds.size.height == 568){
        // iPhone5対応
        [self setFrameOriginY:_apptitle originY:340];
        [self setFrameOriginY:_versionName originY:340];
        [self setFrameOriginY:appstoreLabel originY:363];
        [self setFrameOriginY:otherappLabel originY:363];
    }
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (void)removeAdsBar {
    if(self.adg != nil && [ConfigManager isRemoveAdsFlg] == YES){
        // 広告表示していて、広告削除した場合は表示を消す
        self.adg.view.frame = CGRectMake(0, 581, 320, 50);
        [AppDelegate adjustOriginForiPhone5:self.adg.view];
        
        // ScrollViewの大きさ定義＆iPhone5対応
        scrollView.frame = CGRectMake(0, 64, 320, 366);
        [AppDelegate adjustForiPhone5:scrollView];
        
        if([UIScreen mainScreen].bounds.size.height == 568){
            // iPhone5対応
            [self setFrameOriginY:_apptitle originY:390];
            [self setFrameOriginY:_versionName originY:390];
            [self setFrameOriginY:appstoreLabel originY:413];
            [self setFrameOriginY:otherappLabel originY:413];
        }
        
        [adg_ pauseRefresh];
        adg_.delegate = nil;
        adg_ = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setPlace:nil];
    [self setMyteam:nil];
    [self setInputNavi:nil];
    [self setSendto:nil];
    [self setScrollView:nil];
    [self setAppstoreLabel:nil];
    [self setOtherappLabel:nil];
    [self setApptitle:nil];
    [self setRemoveadsButton:nil];
    [self setCalcInning7:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showDoneButton];
    
    // ちょうどいいところにスクロール
    if (textField == _sendto && scrollView.contentOffset.y < 130.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 130.0f) animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self hiddenDoneButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)showDoneButton {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStylePlain target:self action:@selector(doneButton)];
    inputNavi.rightBarButtonItem = btn;
}

- (void)hiddenDoneButton {
    // すでに広告が非表示ならボタンを消す
    if([ConfigManager isRemoveAdsFlg] == YES){
        inputNavi.rightBarButtonItem = nil;
    } else {
        inputNavi.rightBarButtonItem = removeadsButton;
    }
}

- (void)doneButton {
    [_place endEditing:YES];
    [_myteam endEditing:YES];
    [_sendto endEditing:YES];
}

- (IBAction)placeEdited:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―場所設定" value:nil screen:@"設定画面"];
    
    UITextField* place = sender;
    [ConfigManager setDefaultPlace:place.text];
}

- (IBAction)myteamEdited:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―チーム設定" value:nil screen:@"設定画面"];
    
    UITextField* myteam = sender;
    [ConfigManager setDefaultMyTeam:myteam.text];
}

- (IBAction)sendtoEdited:(id)sender {
    [self saveDefaultSendto];
}

- (void)saveDefaultSendto {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―メールアドレス設定" value:nil screen:@"設定画面"];
    
    NSString* email = _sendto.text;
    [ConfigManager setDefaultSendTo:email];
}

- (void)checkBoxSelected:(UITapGestureRecognizer*)sender {
    if(sender.view == _calcInning7){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―７回計算" value:nil screen:@"設定画面"];
        
        [_calcInning7 checkboxPush:_calcInning7];
        [ConfigManager setCalcInning7Flg:_calcInning7.selected];
    } else if(sender.view == _showMyteam){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―自チーム名表示" value:nil screen:@"設定画面"];
        
        [_showMyteam checkboxPush:_showMyteam];
        [ConfigManager setShowMyteamFlg:_showMyteam.selected];
    }
}

- (void)addAddress:(NSString*)email {
    NSMutableString* targetEmail = [NSMutableString string];

    if (_sendto.text != nil){
        [targetEmail appendString:_sendto.text];
    }
    
    if ([targetEmail isEqualToString:@""] == YES ||
        [targetEmail hasSuffix:@","] == YES){
        [targetEmail appendString:email];
    } else {
        [targetEmail appendString:@","];
        [targetEmail appendString:email];
    }
    
    _sendto.text = targetEmail;
}

- (IBAction)addSendtoButton:(id)sender {
    // アドレス帳を呼び出す
    ABPeoplePickerNavigationController *picker = [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
//    [self presentModalViewController:picker animated:YES];
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController*)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, kABPersonEmailProperty);
    if (ABMultiValueGetCount(multi) != 1) {
        // メールアドレスが０件または複数件の場合は詳細画面へ
        [peoplePicker setDisplayedProperties:[NSArray arrayWithObject:[NSNumber numberWithInt:kABPersonEmailProperty]]];
        return YES;
    } else {
        // メールアドレスが１件だけの場合はそれを使う
        NSString* email = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, 0));
        
        [self addAddress:email];
        [self saveDefaultSendto];
//        [self dismissModalViewControllerAnimated:YES];
        [self dismissViewControllerAnimated:YES completion:nil];
        return NO;  
    }  
}

- (BOOL)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker shouldContinueAfterSelectingPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier {
    // 詳細画面で選択したメールアドレスを取り出す
    ABMutableMultiValueRef multi = ABRecordCopyValue(person, property);
    CFIndex index = ABMultiValueGetIndexForIdentifier(multi, identifier);
    NSString* email = (NSString*)CFBridgingRelease(ABMultiValueCopyValueAtIndex(multi, index));
    
    [self addAddress:email];
    [self saveDefaultSendto];
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    return NO;
}

- (void)tapAction:(UITapGestureRecognizer*)sender{
    if(sender.view == appstoreLabel){
//        NSURL* url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/jp/app/cao-ye-qiu-ri-ji-beboreko/id578136103?mt=8&uo=4"];
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―レビューを書く" value:nil screen:@"設定画面"];
        
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=578136103&mt=8&type=Purple+Software"];

        [[UIApplication sharedApplication] openURL:url];
    } else if(sender.view == otherappLabel){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"設定画面―他のアプリを見る" value:nil screen:@"設定画面"];
        
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/TatsuoFujiwara"];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 広告が削除された場合の対応
    [self removeAdsBar];
    
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
