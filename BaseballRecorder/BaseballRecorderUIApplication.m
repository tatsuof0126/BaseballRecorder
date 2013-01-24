//
//  BaseballRecorderUIApplication.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/28.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BaseballRecorderUIApplication.h"

@implementation BaseballRecorderUIApplication

@synthesize _url;

- (BOOL)openURL:(NSURL *)url
{
    _url = url;
    
    NSString* messageStr;
    
    if([[url absoluteString] hasPrefix:@"itms-apps://"] == YES){
        messageStr = @"AppStoreを起動します";
    } else if([[url absoluteString] hasPrefix:@"http://"] == YES ||
              [[url absoluteString] hasPrefix:@"https://"] == YES ){
        messageStr = @"Safariを起動します";
    } else {
        messageStr = @"アプリを起動します";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.message = messageStr;
    [alert addButtonWithTitle:@"キャンセル"];
    [alert addButtonWithTitle:@"OK"];
    alert.delegate = self;
    
    [alert show];
    
    return YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        [super openURL:_url];
    }
}

@end
