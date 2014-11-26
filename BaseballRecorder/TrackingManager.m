//
//  TrackingManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/11/24.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import "TrackingManager.h"
#import "GAI.h"
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

@implementation TrackingManager

// スクリーン名をGoogleAnalyticsに送信する
+ (void)sendScreenTracking:(NSString *)screenName {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    tracker.allowIDFACollection = NO;
    
    // スクリーン名を設定
    [tracker set:kGAIScreenName value:screenName];
    
    // トラッキング情報を送信する
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    // 送信が終わったらtrackerに設定されているスクリーン名を初期化する
    [tracker set:kGAIScreenName value:nil];
}


// イベントをGoogleAnalyticsに送信する
// イベント情報送信前にスクリーン名を設定するとどの画面でイベントが起きたかも分析可能です
+ (void)sendEventTracking:(NSString *)category action:(NSString *)action label:(NSString *)label value:(NSNumber *)value screen:(NSString *)screen {
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    tracker.allowIDFACollection = NO;
    
    // スクリーン名を設定
    [tracker set:kGAIScreenName value:screen];
    
    // イベントのトラッキング情報を送信する
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:category
                                                          action:action label:label value:value] build]];
}

@end
