//
//  HelpViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/06/21.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import "HelpViewController.h"
#import "TrackingManager.h"
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

@synthesize adg = adg_;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"ヘルプ画面（打撃成績）"];
    
    // ScrollViewの高さを定義＆iPhone5対応
    _scrollView.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:_scrollView];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollView];

    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        NSDictionary *adgparam = @{@"locationid" : @"21680", @"adtype" : @(kADG_AdType_Sp),
                                   @"originx" : @(0), @"originy" : @(630), @"w" : @(320), @"h" : @(50)};
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
    [AppDelegate adjustOriginForBeforeiOS6:self.adg.view];

    // Scrollviewの大きさ定義＆iPhone5対応
    _scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:_scrollView];
    [AppDelegate adjustOriginForBeforeiOS6:_scrollView];
}

- (IBAction)backButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"ヘルプ画面（打撃成績）―戻る" value:nil screen:@"ヘルプ画面（打撃成績）"];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
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

- (void) dealloc {
    adg_.delegate = nil;
    adg_ = nil;
}

@end

