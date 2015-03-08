//
//  ConfigManager.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/06.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TargetTerm.h"

@interface ConfigManager : NSObject

+ (void)initConfig;

+ (NSString*)getDefaultPlace;

+ (void)setDefaultPlace:(NSString*)place;

+ (NSString*)getDefaultMyTeam;

+ (void)setDefaultMyTeam:(NSString*)myteam;

+ (NSString*)getDefaultSendTo;

+ (void)setDefaultSendTo:(NSString*)sendto;

+ (BOOL)isCalcInning7Flg;

+ (void)setCalcInning7Flg:(BOOL)calcInning7Flg;

+ (BOOL)isShowMyteamFlg;

+ (void)setShowMyteamFlg:(BOOL)showMyteamFlg;

+ (NSString*)getCalcTargetTeam;

+ (void)setCalcTargetTeam:(NSString*)targetTeam;

+ (NSString*)getCalcTargetYear;

+ (void)setCalcTargetYear:(NSString*)targetYear;

+ (TargetTerm*)getCalcTargetTerm;

+ (void)setCalcTargetTerm:(TargetTerm*)targetTerm;

+ (BOOL)isRemoveAdsFlg;

+ (void)setRemoveAdsFlg:(BOOL)removeAdsFlg;

@end
