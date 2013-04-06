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

@interface ConfigViewController ()

@end

@implementation ConfigViewController

@synthesize inputNavi;
@synthesize scrollView;
@synthesize removeadsButton;
@synthesize appstoreLabel;

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
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    _versionName.text = [NSString stringWithFormat:@"version%@",version];
    
    _place.text = [ConfigManager getDefaultPlace];
    _myteam.text = [ConfigManager getDefaultMyTeam];
    _sendto.text = [ConfigManager getDefaultSendTo];
    
    // AppStoreへリンクのタップを受け取るため
    appstoreLabel.userInteractionEnabled = YES;
    [appstoreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    
    // iPhone5対応
    [AppDelegate adjustOriginForiPhone5:_apptitle];
    [AppDelegate adjustOriginForiPhone5:_appsubtitle];
    [AppDelegate adjustOriginForiPhone5:_versionName];
    [AppDelegate adjustOriginForiPhone5:appstoreLabel];
    
    // すでに広告が非表示ならボタンを消す
    if([ConfigManager isRemoveAdsFlg] == YES){
        inputNavi.rightBarButtonItem = nil;
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
    [self setApptitle:nil];
    [self setAppsubtitle:nil];
    [self setRemoveadsButton:nil];
    [super viewDidUnload];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showDoneButton];
    
    // ScrollViewを大きくしてスクロールできるようにする
    CGSize size;
    // iPhone5対応
    if([UIScreen mainScreen].bounds.size.height == 568){
        size = CGSizeMake(320, 748);
    } else {
        size = CGSizeMake(320, 660);
    }
    scrollView.contentSize = size;
    
    // ちょうどいいところにスクロール
    if (textField == _sendto && scrollView.contentOffset.y < 140.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 140.0f) animated:YES];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self hiddenDoneButton];
    return YES;
}

- (void)showDoneButton {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStylePlain target:self action:@selector(doneButton)];
    inputNavi.rightBarButtonItem = btn;
}

- (void)hiddenDoneButton {
    inputNavi.rightBarButtonItem = nil;
}

- (void)doneButton {
    // ScrollViewのサイズを戻す
    CGSize size = CGSizeMake(320, 455);
    scrollView.contentSize = size;

    [_place endEditing:YES];
    [_myteam endEditing:YES];
    [_sendto endEditing:YES];
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
    [self presentModalViewController:picker animated:YES];
}

- (IBAction)removeadsButton:(id)sender {
}

- (void) peoplePickerNavigationControllerDidCancel:(ABPeoplePickerNavigationController *)peoplePicker{
    [self dismissModalViewControllerAnimated:YES];
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
        [self dismissModalViewControllerAnimated:YES];
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
    [self dismissModalViewControllerAnimated:YES];
    return NO;
}

- (void)tapAction:(UITapGestureRecognizer*)sender{
    if(sender.view == appstoreLabel){
//        NSURL* url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/jp/app/cao-ye-qiu-ri-ji-beboreko/id578136103?mt=8&uo=4"];
        
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=578136103&mt=8&type=Purple+Software"];

        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
