//
//  GameResult.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResult.h"

#define SAVE_VERSION 2

@implementation GameResult

@synthesize battingResultArray;
@synthesize UUID;
@synthesize resultid;
@synthesize year;
@synthesize month;
@synthesize day;
@synthesize place;
@synthesize myteam;
@synthesize otherteam;
@synthesize myscore;
@synthesize otherscore;
@synthesize daten;
@synthesize steal;
@synthesize errors;

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
    if( SAVE_VERSION == 1 ){
        return [self getGameResultNSDataV1];
    } else if( SAVE_VERSION == 2 ){
        return [self getGameResultNSDataV2];
    } else {
        return [self getGameResultNSDataV1];
    }
}

- (NSData*)getGameResultNSDataV1 {
    NSMutableString* resultStr = [NSMutableString string];
    
    // １行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore]];
    
    // ２行目：打撃成績（場所、結果、場所、結果・・・・）
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

- (NSData*)getGameResultNSDataV2 {
    NSMutableString* resultStr = [NSMutableString string];
    
//    NSLog(@"UUID : %@",UUID);
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V2）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V2,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、盗塁、失策）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,steal,errors]];
    
    // ３行目：打撃成績（場所、結果、場所、結果・・・・）
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
    NSString* resultStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray* resultStrArray = [resultStr componentsSeparatedByString:@"\n"];
    
//    NSLog(@"resultStr : %@", resultStr);
    
    @try {
        // １行目にファイル形式とUUIDがあるはず
        NSString* headerStr = [resultStrArray objectAtIndex:0];
        NSArray* headerStrArray = [headerStr componentsSeparatedByString:@","];
        NSString* versionStr = [headerStrArray objectAtIndex:0];
        NSString* resultUUID = [headerStrArray objectAtIndex:1];
    
        if([versionStr isEqualToString:@"V2"] == true){
            // "V2"という文字列ならV2形式
            return [self makeGameResultV2:resultStrArray resultUUID:resultUUID];
        } else {
            // どのバージョンでもない場合はV1形式と見なす
            return [self makeGameResultV1:resultStrArray];
        }
    }
    @catch (NSException *exception) {
//        NSLog(@"例外名：%@", exception.name);
//        NSLog(@"理由：%@", exception.reason);
    }
    
    // 例外が発生したらnilを返す
    return nil;
}

// V1形式での読み込み
// １行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点）
// ２行目：打撃成績（場所、結果、場所、結果・・・・）
+ (GameResult*)makeGameResultV1:(NSArray*)resultStrArray {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:0];
    [self setGameInfo:gameResult gameInfoStr:gameInfoStr];
    
    // ２行目は打撃成績（打撃成績がないときは空行だが２行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:1];
    [self setBattingResult:gameResult battingResultStr:battingResultStr];
    
    return gameResult;
}

// V2形式での読み込み
// １行目：ファイル形式バージョン（V2）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、盗塁、失策）
// ３行目：打撃成績（場所、結果、場所、結果・・・・）
+ (GameResult*)makeGameResultV2:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目は打撃成績（打撃成績がないときは空行だが２行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:2];
    [self setBattingResult:gameResult battingResultStr:battingResultStr];
    
    return gameResult;
}

+ (void)setGameInfo:(GameResult*)gameResult gameInfoStr:(NSString*)gameInfoStr {
    NSArray* gameInfoStrArray = [gameInfoStr componentsSeparatedByString:@","];
    gameResult.resultid = [[gameInfoStrArray objectAtIndex:0] intValue];
    gameResult.year = [[gameInfoStrArray objectAtIndex:1] intValue];
    gameResult.month = [[gameInfoStrArray objectAtIndex:2] intValue];
    gameResult.day = [[gameInfoStrArray objectAtIndex:3] intValue];
    gameResult.place = [gameInfoStrArray objectAtIndex:4];
    gameResult.myteam = [gameInfoStrArray objectAtIndex:5];
    gameResult.otherteam = [gameInfoStrArray objectAtIndex:6];
    gameResult.myscore = [[gameInfoStrArray objectAtIndex:7] intValue];
    gameResult.otherscore = [[gameInfoStrArray objectAtIndex:8] intValue];
}

+ (void)setGameInfoV2:(GameResult*)gameResult gameInfoStr:(NSString*)gameInfoStr {
    NSArray* gameInfoStrArray = [gameInfoStr componentsSeparatedByString:@","];
    gameResult.resultid = [[gameInfoStrArray objectAtIndex:0] intValue];
    gameResult.year = [[gameInfoStrArray objectAtIndex:1] intValue];
    gameResult.month = [[gameInfoStrArray objectAtIndex:2] intValue];
    gameResult.day = [[gameInfoStrArray objectAtIndex:3] intValue];
    gameResult.place = [gameInfoStrArray objectAtIndex:4];
    gameResult.myteam = [gameInfoStrArray objectAtIndex:5];
    gameResult.otherteam = [gameInfoStrArray objectAtIndex:6];
    gameResult.myscore = [[gameInfoStrArray objectAtIndex:7] intValue];
    gameResult.otherscore = [[gameInfoStrArray objectAtIndex:8] intValue];
    gameResult.daten = [[gameInfoStrArray objectAtIndex:9] intValue];
    gameResult.steal = [[gameInfoStrArray objectAtIndex:10] intValue];
    gameResult.errors = [[gameInfoStrArray objectAtIndex:11] intValue];
}

+ (void)setBattingResult:(GameResult*)gameResult battingResultStr:(NSString*)battingResultStr {
    NSArray* battingResultStrArray = [battingResultStr componentsSeparatedByString:@","];
    for (int i=0; i<battingResultStrArray.count/2; i++) {
        int position = [[battingResultStrArray objectAtIndex:i*2] intValue];
        int result = [[battingResultStrArray objectAtIndex:i*2+1] intValue];
        
        BattingResult* battingResult = [BattingResult makeBattingResult:position result:result];
        [gameResult addBattingResult:battingResult];
    }
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
