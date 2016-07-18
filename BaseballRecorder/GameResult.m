//
//  GameResult.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResult.h"

#define SAVE_VERSION 8

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
@synthesize tagtext;
@synthesize myscore;
@synthesize otherscore;
@synthesize daten;
@synthesize tokuten;
@synthesize steal;
@synthesize stealOut;
@synthesize error;
@synthesize dajun;
@synthesize shubi1;
@synthesize shubi2;
@synthesize shubi3;
@synthesize seme;

@synthesize memo;

@synthesize inning;
@synthesize inning2;
@synthesize hianda;
@synthesize hihomerun;
@synthesize dassanshin;
@synthesize yoshikyu;
@synthesize yoshikyu2;
@synthesize shitten;
@synthesize jisekiten;
@synthesize kanto;
@synthesize sekinin;
@synthesize tamakazu;

- (id)init {
    if(self = [super init]){
        battingResultArray = nil;
        UUID = @"";
        resultid = 0;
        year = 0;
        month = 0;
        day = 0;
        place = @"";
        myteam = @"";
        otherteam = @"";
        tagtext = @"";
        myscore = 0;
        otherscore = 0;
        daten = 0;
        tokuten = 0;
        steal = 0;
        stealOut = 0;
        error = 0;
        seme = 0;
        dajun = 0;
        shubi1 = 0;
        shubi2 = 0;
        shubi3 = 0;
        
        memo = @"";
        
        inning = 0;
        inning2 = 0;
        hianda = 0;
        hihomerun = 0;
        dassanshin = 0;
        yoshikyu = 0;
        yoshikyu2 = 0;
        shitten = 0;
        jisekiten = 0;
        kanto = NO;
        sekinin = 0;
        tamakazu = TAMAKAZU_NONE;
    }
    return self;
}

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
    return [NSString stringWithFormat:@"%d - %d",myscore,otherscore];
}

- (NSString*)getGameResultStringWithTeam {
    return [NSString stringWithFormat:@"%@ %d - %d %@",myteam,myscore,otherscore,otherteam];
}

- (NSString*)getGameResultStringWithTeamSeme {
    NSString* semeStr = @"";
    if(seme != 0){
        semeStr = [NSString stringWithFormat:@"(%@)",[self getSemeString]];
    }
    
    return [NSString stringWithFormat:@"%@%@ %d - %d %@",myteam,semeStr,myscore,otherscore,otherteam];
}

- (NSString*)getMailSubject {
    return [NSString stringWithFormat:@"【ベボレコ】%d年%d月%d日 %@ %d-%d %@ @ベボレコ"
            ,year,month,day,myteam,myscore,otherscore,otherteam];
}

- (NSString*)getMailBody {
    NSMutableString* bodyString = [NSMutableString string];
    
    [bodyString appendString:[NSString stringWithFormat:@"%d年%d月%d日 %@\n",year,month,day,place]];
    [bodyString appendString:[NSString stringWithFormat:@"%@\n",[self getGameResultStringWithTeamSeme]]];
    
//    [bodyString appendString:[NSString stringWithFormat:@"%@ %d-%d %@\n",myteam,myscore,otherscore,otherteam]];
    
    // 打撃成績
    if( (battingResultArray != nil && battingResultArray.count >= 1) ||
       daten >= 1 || tokuten >= 1 || error >= 1 || steal >= 1 || stealOut >= 1){
        [bodyString appendString:[NSString stringWithFormat:@"\n打撃成績\n"]];

        NSMutableString* dajunShubiStr = [NSMutableString string];
        if(dajun != 0){
            [dajunShubiStr appendFormat:@"%@ ", [self getDajunString]];
        }
        [dajunShubiStr appendString:[self getShubiConnectedString]];
        if([dajunShubiStr length] > 0){
            [bodyString appendString:[NSString stringWithFormat:@"%@\n", dajunShubiStr]];
        }
        
        for (int i=0;i<battingResultArray.count;i++){
            BattingResult* battingResult = [battingResultArray objectAtIndex:i];
            [bodyString appendString:[NSString stringWithFormat:@"第%d打席：%@\n"
                                  ,i+1,[battingResult getResultLongString]]];
        }
        [bodyString appendString:[NSString stringWithFormat:@"打点：%d　得点：%d　失策：%d\n",
                              daten,tokuten,error]];
        [bodyString appendString:[NSString stringWithFormat:@"盗塁：%d　盗塁死：%d\n",
                                  steal,stealOut]];
    }
    
    // 投手成績
    if(inning != 0 || inning2 != 0){
        [bodyString appendString:[NSString stringWithFormat:@"\n投手成績\n"]];
        [bodyString appendString:[NSString stringWithFormat:@"投球回：%@%@ %@\n"
                                  ,[GameResult getInningString:inning inning2:inning2]
                                  ,kanto ? @" (完投)" : @""
                                  ,[[GameResult getSekininPickerArray] objectAtIndex:sekinin]]];
        [bodyString appendString:[NSString stringWithFormat:
                                  @"被安打：%d　被本塁打：%d\n",hianda,hihomerun]];
        [bodyString appendString:[NSString stringWithFormat:
                                  @"奪三振：%d　与四球：%d　与死球：%d\n",dassanshin,yoshikyu,yoshikyu2]];
        [bodyString appendString:[NSString stringWithFormat:
                                  @"失点：%d　自責点：%d\n",shitten,jisekiten]];
    }
    
    // 投球数
    if(tamakazu != TAMAKAZU_NONE){
        [bodyString appendString:[NSString stringWithFormat:@"投球数：%d\n",tamakazu]];
    }
    
    // タグ
    if([@"" isEqualToString:tagtext] == NO){
        [bodyString appendString:[NSString stringWithFormat:@"\nタグ：%@\n",tagtext]];
    }
    
    // メモ
    if([@"" isEqualToString:memo] == NO){
        [bodyString appendString:[NSString stringWithFormat:@"\nメモ：\n"]];
        [bodyString appendString:[NSString stringWithFormat:@"%@\n",memo]];
    }
    
    return bodyString;
}


- (NSData*)getGameResultNSData {
    if( SAVE_VERSION == 1 ){
        return [self getGameResultNSDataV1];
    } else if( SAVE_VERSION == 2 ){
        return [self getGameResultNSDataV2];
    } else if( SAVE_VERSION == 3 ){
        return [self getGameResultNSDataV3];
    } else if( SAVE_VERSION == 4 ){
        return [self getGameResultNSDataV4];
    } else if( SAVE_VERSION == 5 ){
        return [self getGameResultNSDataV5];
    } else if( SAVE_VERSION == 6 ){
        return [self getGameResultNSDataV6];
    } else if( SAVE_VERSION == 7 ){
        return [self getGameResultNSDataV7];
    } else if( SAVE_VERSION == 8 ){
        return [self getGameResultNSDataV8];
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
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
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

- (NSData*)getGameResultNSDataV3 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V3）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V3,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
    // ３行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin]];
    
//    NSLog(@"string : %@",resultStr);
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

- (NSData*)getGameResultNSDataV4 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V4）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V4,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
    // ３行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin]];
    
    // ５行目以降：メモ
    [resultStr appendString:[NSString stringWithFormat:@"%@",memo]];
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

// V4とV5の処理の違いはバージョン番号のみ（打撃結果の追加対応の識別のため）
- (NSData*)getGameResultNSDataV5 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V5）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V5,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
    // ３行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin]];
    
    // ５行目以降：メモ
    [resultStr appendString:[NSString stringWithFormat:@"%@",memo]];
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

// V6 ３行目にタグを追加
- (NSData*)getGameResultNSDataV6 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V6）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V6,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
    // ３行目：タグ（カンマ区切り）
    [resultStr appendString:[NSString stringWithFormat:@"%@\n",tagtext]];
    
    // ４行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin]];
    
    // ６行目以降：メモ
    [resultStr appendString:[NSString stringWithFormat:@"%@",memo]];
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

// V7 投球数を追加
- (NSData*)getGameResultNSDataV7 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V7）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V7,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal]];
    
    // ３行目：タグ（カンマ区切り）
    [resultStr appendString:[NSString stringWithFormat:@"%@\n",tagtext]];
    
    // ４行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手、投球数）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin,tamakazu]];
    
    // ６行目以降：メモ
    [resultStr appendString:[NSString stringWithFormat:@"%@",memo]];
    
    NSData* data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
    
    return data;
}

// V8 盗塁死、失策、先攻後攻、打順、守備位置１〜３を追加
- (NSData*)getGameResultNSDataV8 {
    NSMutableString* resultStr = [NSMutableString string];
    
    if (UUID == nil || [UUID isEqualToString:@""] || [UUID isEqualToString:@"(null)"]) {
        // UUIDを作成
        CFUUIDRef uuidObj = CFUUIDCreate(nil);
        UUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
        CFRelease(uuidObj);
    }
    
    // １行目：ファイル形式バージョン（V7）、UUID
    [resultStr appendString:[NSString stringWithFormat:@"V8,%@\n",UUID]];
    
    // ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁、盗塁死、失策、先攻後攻、打順、守備位置１、守備位置２、守備位置３）
    [resultStr appendString:[NSString stringWithFormat:
                             @"%d,%d,%d,%d,%@,%@,%@,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,resultid,year,month,day,place,myteam,otherteam,myscore,otherscore
                             ,daten,tokuten,steal,stealOut,error,seme,dajun,shubi1,shubi2,shubi3]];
    
    // ３行目：タグ（カンマ区切り）
    [resultStr appendString:[NSString stringWithFormat:@"%@\n",tagtext]];
    
    // ４行目：打撃成績（場所、結果、場所、結果・・・・）
    for(int i=0;i<battingResultArray.count;i++){
        BattingResult* battingResult = [battingResultArray objectAtIndex:i];
        
        [resultStr appendString:[NSString stringWithFormat:@"%d,%d"
                                 ,battingResult.position,battingResult.result]];
        
        if( i+1 != battingResultArray.count){
            [resultStr appendString:@","];
        }
    }
    [resultStr appendString:@"\n"];
    
    // ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手、投球数）
    [resultStr appendString:[NSString stringWithFormat:@"%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\n"
                             ,inning,inning2,hianda,hihomerun,dassanshin,yoshikyu,yoshikyu2,shitten,jisekiten,kanto,sekinin,tamakazu]];
    
    // ６行目以降：メモ
    [resultStr appendString:[NSString stringWithFormat:@"%@",memo]];
    
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
    
        if([versionStr isEqualToString:@"V2"] == YES){
            // "V2"という文字列ならV2形式
            return [self makeGameResultV2:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V3"] == YES){
            // "V3"という文字列ならV3形式
            return [self makeGameResultV3:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V4"] == YES){
            // "V4"という文字列ならV4形式
            return [self makeGameResultV4:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V5"] == YES){
            // "V5"という文字列ならV5形式
            return [self makeGameResultV5:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V6"] == YES){
            // "V6"という文字列ならV6形式
            return [self makeGameResultV6:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V7"] == YES){
            // "V7"という文字列ならV7形式
            return [self makeGameResultV7:resultStrArray resultUUID:resultUUID];
        } else if([versionStr isEqualToString:@"V8"] == YES){
            // "V7"という文字列ならV7形式
            return [self makeGameResultV8:resultStrArray resultUUID:resultUUID];
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
    // V5以前の形式なので打撃結果をコンバート
    NSString* battingResultStr = [resultStrArray objectAtIndex:1];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:YES];
    
    return gameResult;
}

// V2形式での読み込み
// １行目：ファイル形式バージョン（V2）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：打撃成績（場所、結果、場所、結果・・・・）
+ (GameResult*)makeGameResultV2:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目は打撃成績（打撃成績がないときは空行だが２行目自体は存在する）
    // V5以前の形式なので打撃結果をコンバート
    NSString* battingResultStr = [resultStrArray objectAtIndex:2];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:YES];
    
    return gameResult;
}

// V3形式での読み込み
// １行目：ファイル形式バージョン（V3）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：打撃成績（場所、結果、場所、結果・・・・）
// ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
+ (GameResult*)makeGameResultV3:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目は打撃成績（打撃成績がないときは空行だが３行目自体は存在する）
    // V5以前の形式なので打撃結果をコンバート
    NSString* battingResultStr = [resultStrArray objectAtIndex:2];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:YES];
    
    // ４行目は投手成績（打撃成績がないときは空行だが３行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:3];
    [self setPitchingResult:gameResult pitchingResultStr:pitchingResultStr];
    
    return gameResult;
}

// V4形式での読み込み
// １行目：ファイル形式バージョン（V4）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：打撃成績（場所、結果、場所、結果・・・・）
// ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
// ５行目以降：メモ
+ (GameResult*)makeGameResultV4:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目は打撃成績（打撃成績がないときは空行だが３行目自体は存在する）
    // V5以前の形式なので打撃結果をコンバート
    NSString* battingResultStr = [resultStrArray objectAtIndex:2];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:YES];
    
    // ４行目は投手成績（投手成績がないときは空行だが４行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:3];
    [self setPitchingResult:gameResult pitchingResultStr:pitchingResultStr];
    
    // ５行目以降はメモ（メモがないときは空行だが５行目自体は存在する）
    NSMutableString* memoStr = [NSMutableString string];
    for(int i=4;i<resultStrArray.count;i++){
        [memoStr appendString:@"\n"];
        [memoStr appendString:[resultStrArray objectAtIndex:i]];
    }
    
    gameResult.memo = [memoStr substringFromIndex:1];
    
//    NSLog(@"memo : %@",gameResult.memo);
    
    return gameResult;
}

// V5形式での読み込み（V4形式との処理の違いは打撃結果の追加対応のみ）
// １行目：ファイル形式バージョン（V4）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：打撃成績（場所、結果、場所、結果・・・・）
// ４行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
// ５行目以降：メモ
+ (GameResult*)makeGameResultV5:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目は打撃成績（打撃成績がないときは空行だが３行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:2];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:NO];
    
    // ４行目は投手成績（投手成績がないときは空行だが４行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:3];
    [self setPitchingResult:gameResult pitchingResultStr:pitchingResultStr];
    
    // ５行目以降はメモ（メモがないときは空行だが５行目自体は存在する）
    NSMutableString* memoStr = [NSMutableString string];
    for(int i=4;i<resultStrArray.count;i++){
        [memoStr appendString:@"\n"];
        [memoStr appendString:[resultStrArray objectAtIndex:i]];
    }
    
    gameResult.memo = [memoStr substringFromIndex:1];
    
    //    NSLog(@"memo : %@",gameResult.memo);
    
    return gameResult;
}

// V6形式での読み込み（V5からタグを追加）
// １行目：ファイル形式バージョン（V4）、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：タグ（カンマ区切り）
// ４行目：打撃成績（場所、結果、場所、結果・・・・）
// ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手）
// ６行目以降：メモ
+ (GameResult*)makeGameResultV6:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目はタグ
    gameResult.tagtext = [resultStrArray objectAtIndex:2];
    
    // ４行目は打撃成績（打撃成績がないときは空行だが３行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:3];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:NO];
    
    // ５行目は投手成績（投手成績がないときは空行だが４行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:4];
    [self setPitchingResult:gameResult pitchingResultStr:pitchingResultStr];
    
    // ６行目以降はメモ（メモがないときは空行だが５行目自体は存在する）
    NSMutableString* memoStr = [NSMutableString string];
    for(int i=5;i<resultStrArray.count;i++){
        [memoStr appendString:@"\n"];
        [memoStr appendString:[resultStrArray objectAtIndex:i]];
    }
    
    gameResult.memo = [memoStr substringFromIndex:1];
    
    //    NSLog(@"memo : %@",gameResult.memo);
    
    return gameResult;
}

// V7形式での読み込み（V6から投球数を追加）
// １行目：ファイル形式バージョン、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁）
// ３行目：タグ（カンマ区切り）
// ４行目：打撃成績（場所、結果、場所、結果・・・・）
// ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手、投球数）
// ６行目以降：メモ
+ (GameResult*)makeGameResultV7:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV2:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目はタグ
    gameResult.tagtext = [resultStrArray objectAtIndex:2];
    
    // ４行目は打撃成績（打撃成績がないときは空行だが４行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:3];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:NO];
    
    // ５行目は投手成績（投手成績がないときは空行だが５行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:4];
    [self setPitchingResultV2:gameResult pitchingResultStr:pitchingResultStr];
    
    // ６行目以降はメモ（メモがないときは空行だが６行目自体は存在する）
    NSMutableString* memoStr = [NSMutableString string];
    for(int i=5;i<resultStrArray.count;i++){
        [memoStr appendString:@"\n"];
        [memoStr appendString:[resultStrArray objectAtIndex:i]];
    }
    
    gameResult.memo = [memoStr substringFromIndex:1];
    
    //    NSLog(@"memo : %@",gameResult.memo);
    
    return gameResult;
}

// V8形式での読み込み（V7から盗塁死、失策、先攻後攻、打順、守備位置１〜３を追加）
// １行目：ファイル形式バージョン、UUID
// ２行目：試合情報（ID、年、月、日、場所、自チーム、相手チーム、自チーム得点、相手チーム得点、打点、得点、盗塁、盗塁死、失策、先攻後攻、打順、守備位置１、守備位置２、守備位置３）
// ３行目：タグ（カンマ区切り）
// ４行目：打撃成績（場所、結果、場所、結果・・・・）
// ５行目：投手成績（投球回、投球回小数点以下、安打、本塁打、奪三振、与四球、与死球、失点、自責点、完投、責任投手、投球数）
// ６行目以降：メモ
+ (GameResult*)makeGameResultV8:(NSArray*)resultStrArray resultUUID:(NSString*)resultUUID {
    GameResult* gameResult = [[GameResult alloc] init];
    
    // １行目は読み込み済のためUUIDのみ設定
    gameResult.UUID = resultUUID;
    
    // ２行目は試合情報
    NSString* gameInfoStr = [resultStrArray objectAtIndex:1];
    [self setGameInfoV3:gameResult gameInfoStr:gameInfoStr];
    
    // ３行目はタグ
    gameResult.tagtext = [resultStrArray objectAtIndex:2];
    
    // ４行目は打撃成績（打撃成績がないときは空行だが４行目自体は存在する）
    NSString* battingResultStr = [resultStrArray objectAtIndex:3];
    [self setBattingResult:gameResult battingResultStr:battingResultStr convert:NO];
    
    // ５行目は投手成績（投手成績がないときは空行だが５行目自体は存在する）
    NSString* pitchingResultStr = [resultStrArray objectAtIndex:4];
    [self setPitchingResultV2:gameResult pitchingResultStr:pitchingResultStr];
    
    // ６行目以降はメモ（メモがないときは空行だが６行目自体は存在する）
    NSMutableString* memoStr = [NSMutableString string];
    for(int i=5;i<resultStrArray.count;i++){
        [memoStr appendString:@"\n"];
        [memoStr appendString:[resultStrArray objectAtIndex:i]];
    }
    
    gameResult.memo = [memoStr substringFromIndex:1];
    
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
    gameResult.tokuten = [[gameInfoStrArray objectAtIndex:10] intValue];
    gameResult.steal = [[gameInfoStrArray objectAtIndex:11] intValue];
}

+ (void)setGameInfoV3:(GameResult*)gameResult gameInfoStr:(NSString*)gameInfoStr {
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
    gameResult.tokuten = [[gameInfoStrArray objectAtIndex:10] intValue];
    gameResult.steal = [[gameInfoStrArray objectAtIndex:11] intValue];
    gameResult.stealOut = [[gameInfoStrArray objectAtIndex:12] intValue];
    gameResult.error = [[gameInfoStrArray objectAtIndex:13] intValue];
    gameResult.seme = [[gameInfoStrArray objectAtIndex:14] intValue];
    gameResult.dajun = [[gameInfoStrArray objectAtIndex:15] intValue];
    gameResult.shubi1 = [[gameInfoStrArray objectAtIndex:16] intValue];
    gameResult.shubi2 = [[gameInfoStrArray objectAtIndex:17] intValue];
    gameResult.shubi3 = [[gameInfoStrArray objectAtIndex:18] intValue];
}

+ (void)setBattingResult:(GameResult*)gameResult battingResultStr:(NSString*)battingResultStr convert:(BOOL)convert {
    NSArray* battingResultStrArray = [battingResultStr componentsSeparatedByString:@","];
    for (int i=0; i<battingResultStrArray.count/2; i++) {
        int position = [[battingResultStrArray objectAtIndex:i*2] intValue];
        int result = [[battingResultStrArray objectAtIndex:i*2+1] intValue];
        
        // V4形式以前の場合はresultを修正する（邪飛、野選、振り逃げ追加対応）
        if(convert == YES){
            if (result >= 11) {
                result += 3;
            } else if (result >= 5){
                result += 2;
            } else if (result >= 3){
                result += 1;
            }
        }
        
        BattingResult* battingResult = [BattingResult makeBattingResult:position result:result];
        [gameResult addBattingResult:battingResult];
    }
}

+ (void)setPitchingResult:(GameResult*)gameResult pitchingResultStr:(NSString*)pitchingResultStr {
    NSArray* gameInfoStrArray = [pitchingResultStr componentsSeparatedByString:@","];
    gameResult.inning = [[gameInfoStrArray objectAtIndex:0] intValue];
    gameResult.inning2 = [[gameInfoStrArray objectAtIndex:1] intValue];
    gameResult.hianda = [[gameInfoStrArray objectAtIndex:2] intValue];
    gameResult.hihomerun = [[gameInfoStrArray objectAtIndex:3] intValue];
    gameResult.dassanshin = [[gameInfoStrArray objectAtIndex:4] intValue];
    gameResult.yoshikyu = [[gameInfoStrArray objectAtIndex:5] intValue];
    gameResult.yoshikyu2 = [[gameInfoStrArray objectAtIndex:6] intValue];
    gameResult.shitten = [[gameInfoStrArray objectAtIndex:7] intValue];
    gameResult.jisekiten = [[gameInfoStrArray objectAtIndex:8] intValue];
    gameResult.kanto = [[gameInfoStrArray objectAtIndex:9] boolValue];
    gameResult.sekinin = [[gameInfoStrArray objectAtIndex:10] intValue];
}

+ (void)setPitchingResultV2:(GameResult*)gameResult pitchingResultStr:(NSString*)pitchingResultStr {
    NSArray* gameInfoStrArray = [pitchingResultStr componentsSeparatedByString:@","];
    gameResult.inning = [[gameInfoStrArray objectAtIndex:0] intValue];
    gameResult.inning2 = [[gameInfoStrArray objectAtIndex:1] intValue];
    gameResult.hianda = [[gameInfoStrArray objectAtIndex:2] intValue];
    gameResult.hihomerun = [[gameInfoStrArray objectAtIndex:3] intValue];
    gameResult.dassanshin = [[gameInfoStrArray objectAtIndex:4] intValue];
    gameResult.yoshikyu = [[gameInfoStrArray objectAtIndex:5] intValue];
    gameResult.yoshikyu2 = [[gameInfoStrArray objectAtIndex:6] intValue];
    gameResult.shitten = [[gameInfoStrArray objectAtIndex:7] intValue];
    gameResult.jisekiten = [[gameInfoStrArray objectAtIndex:8] intValue];
    gameResult.kanto = [[gameInfoStrArray objectAtIndex:9] boolValue];
    gameResult.sekinin = [[gameInfoStrArray objectAtIndex:10] intValue];
    gameResult.tamakazu = [[gameInfoStrArray objectAtIndex:11] intValue];
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
    
    // 年月日すべて一緒ならresultidで判断
    if (self.resultid > data.resultid) {
        return NSOrderedAscending;
    } else if (self.resultid < data.resultid) {
        return NSOrderedDescending;
    }
    
    return NSOrderedSame;
}

+ (NSArray*)getInningPickerArray {
    NSArray* array = [NSArray arrayWithObjects:
                      [NSArray arrayWithObjects:@"",@"1回",@"2回",@"3回",@"4回",
                       @"5回",@"6回",@"7回",@"8回",@"9回",@"10回",@"11回",@"12回",nil],
                      [NSArray arrayWithObjects:@"",@"0/3",@"1/3",@"2/3",nil], nil];
    return array;
}

- (NSString*)getInningString {
    return [GameResult getInningString:inning inning2:inning2];
}

- (NSString*)getSekininString {
    return [[GameResult getSekininPickerArray] objectAtIndex:sekinin];
}

- (UIColor*)getSekininColor {
    UIColor* red = [UIColor redColor];
    UIColor* black = [UIColor blackColor];
    
    NSArray* array = [NSArray arrayWithObjects:black,red,black,red,red,nil];
    
    return [array objectAtIndex:sekinin];
}

+ (NSString*)getInningString:(int)inning inning2:(int)inning2 {
    NSArray* array = [GameResult getInningPickerArray];
    return [NSString stringWithFormat:@"%@%@%@",
                     [[array objectAtIndex:0] objectAtIndex:inning],
                     [[array objectAtIndex:1] objectAtIndex:inning2],inning == 0 ? @"回" : @""];
}

+ (NSArray*)getSekininPickerArray {
    NSArray* array = [NSArray arrayWithObjects:@"",@"勝利投手",@"敗戦投手",@"ホールド",@"セーブ",nil];
    return array;
}

+ (NSArray*)getDajunPickerArray {
    NSArray* array = [NSArray arrayWithObjects:@"",@"１番",@"２番",@"３番",@"４番",@"５番",@"６番",@"７番",@"８番",@"９番",@"10番",@"11番",@"12番",@"代打",@"代走",@"守備交代",nil];
    return array;
}

+ (NSArray*)getShortDajunPickerArray {
    NSArray* array = [NSArray arrayWithObjects:@"",@"１番",@"２番",@"３番",@"４番",@"５番",@"６番",@"７番",@"８番",@"９番",@"10番",@"11番",@"12番",@"代打",@"代走",@"守備",nil];
    return array;
}

+ (NSArray*)getShubiPickerArray {
    NSArray* array = [NSArray arrayWithObjects:@"",@"ピッチャー",@"キャッチャー",@"ファースト",@"セカンド",@"サード",@"ショート",@"レフト",@"センター",@"ライト",nil];
    return array;
}

+ (NSArray*)getShortShubiPickerArray {
    NSArray* array = [NSArray arrayWithObjects:@"",@"投手",@"捕手",@"一塁",@"二塁",@"三塁",@"遊撃",@"左翼",@"中堅",@"右翼",nil];
    return array;
}

- (NSString*)getDajunString {
    NSArray* array = [GameResult getDajunPickerArray];
    return [array objectAtIndex:dajun];
}

- (NSString*)getShubiConnectedString {
    NSArray* array = shubi3 == 0 ? [GameResult getShubiPickerArray] : [GameResult getShortShubiPickerArray];
    
    NSMutableString* str = [NSMutableString string];
    if(shubi1 != 0){
        [str appendString:[array objectAtIndex:shubi1]];
    }
    if(shubi2 != 0){
        [str appendFormat:@"→%@", [array objectAtIndex:shubi2]];
    }
    if(shubi3 != 0){
        [str appendFormat:@"→%@", [array objectAtIndex:shubi3]];
    }
    
    return str;
}

- (NSString*)getSemeString {
    NSArray* array = [NSArray arrayWithObjects:@"未設定",@"先攻",@"後攻",nil];
    return [array objectAtIndex:seme];
}

- (NSArray*)getTagList {
    return [tagtext componentsSeparatedByString:@","];
}

+ (NSString*)adjustTagText:(NSString*)sourceString {
    // 読点（、）と全角カンマ（，）を半角カンマに置換
    sourceString = [[sourceString stringByReplacingOccurrencesOfString:@"、" withString:@","]
                    stringByReplacingOccurrencesOfString:@"，" withString:@","];
    
    // タグ形式で再構成（始めのカンマ、終わりのカンマを削除、カンマの連続は１つにする、同じタグは追加しない）
    NSArray* separatedStringArray = [sourceString componentsSeparatedByString:@","];
    
    NSMutableString* returnString = [NSMutableString string];
    NSMutableArray* tagArray = [NSMutableArray array];
    
    for (NSString* str in separatedStringArray){
        if([str isEqualToString:@""] == NO && [tagArray containsObject:str] == NO){
            if([returnString isEqualToString:@""] == NO){
                [returnString appendString:@","];
            }
            [returnString appendString:str];
            [tagArray addObject:str];
        }
    }
    
    return returnString;
}

@end
