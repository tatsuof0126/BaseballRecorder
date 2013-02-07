//
//  InputViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameResult.h"
#import "BattingResult.h"

@interface InputViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *year;
@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *day;
@property (weak, nonatomic) IBOutlet UITextField *place;
@property (weak, nonatomic) IBOutlet UITextField *myteam;
@property (weak, nonatomic) IBOutlet UITextField *otherteam;
@property (weak, nonatomic) IBOutlet UITextField *myscore;
@property (weak, nonatomic) IBOutlet UITextField *otherscore;

@property (weak, nonatomic) IBOutlet UILabel *datenLabel;
@property (weak, nonatomic) IBOutlet UITextField *daten;
@property (weak, nonatomic) IBOutlet UILabel *tokutenLabel;
@property (weak, nonatomic) IBOutlet UITextField *tokuten;
@property (weak, nonatomic) IBOutlet UILabel *stealLabel;
@property (weak, nonatomic) IBOutlet UITextField *steal;

@property (weak, nonatomic) IBOutlet UIScrollView *scroolview;

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (strong, nonatomic) GameResult *gameResult;

@property (strong, nonatomic) NSMutableArray *battingResultViewArray;

@property (strong, nonatomic) UIToolbar *resultToolbar;
@property (strong, nonatomic) UIPickerView *resultPicker;

@property BOOL edited;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *toPitchingButton;
// @property (weak, nonatomic) IBOutlet UIBarButtonItem *toPitchingButton;

- (IBAction)backButton:(id)sender;
- (IBAction)saveButton:(id)sender;

@end
