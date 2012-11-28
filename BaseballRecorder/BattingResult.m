//
//  BattingResult.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/21.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingResult.h"

@implementation BattingResult

@synthesize position;
@synthesize result;

static NSArray* battingResultTypeArray;

static NSArray* battingStatisticsArray;

+ (NSArray*)getBattingResultTypeArray {
    if(battingResultTypeArray == nil){
        
        NSNumber* byes = [NSNumber numberWithBool:YES];
        NSNumber* bno  = [NSNumber numberWithBool:NO];
        
        battingResultTypeArray = [NSArray arrayWithObjects:
            [NSArray arrayWithObjects:@"",@"ピッチャー",@"キャッチャー",@"ファースト",@"セカンド",
                @"サード",@"ショート",@"レフト",@"センター",@"ライト",@"左中間",@"右中間",nil],
            [NSArray arrayWithObjects:@"",@"ゴロ",@"フライ",@"ライナー",@"エラー",@"ヒット",
                @"二塁打",@"三塁打",@"ホームラン",@"犠打",@"三振",@"四球",@"死球",nil],
            [NSArray arrayWithObjects:
                byes,byes,byes,byes,byes,byes,byes,byes,byes,byes,bno,bno,bno,nil],
            [NSArray arrayWithObjects:@"",@"投",@"捕",@"一",@"二",
                @"三",@"遊",@"左",@"中",@"右",@"左中",@"右中",nil],
            [NSArray arrayWithObjects:@"",@"ゴ",@"飛",@"直",@"失",@"安",
                @"二",@"三",@"本",@"犠",@"三振",@"四球",@"死球",nil],nil];
        
    }
    
    return battingResultTypeArray;
}

+ (NSArray*)getBattingStatisticsCountArray {
    if(battingStatisticsArray == nil){
        NSNumber* n0 = [NSNumber numberWithInt:0];
        NSNumber* n1 = [NSNumber numberWithInt:1];
        
        battingStatisticsArray =[NSArray arrayWithObjects:
            // 打数
            [NSArray arrayWithObjects:n0,n1,n1,n1,n1,n1,n1,n1,n1,n0,n1,n0,n0,nil],
            // 安打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n1,n1,n1,n1,n0,n0,n0,n0,nil],
            // 単打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,n0,nil],
            // 二塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,nil],
            // 三塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,nil],
            // 本塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,nil],
            // 三振
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,nil],
            // 四死球
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n1,nil],
            // 犠打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,nil],
            nil];
    }
    
    return battingStatisticsArray;
}

+ (BattingResult*)makeBattingResult:(int)position result:(int)result {
    NSArray *typeArray = [BattingResult getBattingResultTypeArray];
    
    BOOL needsPosition = [[[typeArray objectAtIndex:2] objectAtIndex:result] boolValue];
    
    if( result == 0 ){
        return nil;
    }
    if( needsPosition == YES && position == 0){
        return nil;
    }
    
    BattingResult* battingResult = [[BattingResult alloc] init];
    battingResult.position = position;
    battingResult.result = result;
    
    if( needsPosition == NO ){
        battingResult.position = 0;
    }
    
    return battingResult;
}

- (NSString*)getResultString {
    NSArray *typeArray = [BattingResult getBattingResultTypeArray];
    NSArray *positionArray = [typeArray objectAtIndex:3];
    NSArray *resultArray = [typeArray objectAtIndex:4];
    
    NSString *positionStr = [positionArray objectAtIndex:position];
    NSString *resultStr = [resultArray objectAtIndex:result];
    
    return [positionStr stringByAppendingString:resultStr];
}

- (int)getStatisticsCounts:(int)type {
    NSArray* statisticsArray = [BattingResult getBattingStatisticsCountArray];
    
    NSArray* statistics = [statisticsArray objectAtIndex:type];
    
    NSNumber* number = [statistics objectAtIndex:result];
    
    return [number intValue];
}

@end
