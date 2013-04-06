//
//  AppDelegate.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameResult.h"
#import "InAppPurchaseManager.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) GameResult* targetGameResult;

@property (strong, nonatomic) InAppPurchaseManager* purchaseManager;

- (InAppPurchaseManager*)getInAppPurchaseManager;

+ (void)adjustForiPhone5:(UIView*)view;

+ (void)adjustOriginForiPhone5:(UIView*)view;

@end
