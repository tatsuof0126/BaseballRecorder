//
//  TargetTerm.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/03/03.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import "TargetTerm.h"
#import "GameResult.h"

@implementation TargetTerm

@synthesize type;
@synthesize beginyear;
@synthesize beginmonth;
@synthesize endyear;
@synthesize endmonth;

- (NSString*)getTermStringForView {
    switch (type) {
        case TERM_TYPE_ALL:
            return @"すべて";
            break;
        case TERM_TYPE_RECENT5:
            return @"最近５試合";
            break;
        case TERM_TYPE_YEAR:
            return [NSString stringWithFormat:@"%d年",beginyear];
            break;
        case TERM_TYPE_MONTH:
            return [NSString stringWithFormat:@"%d年%d月",beginyear,beginmonth];
            break;
        case TERM_TYPE_RANGE_YEAR:
            if(beginyear == 0){
                return [NSString stringWithFormat:@"〜 %d年",endyear];
            } else if(endyear == 0){
                return [NSString stringWithFormat:@"%d年 〜",beginyear];
            } else {
                return [NSString stringWithFormat:@"%d年 〜 %d年",beginyear,endyear];
            }
            break;
        case TERM_TYPE_RANGE_MONTH:
            if(beginyear == 0){
                return [NSString stringWithFormat:@"〜 %d年%d月",endyear,endmonth];
            } else if(endyear == 0){
                return [NSString stringWithFormat:@"%d年%d月 〜",beginyear,beginmonth];
            } else {
                return [NSString stringWithFormat:@"%d年%d月 〜 %d年%d月",beginyear,beginmonth,endyear,endmonth];
            }
            break;
        default:
            break;
    }
    return @"";
}

- (NSString*)getTermStringForShare {
    switch (type) {
        case TERM_TYPE_ALL:
            return @"";
            break;
        case TERM_TYPE_RECENT5:
            return @"最近５試合";
            break;
        case TERM_TYPE_YEAR:
            return [NSString stringWithFormat:@"%d年",beginyear];
            break;
        case TERM_TYPE_MONTH:
            return [NSString stringWithFormat:@"%d年%d月",beginyear,beginmonth];
            break;
        case TERM_TYPE_RANGE_YEAR:
            if(beginyear == 0){
                return [NSString stringWithFormat:@"%d年まで",endyear];
            } else if(endyear == 0){
                return [NSString stringWithFormat:@"%d年から",beginyear];
            } else {
                return [NSString stringWithFormat:@"%d年〜%d年",beginyear,endyear];
            }
            break;
        case TERM_TYPE_RANGE_MONTH:
            if(beginyear == 0){
                return [NSString stringWithFormat:@"%d年%d月まで",endyear,endmonth];
            } else if(endyear == 0){
                return [NSString stringWithFormat:@"%d年%d月から",beginyear,beginmonth];
            } else {
                if(beginyear == endyear){
                    return [NSString stringWithFormat:@"%d年%d月〜%d月",beginyear,beginmonth,endmonth];
                } else {
                    return [NSString stringWithFormat:@"%d年%d月〜%d年%d月",beginyear,beginmonth,endyear,endmonth];
                }
            }
            break;
        default:
            break;
    }
    return @"";
}

- (NSString*)getTermStringForConfig {
    return [NSString stringWithFormat:@"%d,%d,%d,%d,%d",type,beginyear,beginmonth,endyear,endmonth];
}

- (BOOL)isInTargetTeam:(GameResult*)gameResult {
    switch (type) {
        case TERM_TYPE_ALL:
            return YES;
            break;
        case TERM_TYPE_RECENT5:
            // 最近５試合の判定はしない
            return YES;
            break;
        case TERM_TYPE_YEAR:
            return gameResult.year == beginyear ? YES : NO;
            break;
        case TERM_TYPE_MONTH:
            return gameResult.year == beginyear && gameResult.month == beginmonth ? YES : NO;
            break;
        case TERM_TYPE_RANGE_YEAR:
            if(beginyear == 0){
                return gameResult.year <= endyear ? YES : NO;
            } else if(endyear == 0){
                return gameResult.year >= beginyear ? YES : NO;
            } else {
                return gameResult.year >= beginyear && gameResult.year <= endyear ? YES : NO;
            }
            break;
        case TERM_TYPE_RANGE_MONTH:
            if(beginyear == 0){
                if(gameResult.year < endyear ||
                    (gameResult.year == endyear && gameResult.month <= endmonth)){
                    return YES;
                } else {
                    return NO;
                }
            } else if(endyear == 0){
                if(gameResult.year > beginyear ||
                    (gameResult.year == beginyear && gameResult.month >= beginmonth)){
                    return YES;
                } else {
                    return NO;
                }
            } else {
                if((gameResult.year > beginyear ||
                    (gameResult.year == beginyear && gameResult.month >= beginmonth)) &&
                   (gameResult.year < endyear ||
                    (gameResult.year == endyear && gameResult.month <= endmonth))){
                    return YES;
                } else {
                    return NO;
                }
            }
            break;
        default:
            break;
    }
    return NO;
}

+ (NSString*)getDefaultTermStringForConfig {
    return [NSString stringWithFormat:@"%d,0,0,0,0",TERM_TYPE_ALL];
}

+ (TargetTerm*)makeTargetTerm:(NSString*)string {
    NSArray* strArray = [string componentsSeparatedByString:@","];
    
    TargetTerm* targetTerm = [[TargetTerm alloc] init];
    targetTerm.type = [[strArray objectAtIndex:0] intValue];
    targetTerm.beginyear = [[strArray objectAtIndex:1] intValue];
    targetTerm.beginmonth = [[strArray objectAtIndex:2] intValue];
    
    if(strArray.count >= 4){
        targetTerm.endyear = [[strArray objectAtIndex:3] intValue];
        targetTerm.endmonth = [[strArray objectAtIndex:4] intValue];
    }
    
    return targetTerm;
}

/*
+ (NSArray*)getTargetTermListForPicker2:(NSArray*)gameResultList {
    NSMutableArray* targetTermList = [NSMutableArray array];
    
    // 固定分
    TargetTerm* allTerm = [[TargetTerm alloc] init];
    allTerm.type = TERM_TYPE_ALL;
    [targetTermList addObject:allTerm];
    
    TargetTerm* recent5Term = [[TargetTerm alloc] init];
    recent5Term.type = TERM_TYPE_RECENT5;
    [targetTermList addObject:recent5Term];
    
//    [targetTermList addObject:@"すべて"];
//    [targetTermList addObject:@"最近５試合"];
    
    // 変動分（年別）
    int tempyear = -999;
    for(GameResult* gameResult in gameResultList){
        if(tempyear != gameResult.year){
            TargetTerm* yearTerm = [[TargetTerm alloc]init];
            yearTerm.type = TERM_TYPE_YEAR;
            yearTerm.beginyear = gameResult.year;
            [targetTermList addObject:yearTerm];
            
//            [targetTermList addObject:[NSString stringWithFormat:@"%d年", gameResult.year]];
            tempyear = gameResult.year;
        }
    }

    // 変動分（月別）
    tempyear = -999;
    int tempmonth = -999;
    for(GameResult* gameResult in gameResultList){
        if(tempyear != gameResult.year || tempmonth != gameResult.month){
            TargetTerm* monthTerm = [[TargetTerm alloc]init];
            monthTerm.type = TERM_TYPE_MONTH;
            monthTerm.beginyear = gameResult.year;
            monthTerm.beginmonth = gameResult.month;
            [targetTermList addObject:monthTerm];
            
            tempyear = gameResult.year;
            tempmonth = gameResult.month;
        }
    }
    
    return targetTermList;
}
*/

+ (NSArray*)getActiveTermList:(int)type gameResultList:(NSArray*)gameResultList {
    NSMutableArray* targetTermList = [NSMutableArray array];
    
    // 各分析画面での左右の矢印を出す判定にのみ利用するのでTERM_TYPE_YEARとTERM_TYPE_MONTHのみ計算
    switch (type) {
        case TERM_TYPE_ALL:
            break;
        case TERM_TYPE_RECENT5:
            break;
        case TERM_TYPE_YEAR:{
            int tempyear = -999;
            for(GameResult* gameResult in gameResultList){
                if(tempyear != gameResult.year){
                    TargetTerm* yearTerm = [[TargetTerm alloc]init];
                    yearTerm.type = TERM_TYPE_YEAR;
                    yearTerm.beginyear = gameResult.year;
                    [targetTermList addObject:yearTerm];
                    tempyear = gameResult.year;
                }
            }
            break;
        }
        case TERM_TYPE_MONTH:{
            int tempyear = -999;
            int tempmonth = -999;
            for(GameResult* gameResult in gameResultList){
                if(tempyear != gameResult.year || tempmonth != gameResult.month){
                    TargetTerm* monthTerm = [[TargetTerm alloc]init];
                    monthTerm.type = TERM_TYPE_MONTH;
                    monthTerm.beginyear = gameResult.year;
                    monthTerm.beginmonth = gameResult.month;
                    [targetTermList addObject:monthTerm];
                    tempyear = gameResult.year;
                    tempmonth = gameResult.month;
                }
            }
            break;
        }
        case TERM_TYPE_RANGE_YEAR:
            break;
        case TERM_TYPE_RANGE_MONTH:
            break;
        default:
            break;
    }
    
    return targetTermList;
}

@end
