//
//  TargetTerm.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/03/03.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameResult.h"

@interface TargetTerm : NSObject

#define TERM_TYPE_ALL       1
#define TERM_TYPE_RECENT5   2
#define TERM_TYPE_YEAR      3
#define TERM_TYPE_MONTH     4
#define TERM_TYPE_RANGE_YEAR  5
#define TERM_TYPE_RANGE_MONTH 6

@property int type;
@property int beginyear;
@property int beginmonth;
@property int endyear;
@property int endmonth;

- (NSString*)getTermString;

- (NSString*)getTermStringForConfig;

- (BOOL)isInTargetTeam:(GameResult*)gameResult;

+ (NSString*)getDefaultTermStringForConfig;

+ (TargetTerm*)makeTargetTerm:(NSString*)string;

+ (NSArray*)getTargetTermListForPicker:(NSArray*)gameResultList;

+ (NSArray*)getTargetTermList:(int)type gameResultList:(NSArray*)gameResultList;

@end
