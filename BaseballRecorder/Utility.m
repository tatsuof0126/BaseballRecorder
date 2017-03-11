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

+ (void)showAlert:(NSString*)title message:(NSString*)message {
    UIAlertView *alert = [ [UIAlertView alloc] initWithTitle:title
        message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
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
    
    // NSLog(@"%@/%@/%@",year, month, day);
    
    // Dateオブジェクトに変換して正しい日時かをチェック
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setCalendar:calendar];
    
    NSDate* retDate = [formatter dateFromString:dateStr];
    
    if(retDate == nil){
        return nil;
    }
    
    // 日付チェック（2月31日などをチェック）
    NSCalendar* checkCalendar = [NSCalendar currentCalendar];
    [checkCalendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents* dateComps = [checkCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:retDate];
    
    if([year integerValue] != dateComps.year ||
       [month integerValue] != dateComps.month ||
       [day integerValue] != dateComps.day){
        return nil;
    }
    
    // NSLog(@" -> %@", [retDate description]);
    
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
