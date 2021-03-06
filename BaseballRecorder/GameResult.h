//
//  GameResult.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BattingResult.h"

#define TAMAKAZU_NONE -999

@interface GameResult : NSObject

@property int version;
@property (strong, nonatomic, readwrite) NSString *UUID;
@property int resultid;
@property int year;
@property int month;
@property int day;

@property (strong, nonatomic, readwrite) NSString *place;
@property (strong, nonatomic, readwrite) NSString *myteam;
@property (strong, nonatomic, readwrite) NSString *otherteam;
@property (strong, nonatomic, readwrite) NSString *tagtext;

@property int myscore;
@property int otherscore;

@property int daten;
@property int tokuten;
@property int steal;
@property int stealOut;
@property int error;

@property int dajun;
@property int shubi1;
@property int shubi2;
@property int shubi3;
@property int seme;

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
@property int tamakazu;

- (BattingResult*)getBattingResult:(NSInteger)resultno;

- (void)addBattingResult:(BattingResult*)battingResult;

- (void)replaceBattingResult:(BattingResult*)battingResult resultno:(NSInteger)resultno;

- (void)removeBattingResult:(NSInteger)resultno;

- (NSString*)getDateString;

- (NSString*)getMailSubject;

- (NSString*)getMailBody;

- (NSString*)getGameResultString;

- (NSString*)getGameResultStringWithTeam;

- (NSData*)getGameResultNSData;

- (NSString*)getInningString;

- (NSString*)getSekininString;

- (UIColor*)getSekininColor;

- (NSArray*)getTagList;

+ (GameResult*)makeGameResult:(NSData*)data;

- (NSComparisonResult)compareDate:(GameResult*)data;

+ (NSArray*)getInningPickerArray;

+ (NSString*)getInningString:(int)inning inning2:(int)inning2;

+ (NSArray*)getSekininPickerArray;

+ (NSArray*)getDajunPickerArray;

+ (NSArray*)getShortDajunPickerArray;

+ (NSArray*)getShubiPickerArray;

+ (NSArray*)getShortShubiPickerArray;

- (NSString*)getSemeString;

- (NSString*)getDajunString;

- (NSString*)getShubiConnectedString;

+ (NSString*)adjustTagText:(NSString*)sourceString;

- (BOOL)isLatestVersion;

@end
