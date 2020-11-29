//
//  Utility.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/24.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utility : NSObject

// + (void)showAlert:(NSString*)message;

// + (void)showAlert:(NSString*)title message:(NSString*)message;

+ (void)showAlert:(NSString*)message;

+ (void)showAlert:(NSString*)title message:(NSString*)message;

+ (void)showAlert:(NSString*)title message:(NSString*)message buttonText:(NSString*)buttonText;

+ (UIAlertController*)makeConfirmAlert:(NSString*)title message:(NSString*)message okAction:(UIAlertAction*)okAction;

+ (UIViewController*)topViewController;

//+ (NSString*)getFloatStr:(float)floatvalue;
+ (NSString*)getFloatStr:(float)floatvalue appendBlank:(BOOL)appendBlank;

+ (NSString*)getFloatStr2:(float)floatvalue;

+ (int)convert2int:(NSInteger)integer;

+ (UIActivityIndicatorView*)getIndicatorView:(UIViewController*)controller;

+ (NSDate*)getDate:(NSString*)year month:(NSString*)month day:(NSString*)day;

+ (BOOL)isToday:(NSDate*)date;

@end
