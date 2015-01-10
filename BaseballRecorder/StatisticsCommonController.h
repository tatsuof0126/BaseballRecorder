//
//  StatisticsCommonController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/14.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import "NADView.h"

#define ALL_TARGET 0
#define RECENT5_TARGET 1

#define BATTING_RESULT  1
#define PITCHING_RESULT 2

#define SHARE_TYPE_TEXT 0
#define SHARE_TYPE_IMAGE 1

#define POST_TWITTER 1
#define POST_FACEBOOK 2

@interface StatisticsCommonController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource, UIActionSheetDelegate, NADViewDelegate>

@property (nonatomic, retain) NADView* nadView;

@property int targetyear;
@property int targetteam;

@property (strong, nonatomic) UIView *pickerBaseView;
@property (strong, nonatomic) UIToolbar *targetToolbar;
@property (strong, nonatomic) UIPickerView *targetPicker;

@property (strong, nonatomic) NSArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *yearList;
@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@property (strong, nonatomic) NSMutableArray *teamList;

@property BOOL posted;

- (NSArray*)getGameResultListForCalc;

- (void)updateStatistics;

- (void)makeResultPicker;

- (void)showTarget:(UILabel*)year team:(UILabel*)team;

//- (void)shareStatistics;

- (void)shareStatistics:(int)shareType;

// - (NSString*)makeShareString:(int)type;

- (NSString*)getMailTitle:(int)type;

@end
