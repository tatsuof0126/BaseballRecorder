//
//  GameResult.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResult.h"

@implementation GameResult

@synthesize battingResultArray;
@synthesize resultid;
@synthesize year;
@synthesize month;
@synthesize day;
@synthesize place;
@synthesize myteam;
@synthesize otherteam;
@synthesize myscore;
@synthesize otherscore;

- (BattingResult*)getBattingResult:(NSInteger)resultno {
    return [battingResultArray objectAtIndex:resultno];
}

- (void)addBattingResult:(BattingResult*)battingResult {
    if (battingResultArray == nil){
        battingResultArray = [[NSMutableArray alloc] init];
    }
    
    [battingResultArray addObject:battingResult];
}

- (void)replaceBattingResult:(BattingResult*)battingResult resultno:(NSInteger)resultno {
    [battingResultArray replaceObjectAtIndex:resultno withObject:battingResult];
}

- (void)removeBattingResult:(NSInteger)resultno {
    [battingResultArray removeObjectAtIndex:resultno];
}

- (NSString*)getDateString {
    return [NSString stringWithFormat:@"%d年%d月%d日",year,month,day];
}

- (NSString*)getGameResultString {
    return [NSString stringWithFormat:@"%d-%d",myscore,otherscore];
}

- (NSData*)getGameResultNSData {
    NSMutableString* resultStr = [NSMutableString string];
    
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore]];
    
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    
//    NSLog(@"string : %@",resultStr);
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

+ (GameResult*)makeGameResult:(NSData*)data {
    GameResult* gameResult = [[GameResult alloc] init];
    
    NSString* resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

//    NSLog(@"resultStr : %@", resultStr);
    
    NSArray* resultStrArray = [resultStr componentsSeparatedByString:@"\n"];
    
    // １行目はヘッダー情報
    NSString* headerStr = [resultStrArray objectAtIndex:0];
    NSArray* headerStrArray = [headerStr componentsSeparatedByString:@","];
    gameResult.resultid = [[headerStrArray objectAtIndex:0] intValue];
    gameResult.year = [[headerStrArray objectAtIndex:1] intValue];
    gameResult.month = [[headerStrArray objectAtIndex:2] intValue];
    gameResult.day = [[headerStrArray objectAtIndex:3] intValue];
    gameResult.place = [headerStrArray objectAtIndex:4];
    gameResult.myteam = [headerStrArray objectAtIndex:5];
    gameResult.otherteam = [headerStrArray objectAtIndex:6];
    gameResult.myscore = [[headerStrArray objectAtIndex:7] intValue];
    gameResult.otherscore = [[headerStrArray objectAtIndex:8] intValue];
    
    // ２行目は打撃成績（打撃成績がないときは空行だが２行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:1];
    NSArray* battingResultStrArray = [battingResultStr componentsSeparatedByString:@","];
    for (int i=0; i<battingResultStrArray.count/2; i++) {
        int position = [[battingResultStrArray objectAtIndex:i*2] intValue];
        int result = [[battingResultStrArray objectAtIndex:i*2+1] intValue];
        
        BattingResult* battingResult = [BattingResult makeBattingResult:position result:result];
        [gameResult addBattingResult:battingResult];
    }
    
    return gameResult;
}

- (NSComparisonResult)compareDate:(GameResult*)data {
    if (self.year > data.year) {
        return NSOrderedAscending;
    } else if (self.year < data.year) {
        return NSOrderedDescending;
    }
    
    if (self.month > data.month) {
        return NSOrderedAscending;
    } else if (self.month < data.month) {
        return NSOrderedDescending;
    }
    
    if (self.day > data.day) {
        return NSOrderedAscending;
    } else if (self.day < data.day) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

@end
