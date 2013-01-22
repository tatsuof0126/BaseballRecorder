//
//  ConfigManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/06.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ConfigManager.h"

@implementation ConfigManager

+ (NSString*)getDefaultPlace {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"PLACE"];
}

+ (void)setDefaultPlace:(NSString*)place {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:place forKey:@"PLACE"];
    [defaults synchronize];
}

+ (NSString*)getDefaultMyTeam {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"MYTEAM"];
}

+ (void)setDefaultMyTeam:(NSString*)myteam {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myteam forKey:@"MYTEAM"];
    [defaults synchronize];
}

+ (NSString*)getDefaultSendTo {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"SENDTO"];
}

+ (void)setDefaultSendTo:(NSString*)sendto {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:sendto forKey:@"SENDTO"];
    [defaults synchronize];
}

@end
