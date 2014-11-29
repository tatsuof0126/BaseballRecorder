//
//  GameResultManager.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/27.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameResult.h"

@interface GameResultManager : NSObject

+ (void)saveGameResult:(GameResult*)gameResult;

+ (GameResult*)loadGameResult:(int)resultid;

+ (void)removeGameResult:(int)resultid;

+ (NSArray*)loadGameResultList;

+ (void)makeSampleData;

@end
