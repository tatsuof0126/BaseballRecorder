//
//  BattingResult.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

#define S_ATBATS   0
#define S_HITS     1
#define S_SINGLES  2
#define S_DOUBLES  3
#define S_TRIPLES  4
#define S_HOMERUNS 5
#define S_STRIKEOUTS 6
#define S_WALKS    7
#define S_SACRIFICES 8

@interface BattingResult : NSObject

@property int position;
@property int result;

+ (NSArray*)getBattingResultTypeArray;

+ (NSArray*)getBattingStatisticsCountArray;

+ (BattingResult*)makeBattingResult:(int)position result:(int)result;

- (NSString*)getResultString;

- (int)getStatisticsCounts:(int)type;

@end
