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

@property (strong, nonatomic, readwrite) NSString *UUID;
@property int resultid;
@property int year;
@property int month;
@property int day;

@property (strong, nonatomic, readwrite) NSString *place;
@property (strong, nonatomic, readwrite) NSString *myteam;
@property (strong, nonatomic, readwrite) NSString *otherteam;

@property int myscore;
@property int otherscore;

@property int daten;
@property int tokuten;
@property int steal;

@property (strong, nonatomic, readwrite) NSString *memo;

@property (strong, nonatomic, readwrite) NSMutableArray *battingResultArray;

@property int inning;
@property int inning2;
@property int hianda;
@property int hihomerun;
@property int dassanshin;
@property int yoshikyu;
@property int yoshikyu2;
@property int shitten;
@property int jisekiten;
@property BOOL kanto;
@property int sekinin;

- (BattingResult*)getBattingResult:(NSInteger)resultno;

- (void)addBattingResult:(BattingResult*)battingResult;

- (void)replaceBattingResult:(BattingResult*)battingResult resultno:(NSInteger)resultno;

- (void)removeBattingResult:(NSInteger)resultno;

- (NSString*)getDateString;

- (NSString*)getMailSubject;

- (NSString*)getMailBody;

- (NSString*)getGameResultString;

- (NSData*)getGameResultNSData;

+ (GameResult*)makeGameResult:(NSData*)data;

- (NSComparisonResult)compareDate:(GameResult*)data;

+ (NSArray*)getInningPickerArray;

+ (NSString*)getInningString:(int)inning inning2:(int)inning2;

+ (NSArray*)getSekininPickerArray;

@end
