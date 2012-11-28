//
//  GameResult.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BattingResult.h"

@interface GameResult : NSObject

@property int resultid;
@property int year;
@property int month;
@property int day;

@property (strong, nonatomic, readwrite) NSString *place;
@property (strong, nonatomic, readwrite) NSString *myteam;
@property (strong, nonatomic, readwrite) NSString *otherteam;

@property int myscore;
@property int otherscore;

@property (strong, nonatomic, readwrite) NSMutableArray *battingResultArray;

- (BattingResult*)getBattingResult:(NSInteger)resultno;

- (void)addBattingResult:(BattingResult*)battingResult;

- (void)replaceBattingResult:(BattingResult*)battingResult resultno:(NSInteger)resultno;

- (void)removeBattingResult:(NSInteger)resultno;

- (NSString*)getDateString;

- (NSString*)getGameResultString;

- (NSData*)getGameResultNSData;

+ (GameResult*)makeGameResult:(NSData*)data;

- (NSComparisonResult)compareDate:(GameResult*)data;

@end
