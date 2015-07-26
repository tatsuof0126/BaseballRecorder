//
//  AppDelegate.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "AppDelegate.h"
#import "GAI.h"
#import "NADInterstitial.h"
#import "ConfigManager.h"
#import "GameResultManager.h"

@implementation AppDelegate

@synthesize purchaseManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    // Google Analyticsの初期化
    [self initializeGoogleAnalytics];
    
    // AppBankNetworkのインタースティシャル広告の初期化
    [[NADInterstitial sharedInstance] loadAdWithApiKey:@"ced5049f9d729e1847dbfa8b0d188218a720f20e"
                                                spotId:@"271381"];
    
    // サンプルデータを作る
    if(MAKE_SAMPLE_DATA == 1){
        [GameResultManager makeSampleData];
    }
    
    // 設定ファイルを初期化（必要な場合のみ）
    [ConfigManager initConfig];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
//    NSLog(@"URL : %@",[url absoluteString]);
//    NSLog(@"Schame : %@",[url scheme]);
//    NSLog(@"Query : %@",[url query]);
    
    return YES;
}

- (InAppPurchaseManager*)getInAppPurchaseManager {
    if(purchaseManager == nil){
        purchaseManager = [[InAppPurchaseManager alloc] init];
    }
    
    return purchaseManager;
    
}

+ (void)adjustForiPhone5:(UIView*)view {
    // iPhone5対応
    if([UIScreen mainScreen].bounds.size.height == 568){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y,
                                    oldRect.size.width, oldRect.size.height+88);
        view.frame = newRect;
    }
}

+ (void)adjustOriginForiPhone5:(UIView*)view {
    // iPhone5対応
    if([UIScreen mainScreen].bounds.size.height == 568){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y+88,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
}

+ (void)adjustOriginForBeforeiOS6:(UIView*)view {
    // iOS5/6対応
    if([[[UIDevice currentDevice] systemVersion] compare:@"7" options:NSNumericSearch]
       == NSOrderedAscending){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y-20,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
}

- (void)initializeGoogleAnalytics {
    // トラッキングIDを設定
    [[GAI sharedInstance] trackerWithTrackingId:@"UA-23529359-5"];
    
    // 例外を Google Analytics に送る
    [GAI sharedInstance].trackUncaughtExceptions = YES;
}

@end
