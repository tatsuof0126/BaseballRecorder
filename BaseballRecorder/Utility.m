//
//  Utility.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/24.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "Utility.h"

@implementation Utility

+ (void)showAlert:(NSString*)message {
    [self showAlert:@"" message:message];
}

/*
+ (void)showAlert:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:title
        message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}
*/

+ (void)showAlert:(NSString*)title message:(NSString*)message {
    [self showAlert:@"" message:message buttonText:@"OK"];
}

+ (void)showAlert:(NSString*)title message:(NSString*)message buttonText:(NSString*)buttonText {
    UIAlertController* alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* okAction =
        [UIAlertAction actionWithTitle:buttonText
                                 style:UIAlertActionStyleDefault
                               handler:nil];
    [alertController addAction:okAction];
    
    [[Utility topViewController] presentViewController:alertController animated:YES completion:nil];
}

// https://qastack.jp/programming/26667009/get-top-most-uiviewcontroller
// https://sites.google.com/site/kindaichiios9/home/uiapplication/uiapplicationkararootviewcontrollerwo-qu-desuru
+ (UIViewController*)topViewController {
    UIViewController* rootVC = UIApplication.sharedApplication.keyWindow.rootViewController;
    return [Utility topPresentedViewController:rootVC];
}

+ (UIViewController*)topPresentedViewController:(UIViewController*)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        UIViewController* targetViewController =  (UIViewController*)[((UINavigationController*)viewController).viewControllers objectAtIndex:0];
        return [Utility topPresentedViewController:targetViewController];
    }
    
    if ([viewController isKindOfClass:[UITabBarController class]]) {
        UIViewController* targetViewController = ((UITabBarController*)viewController).selectedViewController;
        return [Utility topPresentedViewController:targetViewController];
    }
    
    if(viewController.presentedViewController){
        return [Utility topPresentedViewController:viewController.presentedViewController];
    }
    
    return viewController;
}

+ (UIAlertController*)makeConfirmAlert:(NSString*)title message:(NSString*)message okAction:(UIAlertAction*)okAction {
    UIAlertController* alertController =
        [UIAlertController alertControllerWithTitle:title
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:okAction];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"キャンセル"
                                 style:UIAlertActionStyleCancel
                               handler:nil];
    [alertController addAction:cancelAction];
    
    return alertController;
}

+ (NSString*)getFloatStr:(float)floatvalue appendBlank:(BOOL)appendBlank {
    if(isnan(floatvalue) == YES || isinf(floatvalue) == YES){
        return @".--- ";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.03f",floatvalue];
    
    if(floatvalue >= 0.0f && floatvalue < 1.0f){
        floatStr = [[floatStr substringFromIndex:1] stringByAppendingString:@" "];
    }
    
    return floatStr;
}

+ (NSString*)getFloatStr2:(float)floatvalue {
    if(isnan(floatvalue) == YES || isinf(floatvalue) == YES){
        return @"-.--";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.02f",floatvalue];
    
    return floatStr;
}

+ (int)convert2int:(NSInteger)integer {
    // NSIntegerを無理やりintに直している
    return [[NSNumber numberWithInteger:integer] intValue];
}

+ (UIActivityIndicatorView*)getIndicatorView:(UIViewController*)controller {
    UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.color = [UIColor darkGrayColor];
    indicator.hidesWhenStopped = YES;
    indicator.center = CGPointMake(controller.view.bounds.size.width / 2, controller.view.bounds.size.height / 2);
    return indicator;
}

+ (NSDate*)getDate:(NSString*)year month:(NSString*)month day:(NSString*)day {
    NSString* dateStr = [NSString stringWithFormat:@"%@-%@-%@ 00:00", year, month, day];
    
    // NSLog(@"%@/%@/%@ -> %@",year, month, day, dateStr);
    
    // Dateオブジェクトに変換して正しい日時かをチェック
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [formatter setLocale:[NSLocale systemLocale]];
    // [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setCalendar:calendar];
    
    NSDate* retDate = [formatter dateFromString:dateStr];
    
    if(retDate == nil){
        return nil;
    }
    
    // NSLog(@"retDate -> %@", [retDate description]);
    
    // 日付チェック（2月31日などをチェック）
    // NSCalendar* checkCalendar = [NSCalendar currentCalendar];
    NSCalendar* checkCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [checkCalendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents* dateComps = [checkCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:retDate];
    
    // NSLog(@"%@ <-> %d", year, (int)dateComps.year);
    // NSLog(@"%@ <-> %d", month, (int)dateComps.month);
    // NSLog(@"%@ <-> %d", day, (int)dateComps.day);
    
    // if([year integerValue] != dateComps.year ||
    //    [month integerValue] != dateComps.month ||
    //    [day integerValue] != dateComps.day){
    //     return nil;
    // }
    
    if([month integerValue] != dateComps.month ||
       [day integerValue] != dateComps.day){
        return nil;
    }
    
    // NSLog(@"retDate -> %@", [retDate description]);
    
    return retDate;
}

+ (BOOL)isToday:(NSDate*)date {
    if(date == nil){
        return NO;
    }
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps
        = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    NSDate* nowDate = [NSDate date];
    NSCalendar* nowCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *nowDateComps
        = [nowCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:nowDate];
    
    if(dateComps.year == nowDateComps.year &&
       dateComps.month == nowDateComps.month &&
       dateComps.day == nowDateComps.day){
        return YES;
    } else {
        return NO;
    }
}

@end
