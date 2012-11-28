//
//  TeamStatistics.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TeamStatistics : NSObject

@property int win;
@property int lose;
@property int draw;

+ (TeamStatistics*)calculateTeamStatistics:(NSArray*)gameResultList;

@end
