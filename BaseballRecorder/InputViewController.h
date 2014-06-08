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
#import "UIPlaceHolderTextView.h"
#import "RectView.h"

@interface InputViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (weak, nonatomic) IBOutlet UITextField *year;
@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *day;
@property (weak, nonatomic) IBOutlet UITextField *place;
@property (weak, nonatomic) IBOutlet UITextField *myteam;
@property (weak, nonatomic) IBOutlet UITextField *otherteam;
@property (strong, nonatomic) IBOutlet UITextField *tagtext;
@property (weak, nonatomic) IBOutlet UITextField *myscore;
@property (weak, nonatomic) IBOutlet UITextField *otherscore;

@property (weak, nonatomic) IBOutlet UILabel *datenLabel;
@property (weak, nonatomic) IBOutlet UITextField *daten;
@property (weak, nonatomic) IBOutlet UILabel *tokutenLabel;
@property (weak, nonatomic) IBOutlet UITextField *tokuten;
@property (weak, nonatomic) IBOutlet UILabel *stealLabel;
@property (weak, nonatomic) IBOutlet UITextField *steal;

@property (strong, nonatomic) IBOutlet UILabel *memoLabel;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *memo;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (strong, nonatomic) GameResult *gameResult;

@property (strong, nonatomic) NSMutableArray *battingResultViewArray;

@property (strong, nonatomic) UIView *pickerBaseView;
@property (strong, nonatomic) UIToolbar *resultToolbar;
@property (strong, nonatomic) UIPickerView *resultPicker;
@property (strong, nonatomic) RectView *rectView;

@property BOOL edited;

@property (weak, nonatomic) IBOutlet UIButton *toPitchingButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

- (IBAction)toPitchingButton:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)backButton:(id)sender;

@end
