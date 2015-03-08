//
//  ConfigManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/06.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ConfigManager.h"
#import "Utility.h"

@implementation ConfigManager

+ (void)initConfig {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary* defaultDic = [NSMutableDictionary dictionary];
    [defaultDic setObject:@"" forKey:@"PLACE"];
    [defaultDic setObject:@"" forKey:@"MYTEAM"];
    [defaultDic setObject:@"" forKey:@"SENDTO"];
    [defaultDic setObject:@"すべて" forKey:@"TARGETTEAM"];
    [defaultDic setObject:@"すべて" forKey:@"TARGETYEAR"];
    [defaultDic setObject:[TargetTerm getDefaultTermStringForConfig] forKey:@"TARGETTERM"];
    [defaults registerDefaults:defaultDic];
}

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

+ (BOOL)isCalcInning7Flg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"CALCINNING7"];
}

+ (void)setCalcInning7Flg:(BOOL)calcInning7Flg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:calcInning7Flg forKey:@"CALCINNING7"];
    [defaults synchronize];
}

+ (BOOL)isShowMyteamFlg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"SHOWMYTEAM"];
}

+ (void)setShowMyteamFlg:(BOOL)showMyteamFlg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:showMyteamFlg forKey:@"SHOWMYTEAM"];
    [defaults synchronize];
}

+ (NSString*)getCalcTargetTeam {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"TARGETTEAM"];
}

+ (void)setCalcTargetTeam:(NSString*)targetTeam {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:targetTeam forKey:@"TARGETTEAM"];
    [defaults synchronize];
}

+ (NSString*)getCalcTargetYear {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults stringForKey:@"TARGETYEAR"];
}

+ (void)setCalcTargetYear:(NSString*)targetYear {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:targetYear forKey:@"TARGETYEAR"];
    [defaults synchronize];
}

+ (TargetTerm*)getCalcTargetTerm {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [TargetTerm makeTargetTerm:[defaults stringForKey:@"TARGETTERM"]];
}

+ (void)setCalcTargetTerm:(TargetTerm*)targetTerm {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[targetTerm getTermStringForConfig] forKey:@"TARGETTERM"];
    [defaults synchronize];
}

+ (BOOL)isRemoveAdsFlg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    return [defaults boolForKey:@"REMOVEADSFLG"];
}

+ (void)setRemoveAdsFlg:(BOOL)removeAdsFlg {
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:removeAdsFlg forKey:@"REMOVEADSFLG"];
    [defaults synchronize];
}

@end
