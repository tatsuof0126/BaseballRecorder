//
//  HelpViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/06/21.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import "HelpViewController.h"
#import "ConfigManager.h"
#import "AppDelegate.h"

@interface HelpViewController ()

@end

@implementation HelpViewController

@synthesize gadView;
@synthesize scrollView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    scrollView.contentSize = CGSizeMake(320, 600);
    
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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end

