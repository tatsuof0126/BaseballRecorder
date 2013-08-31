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
#import "Utility.h"

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
@synthesize daten;
@synthesize tokuten;
@synthesize steal;

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

- (NSString*)getMailBody {
    NSMutableString* bodyString = [NSMutableString string];
    
    [bodyString appendString:[NSString stringWithFormat:@"%d打席　%d打数　%d安打\n",boxs, atbats, hits]];
    [bodyString appendString:[NSString stringWithFormat:@"二塁打：%d　三塁打：%d　本塁打：%d\n",doubles, triples, homeruns]];
    [bodyString appendString:[NSString stringWithFormat:@"三振：%d　四死球：%d　犠打：%d\n",strikeouts, walks, sacrifices]];
    [bodyString appendString:[NSString stringWithFormat:@"打点：%d　得点：%d　盗塁：%d\n",daten, tokuten, steal]];
    [bodyString appendString:[NSString stringWithFormat:@"打率：%@　出塁率：%@　OPS：%@　長打率：%@\n",
                              [Utility getFloatStr:average appendBlank:NO],
                              [Utility getFloatStr:obp appendBlank:NO],
                              [Utility getFloatStr:ops appendBlank:NO],
                              [Utility getFloatStr:slg appendBlank:NO]]];
    
    return bodyString;
}

@end
