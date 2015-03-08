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
@synthesize year;
@synthesize month;

- (NSString*)getTermString {
    switch (type) {
        case TERM_TYPE_ALL:
            return @"すべて";
            break;
        case TERM_TYPE_RECENT5:
            return @"最近５試合";
            break;
        case TERM_TYPE_YEAR:
            return [NSString stringWithFormat:@"%d年",year];
            break;
        case TERM_TYPE_MONTH:
            return [NSString stringWithFormat:@"%d年%d月",year,month];
            break;
        default:
            break;
    }
    return @"";
}

- (NSString*)getTermStringForConfig {
    return [NSString stringWithFormat:@"%d,%d,%d",type,year,month];
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
            return gameResult.year == year ? YES : NO;
            break;
        case TERM_TYPE_MONTH:
            return gameResult.year == year && gameResult.month == month ? YES : NO;
            break;
        default:
            break;
    }
    return NO;
}

+ (NSString*)getDefaultTermStringForConfig {
    return [NSString stringWithFormat:@"%d,0,0",TERM_TYPE_ALL];
}

+ (TargetTerm*)makeTargetTerm:(NSString*)string {
    NSArray* strArray = [string componentsSeparatedByString:@","];
    
    TargetTerm* targetTerm = [[TargetTerm alloc] init];
    targetTerm.type = [[strArray objectAtIndex:0] intValue];
    targetTerm.year = [[strArray objectAtIndex:1] intValue];
    targetTerm.month = [[strArray objectAtIndex:2] intValue];
    
    return targetTerm;
}

+ (NSArray*)getTargetTermListForPicker:(NSArray*)gameResultList {
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
            yearTerm.year = gameResult.year;
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
            monthTerm.year = gameResult.year;
            monthTerm.month = gameResult.month;
            [targetTermList addObject:monthTerm];
            
//            [targetTermList addObject:[NSString stringWithFormat:@"%d年%d月", gameResult.year, gameResult.month]];
            tempyear = gameResult.year;
            tempmonth = gameResult.month;
        }
    }
    
    return targetTermList;
}

+ (NSArray*)getTargetTermList:(int)type gameResultList:(NSArray*)gameResultList {
    NSMutableArray* targetTermList = [NSMutableArray array];
    
    switch (type) {
        case TERM_TYPE_ALL:{
            TargetTerm* allTerm = [[TargetTerm alloc] init];
            allTerm.type = TERM_TYPE_ALL;
            [targetTermList addObject:allTerm];
            break;
        }
        case TERM_TYPE_RECENT5:{
            TargetTerm* recent5Term = [[TargetTerm alloc] init];
            recent5Term.type = TERM_TYPE_RECENT5;
            [targetTermList addObject:recent5Term];
            break;
        }
        case TERM_TYPE_YEAR:{
            int tempyear = -999;
            for(GameResult* gameResult in gameResultList){
                if(tempyear != gameResult.year){
                    TargetTerm* yearTerm = [[TargetTerm alloc]init];
                    yearTerm.type = TERM_TYPE_YEAR;
                    yearTerm.year = gameResult.year;
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
                    monthTerm.year = gameResult.year;
                    monthTerm.month = gameResult.month;
                    [targetTermList addObject:monthTerm];
                    tempyear = gameResult.year;
                    tempmonth = gameResult.month;
                }
            }
            break;
        }
        default:
            break;
    }
    
    return targetTermList;
}

@end
