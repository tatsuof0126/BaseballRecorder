//
//  AppDelegate.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameResult.h"

// #define NO_TARGET -1

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

//@property (strong, nonatomic) NSArray* gameResultList;

@property (strong, nonatomic) GameResult* targetGameResult;

// @property int targatResultid;

+ (void)adjustForiPhone5:(UIView*)view;

@end
