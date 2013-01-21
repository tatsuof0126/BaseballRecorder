//
//  BattingStatisticsViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

#define ALL_TARGET 0

@interface BattingStatisticsViewController : UIViewController
    <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *teamresult;
@property (weak, nonatomic) IBOutlet UILabel *battingresult;
@property (weak, nonatomic) IBOutlet UILabel *battingstat;
@property (weak, nonatomic) IBOutlet UILabel *battingresult2;
@property (weak, nonatomic) IBOutlet UILabel *battingresult3;
@property (weak, nonatomic) IBOutlet UILabel *battingresult4;

@property (weak, nonatomic) IBOutlet UILabel *team;

@property (weak, nonatomic) IBOutlet UILabel *year;

@property int targetyear;
@property int targetteam;

@property (strong, nonatomic) UIToolbar *targetToolbar;
@property (strong, nonatomic) UIPickerView *targetPicker;

@property (strong, nonatomic) NSArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *yearList;
@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@property (strong, nonatomic) NSMutableArray *teamList;

- (IBAction)changeButton:(id)sender;

@end
