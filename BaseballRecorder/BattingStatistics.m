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
@synthesize isod;
@synthesize isop;
@synthesize rc27;

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
    
    // IsoD＝出塁率ー打率
    isod = obp - average;
    
    // IsoP＝長打率ー打率
    isop = slg - average;

    // RC27＝https://ja.wikipedia.org/wiki/RC_%28%E9%87%8E%E7%90%83%29
    // 出塁能力A = 安打 + 四球 + 死球 - 盗塁死 - 併殺打
    // 進塁能力B = 塁打 + 0.26 ×（四球 + 死球） + 0.53 ×（犠飛 + 犠打） + 0.64 × 盗塁 - 0.03 × 三振
    // 出塁機会C = 打数 + 四球 + 死球 + 犠飛 + 犠打
    // RC =（A+2.4×C）×（B+3×C）÷(9×C)－0.9×C
    // RC27 = RC÷（打数－安打＋盗塁死＋犠打＋犠飛＋併殺打）×27
    float a = hits + walks; // TODO 盗塁死を併殺打を引く
    float b = (singles+doubles*2+triples*3+homeruns*4) + walks*0.26 + sacrifices*0.53 + steal*0.64 - strikeouts*0.03;
    float c = atbats + walks + sacrifices;
    float rc = (a+2.4*c) * (b+3*c) / (9*c) - 0.9*c;
    rc27 = rc / (float)(atbats - hits + sacrifices) * 27; // TODO 盗塁死を併殺打を加える
    
    /*
    NSLog(@"a : %f", a);
    NSLog(@"b : %f", b);
    NSLog(@"c : %f", c);
    NSLog(@"rc : %f", rc);
    NSLog(@"rc27 : %f", rc27);
    */
    
}

- (NSString*)getMailBody {
    NSMutableString* bodyString = [NSMutableString string];
    
    [bodyString appendString:[NSString stringWithFormat:@"%d打席　%d打数　%d安打\n",boxs, atbats, hits]];
    [bodyString appendString:[NSString stringWithFormat:@"二塁打：%d　三塁打：%d　本塁打：%d\n",doubles, triples, homeruns]];
    [bodyString appendString:[NSString stringWithFormat:@"三振：%d　四死球：%d　犠打：%d\n",strikeouts, walks, sacrifices]];
    [bodyString appendString:[NSString stringWithFormat:@"打点：%d　得点：%d　盗塁：%d\n",daten, tokuten, steal]];
    [bodyString appendString:[NSString stringWithFormat:@"打率：%@　出塁率：%@　長打率：%@\n",
                              [Utility getFloatStr:average appendBlank:NO],
                              [Utility getFloatStr:obp appendBlank:NO],
                              [Utility getFloatStr:slg appendBlank:NO]]];
    [bodyString appendString:[NSString stringWithFormat:@"OPS：%@　IsoD：%@　IsoP：%@　RC27：%@\n",
                              [Utility getFloatStr:ops appendBlank:NO],
                              [Utility getFloatStr:isod appendBlank:NO],
                              [Utility getFloatStr:isop appendBlank:NO],
                              [Utility getFloatStr2:rc27]]];
    
    return bodyString;
}

@end
