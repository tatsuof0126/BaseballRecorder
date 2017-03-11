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
#define S_DOUBLEPLAY 9
#define S_SACRIFICEFLIES 99

#define P_STR_PICKER 0
#define P_STR_SHORT  1
#define P_STR_LONG   2

#define R_STR_PICKER 0
#define R_STR_SHORT  1
#define R_STR_SEMILONG 2
#define R_STR_LONG   3

#define R_HOMERUN 10

#define R_TYPE_NEEDP 0
#define R_TYPE_COLOR 1
#define R_TYPE_COLOR2 2
#define R_TYPE_COLOR3 3

@interface BattingResult : NSObject

@property int position;
@property int result;

+ (NSArray*)getBattingPositionStringArray:(int)type;

+ (NSArray*)getBattingResultStringArray:(int)type;

+ (NSArray*)getBattingResultTypeArray2:(int)type;

+ (NSArray*)getBattingStatisticsCountArray;

+ (BattingResult*)makeBattingResult:(int)position result:(int)result;

- (NSString*)getResultShortString;

- (NSString*)getResultSemiLongString;

- (NSString*)getResultLongString;

- (UIColor*)getResultColor;

- (UIColor*)getResultColorForListView;

- (UIColor*)getResultColorForAnalysisView;

- (int)getStatisticsCounts:(int)type;

@end
