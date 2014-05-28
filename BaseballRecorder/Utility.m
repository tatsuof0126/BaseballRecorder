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
    if(isnan(floatvalue) == YES){
        return @".--- ";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.03f",floatvalue];
    
    if(floatvalue < 1.0){
        floatStr = [[floatStr substringFromIndex:1] stringByAppendingString:@" "];
    }
    
    return floatStr;
}

+ (NSString*)getFloatStr2:(float)floatvalue {
    if(isnan(floatvalue) == YES || isinf(floatvalue)){
        return @"-.--";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.02f",floatvalue];
    
    return floatStr;
}

+ (int)convert2int:(NSInteger)integer {
    // NSIntegerを無理やりintに直している
    return [[NSNumber numberWithInteger:integer] intValue];
}

@end
