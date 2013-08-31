//
//  BattingStatistics.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BattingStatistics : NSObject

@property int boxs;
@property int atbats;
@property int hits;
@property int singles;
@property int doubles;
@property int triples;
@property int homeruns;
@property int strikeouts;
@property int walks;
@property int sacrifices;
@property int sacrificeflies;
@property int daten;
@property int tokuten;
@property int steal;

@property float average;
@property float obp;
@property float slg;
@property float ops;

+ (BattingStatistics*)calculateBattingStatistics:(NSArray*)gameResultList;

- (NSString*)getMailBody;

@end
