//
//  PitchingStatistics.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/15.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingStatistics.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "Utility.h"

@implementation PitchingStatistics

@synthesize games;
@synthesize win;
@synthesize lose;
@synthesize save;
@synthesize hold;
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

@synthesize era;
@synthesize whip;
@synthesize k9;
@synthesize kbb;
@synthesize fip;

+ (PitchingStatistics*)calculatePitchingStatistics:(NSArray*)gameResultList {
    PitchingStatistics* pitchingStatistics = [[PitchingStatistics alloc] init];
    
    for(int i=0;i<gameResultList.count;i++){
        GameResult* gameResult = [gameResultList objectAtIndex:i];
        
        if(gameResult.inning != 0 || gameResult.inning2 != 0){
            pitchingStatistics.games++;
        }
        
        switch (gameResult.sekinin) {
            case 1:
                pitchingStatistics.win++;
                break;
            case 2:
                pitchingStatistics.lose++;
                break;
            case 3:
                pitchingStatistics.hold++;
                break;
            case 4:
                pitchingStatistics.save++;
                break;
            default:
                break;
        }
        
        pitchingStatistics.inning += gameResult.inning;
        switch (gameResult.inning2) {
            case 2: // 1/3
                pitchingStatistics.inning2++;
                break;
            case 3: // 2/3
                pitchingStatistics.inning2+=2;
                break;
            default:
                break;
        }
        
        pitchingStatistics.hianda     += gameResult.hianda;
        pitchingStatistics.hihomerun  += gameResult.hihomerun;
        pitchingStatistics.dassanshin += gameResult.dassanshin;
        pitchingStatistics.yoshikyu   += gameResult.yoshikyu;
        pitchingStatistics.yoshikyu2  += gameResult.yoshikyu2;
        pitchingStatistics.shitten    += gameResult.shitten;
        pitchingStatistics.jisekiten  += gameResult.jisekiten;
        
        if(gameResult.kanto == YES){
            pitchingStatistics.kanto++;
        }
    }
    
    pitchingStatistics.inning += (int)(pitchingStatistics.inning2 / 3);
    pitchingStatistics.inning2 = pitchingStatistics.inning2 % 3;
    
    [pitchingStatistics calculateStatistics];
    
    return pitchingStatistics;
}

- (void)calculateStatistics {
    float realinning = (float)(inning*3 + inning2) / 3.0f;
    
    // 設定ファイルから９回で計算するか７回で計算するかを取得
    float gameinning = 0.0f;
    if( [ConfigManager isCalcInning7Flg] == YES){
        gameinning = 7.0f;
    } else {
        gameinning = 9.0f;
    }

    // 防御率＝自責点／投球回数×９or７
    era = (float)jisekiten / realinning * gameinning;
    
    // WHIP＝（被安打＋与四球）／投球回数
    whip = (float)(hianda + yoshikyu) / realinning;

    // 奪三振率＝奪三振／投球回数×９or７
    k9 = (float)dassanshin / realinning * gameinning;
    
    // K/BB＝奪三振／与四球
    kbb = (float)dassanshin / yoshikyu;
    
    // FIP=（被本塁打×13＋四死球（敬遠除く）×3−奪三振×2）÷イニング数+3.12（リーグ定数）
    fip = (float)(hihomerun*13+(yoshikyu+yoshikyu2)*3-dassanshin*2) / realinning + 3.12f;
}

- (NSString*)getInningString {
    NSArray* array = [NSArray arrayWithObjects:@"",@"1/3",@"2/3",nil];
    if(inning != 0){
        return [NSString stringWithFormat:@"%d回%@", inning, [array objectAtIndex:inning2]];
    } else if(inning2 != 0){
        return [NSString stringWithFormat:@"%@回", [array objectAtIndex:inning2]];
    } else {
        return @"0回";
    }
}
 
- (NSString*)getMailBody {
    NSMutableString* bodyString = [NSMutableString string];
    
    [bodyString appendString:[NSString stringWithFormat:@"%d試合 %d勝 %d敗 %dセーブ %dホールド\n",games,win,lose,save,hold]];
    [bodyString appendString:[NSString stringWithFormat:@"防御率：%@　勝率：%@\n",
                              [Utility getFloatStr2:era],
                              [Utility getFloatStr:(float)(win) / (float)(win+lose) appendBlank:NO]]];
    [bodyString appendString:[NSString stringWithFormat:@"投球回：%@　",[self getInningString]]];
    [bodyString appendString:[NSString stringWithFormat:@"被安打：%d　被本塁打：%d\n",hianda, hihomerun]];
    [bodyString appendString:[NSString stringWithFormat:@"奪三振：%d　与四球：%d　与死球：%d\n",dassanshin, yoshikyu, yoshikyu2]];
    [bodyString appendString:[NSString stringWithFormat:@"失点：%d　自責点：%d　完投：%d\n",shitten, jisekiten, kanto]];
    [bodyString appendString:[NSString stringWithFormat:@"WHIP：%@　奪三振率：%@　K/BB：%@　FIP：%@\n",
                              [Utility getFloatStr2:whip],[Utility getFloatStr2:k9],
                              [Utility getFloatStr2:kbb],[Utility getFloatStr2:fip]]];
    
    return bodyString;
}

@end
