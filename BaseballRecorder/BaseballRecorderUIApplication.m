//
//  BaseballRecorderUIApplication.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/28.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BaseballRecorderUIApplication.h"
#import "Utility.h"

@implementation BaseballRecorderUIApplication

@synthesize targetUrl;

- (void)openURL:(NSURL*)url options:(NSDictionary<NSString *, id> *)options completionHandler:(void (^ __nullable)(BOOL success))completion {
// - (BOOL)openURL:(NSURL*)url {
    targetUrl = url;
    
    NSString* messageStr;
    
    if([[url absoluteString] hasPrefix:@"http://"] == YES ||
       [[url absoluteString] hasPrefix:@"https://"] == YES ){
        [super openURL:targetUrl options:options completionHandler:completion];
        return;
    }
    
    if([[url absoluteString] hasPrefix:@"itms-apps://"] == YES){
        messageStr = @"AppStoreを起動します";
    } else {
        messageStr = @"アプリを起動します";
    }
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                 style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction* action) {
        [super openURL:self->targetUrl options:options completionHandler:completion];
                               }];
    UIAlertController* alertController = [Utility makeConfirmAlert:@"" message:messageStr okAction:okAction];
    
    [[Utility topViewController] presentViewController:alertController animated:YES completion:nil];
}

/*
- (BOOL)openURL:(NSURL *)url
{
    _url = url;
    
    NSString* messageStr;
    
    if([[url absoluteString] hasPrefix:@"itms-apps://"] == YES){
        messageStr = @"AppStoreを起動します";
    } else if([[url absoluteString] hasPrefix:@"http://"] == YES ||
              [[url absoluteString] hasPrefix:@"https://"] == YES ){
//        messageStr = @"Safariを起動します";
        [super openURL:_url];
        return YES;
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
*/

@end
