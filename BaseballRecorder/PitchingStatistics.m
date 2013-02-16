//
//  PitchingStatistics.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/15.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingStatistics.h"
#import "GameResult.h"

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
    
    // 防御率＝自責点／投球回数×９
    era = (float)jisekiten / realinning * 9.0f;

    // WHIP＝（被安打＋与四球）／投球回数
    whip = (float)(hianda + yoshikyu) / realinning;

    // 奪三振率＝奪三振／投球回数×９
    k9 = (float)dassanshin / realinning * 9.0f;
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

@end
