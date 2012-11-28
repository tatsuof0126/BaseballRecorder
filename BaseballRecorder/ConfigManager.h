//
//  ConfigManager.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/06.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConfigManager : NSObject

+ (NSString*)getDefaultPlace;

+ (void)setDefaultPlace:(NSString*)place;

+ (NSString*)getDefaultMyTeam;

+ (void)setDefaultMyTeam:(NSString*)myteam;

@end
