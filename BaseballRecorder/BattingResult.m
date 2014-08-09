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

static NSArray* battingPositionStringArray;
static NSArray* battingResultStringArray;
static NSArray* battingResultTypeArray;

static NSArray* battingStatisticsArray;

+ (NSArray*)getBattingPositionStringArray:(int)type {
    if(battingPositionStringArray == nil){
        battingPositionStringArray
            = [NSArray arrayWithObjects:
               // 打撃成績入力Picker用
               [NSArray arrayWithObjects:@"",@"ピッチャー",@"キャッチャー",@"ファースト",@"セカンド",
                @"サード",@"ショート",@"レフト",@"センター",@"ライト",@"左中間",@"右中間",nil],
               // 表示用（短縮）
               [NSArray arrayWithObjects:@"",@"投",@"捕",@"一",@"二",
                @"三",@"遊",@"左",@"中",@"右",@"左中",@"右中",nil],
               // 表示用（正式名称）
               [NSArray arrayWithObjects:@"",@"ピッチャー",@"キャッチャー",@"ファースト",@"セカンド",
                @"サード",@"ショート",@"レフト",@"センター",@"ライト",@"左中間",@"右中間",nil],
               nil];
    }
    
    return [battingPositionStringArray objectAtIndex:type];
}

+ (NSArray*)getBattingResultStringArray:(int)type {
    if(battingResultStringArray == nil){
        battingResultStringArray
            = [NSArray arrayWithObjects:
               // 打撃成績入力Picker用
               [NSArray arrayWithObjects:@"",@"ゴロ",@"フライ",@"ﾌｧｰﾙﾌﾗｲ",@"ライナー",@"エラー",@"ﾌｨﾙﾀﾞｰｽﾁｮｲｽ",
                @"ヒット",@"二塁打",@"三塁打",@"ホームラン",@"犠打",@"三振",@"振り逃げ",@"四球",@"死球",@"打撃妨害",nil],
               // 表示用（短縮）
               [NSArray arrayWithObjects:@"",@"ゴ",@"飛",@"邪飛",@"直",@"失",@"野選",@"安",
                @"二",@"三",@"本",@"犠",@"三振",@"振逃",@"四球",@"死球",@"打妨",nil],
               // 表示用（やや短縮）
               [NSArray arrayWithObjects:@"",@"ゴロ",@"フライ",@"邪フライ",@"ライナー",@"エラー",@"野選",
                @"ヒット",@"二塁打",@"三塁打",@"ホームラン",@"犠打",@"三振",@"振り逃げ",@"四球",@"死球",@"打撃妨害",nil],
               // 表示用（正式名称）
               [NSArray arrayWithObjects:@"",@"ゴロ",@"フライ",@"ファールフライ",@"ライナー",@"エラー",@"フィルダースチョイス",
                @"ヒット",@"二塁打",@"三塁打",@"ホームラン",@"犠打",@"三振",@"振り逃げ",@"四球",@"死球",@"打撃妨害",nil],
               nil];
    }
    
    return [battingResultStringArray objectAtIndex:type];
}

+ (NSArray*)getBattingResultTypeArray2:(int)type {
    if(battingResultTypeArray == nil){
        NSNumber* byes = [NSNumber numberWithBool:YES];
        NSNumber* bno  = [NSNumber numberWithBool:NO];
        
        UIColor* black = [UIColor blackColor];
        UIColor* blue = [UIColor blueColor];
        UIColor* red = [UIColor redColor];
        UIColor* dgray = [UIColor darkGrayColor];
        UIColor* gray = [UIColor grayColor];
        
        battingResultTypeArray
            = [NSArray arrayWithObjects:
               // ポジションが必須か
               [NSArray arrayWithObjects:
                byes,byes,byes,byes,byes,byes,byes,byes,byes,byes,byes,byes,bno,bno,bno,bno,bno,nil],
               // 試合結果参照画面での表示色
               [NSArray arrayWithObjects:
                black,black,black,black,black,black,black,red,red,red,red,blue,black,black,blue,blue,black,nil],
               // 打撃分析画面での線の色
               [NSArray arrayWithObjects:
                dgray,dgray,dgray,dgray,dgray,dgray,dgray,blue,red,red,red,dgray,dgray,dgray,dgray,dgray,dgray,nil],
               // 試合結果一覧画面での表示色
               [NSArray arrayWithObjects:
                gray,gray,gray,gray,gray,gray,gray,red,red,red,red,blue,gray,gray,blue,blue,gray,nil],
               nil];
    }
    
    return [battingResultTypeArray objectAtIndex:type];
}

+ (NSArray*)getBattingStatisticsCountArray {
    if(battingStatisticsArray == nil){
        NSNumber* n0 = [NSNumber numberWithInt:0];
        NSNumber* n1 = [NSNumber numberWithInt:1];
        
        battingStatisticsArray =[NSArray arrayWithObjects:
            // 打数
            [NSArray arrayWithObjects:n0,n1,n1,n1,n1,n1,n1,n1,n1,n1,n1,n0,n1,n1,n0,n0,n0,nil],
            // 安打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n1,n1,n1,n1,n0,n0,n0,n0,n0,n0,nil],
            // 単打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,n0,n0,n0,nil],
            // 二塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,n0,n0,nil],
            // 三塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,n0,nil],
            // 本塁打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,n0,nil],
            // 三振
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n1,n0,n0,n0,nil],
            // 四死球
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n1,n0,nil],
            // 犠打
            [NSArray arrayWithObjects:n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n0,n1,n0,n0,n0,n0,n0,nil],
            nil];
    }
    
    return battingStatisticsArray;
}

+ (BattingResult*)makeBattingResult:(int)position result:(int)result {
    NSArray *needPositionArray = [BattingResult getBattingResultTypeArray2:R_TYPE_NEEDP];
    BOOL needsPosition = [[needPositionArray objectAtIndex:result] boolValue];
    
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

- (NSString*)getResultShortString {
    NSArray *positionArray = [BattingResult getBattingPositionStringArray:P_STR_SHORT];
    NSArray *resultArray = [BattingResult getBattingResultStringArray:R_STR_SHORT];
    
    NSString *positionStr = [positionArray objectAtIndex:position];
    NSString *resultStr = [resultArray objectAtIndex:result];
    
    return [positionStr stringByAppendingString:resultStr];
}

- (NSString*)getResultSemiLongString {
    NSArray *positionArray = [BattingResult getBattingPositionStringArray:P_STR_LONG];
    NSArray *resultArray = [BattingResult getBattingResultStringArray:R_STR_SEMILONG];
    
    NSString *positionStr = [positionArray objectAtIndex:position];
    NSString *resultStr = [resultArray objectAtIndex:result];
    
    return [positionStr stringByAppendingString:resultStr];
}

- (NSString*)getResultLongString {
    NSArray *positionArray = [BattingResult getBattingPositionStringArray:P_STR_LONG];
    NSArray *resultArray = [BattingResult getBattingResultStringArray:R_STR_LONG];
    
    NSString *positionStr = [positionArray objectAtIndex:position];
    NSString *resultStr = [resultArray objectAtIndex:result];
    
    return [positionStr stringByAppendingString:resultStr];
}

- (UIColor*)getResultColor {
    NSArray *colorArray = [BattingResult getBattingResultTypeArray2:R_TYPE_COLOR];
    return [colorArray objectAtIndex:result];
}

- (UIColor*)getResultColorForAnalysisView {
    NSArray *colorArray = [BattingResult getBattingResultTypeArray2:R_TYPE_COLOR2];
    return [colorArray objectAtIndex:result];
}

- (UIColor*)getResultColorForListView {
    NSArray *colorArray = [BattingResult getBattingResultTypeArray2:R_TYPE_COLOR3];
    return [colorArray objectAtIndex:result];
}

- (int)getStatisticsCounts:(int)type {
    if ( type != S_SACRIFICEFLIES ){
        // 犠飛以外
        NSArray* statisticsArray = [BattingResult getBattingStatisticsCountArray];
        NSArray* statistics = [statisticsArray objectAtIndex:type];
        NSNumber* number = [statistics objectAtIndex:result];
        return [number intValue];
    } else {
        // 犠飛だけ飛んだ方向を判断する
        // 犠打のうち、飛んだ方向がレフト・センター・ライト・左中間・右中間の場合は犠飛として返す
        if (result == 11 &&
            (position == 7 || position == 8 || position == 9 || position == 10 || position == 11)){
            return 1;
        }
        
        return 0;
    }
}

@end
