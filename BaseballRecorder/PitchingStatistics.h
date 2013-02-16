//
//  PitchingStatistics.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/15.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PitchingStatistics : NSObject

@property int games;
@property int win;
@property int lose;
@property int save;
@property int hold;
@property int inning;
@property int inning2;
@property int hianda;
@property int hihomerun;
@property int dassanshin;
@property int yoshikyu;
@property int yoshikyu2;
@property int shitten;
@property int jisekiten;
@property int kanto;

@property float era;
@property float whip;
@property float k9;

+ (PitchingStatistics*)calculatePitchingStatistics:(NSArray*)gameResultList;

- (NSString*)getInningString;

@end
