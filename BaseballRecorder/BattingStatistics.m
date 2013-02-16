//
//  BattingStatistics.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingStatistics.h"
#import "GameResult.h"
#import "BattingResult.h"

@implementation BattingStatistics

@synthesize boxs;
@synthesize atbats;
@synthesize hits;
@synthesize singles;
@synthesize doubles;
@synthesize triples;
@synthesize homeruns;
@synthesize strikeouts;
@synthesize walks;
@synthesize sacrifices;
@synthesize sacrificeflies;

@synthesize average;
@synthesize obp;
@synthesize slg;
@synthesize ops;

+ (BattingStatistics*)calculateBattingStatistics:(NSArray*)gameResultList {
    BattingStatistics* battingStatistics = [[BattingStatistics alloc] init];
    
    for(int i=0;i<gameResultList.count;i++){
        GameResult* gameResult = [gameResultList objectAtIndex:i];
        
        NSArray* battingResultArray = gameResult.battingResultArray;
        for(int j=0;j<battingResultArray.count;j++){
            BattingResult* battingResult = [battingResultArray objectAtIndex:j];
            
            battingStatistics.boxs++;
            battingStatistics.atbats   += [battingResult getStatisticsCounts:S_ATBATS];
            battingStatistics.hits     += [battingResult getStatisticsCounts:S_HITS];
            battingStatistics.singles  += [battingResult getStatisticsCounts:S_SINGLES];
            battingStatistics.doubles  += [battingResult getStatisticsCounts:S_DOUBLES];
            battingStatistics.triples  += [battingResult getStatisticsCounts:S_TRIPLES];
            battingStatistics.homeruns += [battingResult getStatisticsCounts:S_HOMERUNS];
            battingStatistics.strikeouts += [battingResult getStatisticsCounts:S_STRIKEOUTS];
            battingStatistics.walks    += [battingResult getStatisticsCounts:S_WALKS];
            battingStatistics.sacrifices += [battingResult getStatisticsCounts:S_SACRIFICES];
            battingStatistics.sacrificeflies += [battingResult getStatisticsCounts:S_SACRIFICEFLIES];
        }
        
        battingStatistics.daten  += gameResult.daten;
        battingStatistics.tokuten  += gameResult.tokuten;
        battingStatistics.steal  += gameResult.steal;
        
    }
    
    [battingStatistics calculateStatistics];
    
    return battingStatistics;
}

- (void)calculateStatistics {
    // 打率＝安打／打数
    average = (float)hits / (float)atbats;
    
    // 出塁率＝（安打＋四死球）／（打数＋四死球＋犠飛）
    obp = (float)(hits+walks) / (float)(atbats+walks+sacrificeflies);
    
    // 長打率＝（単打＋二塁打×２＋三塁打×３＋本塁打×４）／打数
    slg = (float)(singles+doubles*2+triples*3+homeruns*4) / (float)atbats;
    
    // OPS＝出塁率＋長打率
    ops = obp + slg;
}

@end
