//
//  TeamStatistics.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "TeamStatistics.h"
#import "GameResult.h"

@implementation TeamStatistics

+ (TeamStatistics*)calculateTeamStatistics:(NSArray*)gameResultList {
    TeamStatistics* teamStatistics = [[TeamStatistics alloc] init];
    
    for(int i=0;i<gameResultList.count;i++){
        GameResult* gameResult = [gameResultList objectAtIndex:i];
        if(gameResult.myscore > gameResult.otherscore){
            teamStatistics.win++;
        } else if (gameResult.myscore == gameResult.otherscore){
            teamStatistics.draw++;
        } else {
            teamStatistics.lose++;
        }
        
        
        
        
    }
    
    return teamStatistics;
}

@end
