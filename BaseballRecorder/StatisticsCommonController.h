//
//  StatisticsCommonController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/14.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALL_TARGET 0

#define BATTING_RESULT  1
#define PITCHING_RESULT 2

@interface StatisticsCommonController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource>

@property int targetyear;
@property int targetteam;

@property (strong, nonatomic) UIToolbar *targetToolbar;
@property (strong, nonatomic) UIPickerView *targetPicker;

@property (strong, nonatomic) NSArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *yearList;
@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@property (strong, nonatomic) NSMutableArray *teamList;

- (NSArray*)getGameResultListForCalc;

- (void)updateStatistics;

- (void)makeResultPicker;

- (void)showTarget:(UILabel*)year team:(UILabel*)team;

- (NSString*)getMailTitle:(int)type;

@end
