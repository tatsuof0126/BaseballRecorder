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

@end
