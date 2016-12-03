//
//  InputViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "GameResult.h"
#import "BattingResult.h"
#import "UIPlaceHolderTextView.h"
#import "RectView.h"

#define INPUT_TYPE_NEW 1
#define INPUT_TYPE_UPDATE 2

@interface InputViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UITextField *year;
@property (weak, nonatomic) IBOutlet UITextField *month;
@property (weak, nonatomic) IBOutlet UITextField *day;
@property (weak, nonatomic) IBOutlet UITextField *myteam;
@property (weak, nonatomic) IBOutlet UITextField *otherteam;
@property (strong, nonatomic) IBOutlet UITextField *tagtext;
@property (weak, nonatomic) IBOutlet UITextField *myscore;
@property (weak, nonatomic) IBOutlet UITextField *otherscore;


@property (weak, nonatomic) IBOutlet UITextField *place;
@property (strong, nonatomic) IBOutlet UILabel *placeLabel;
@property (strong, nonatomic) IBOutlet UIButton *placeBtn;

@property (strong, nonatomic) IBOutlet UILabel *semeLabel;
@property (strong, nonatomic) IBOutlet UIButton *semeBtn;
@property (strong, nonatomic) IBOutlet UILabel *dajunShubiLabel;
@property (strong, nonatomic) IBOutlet UIButton *dajunShubiInputBtn;
@property (strong, nonatomic) IBOutlet UILabel *dajunShubi;
@property (strong, nonatomic) IBOutlet UIButton *dajunShubiChangeBtn;

@property int dajun;
@property (strong, nonatomic) NSMutableArray* shubiArray;

@property (strong, nonatomic) IBOutlet UILabel *battingResultLabel;

@property (weak, nonatomic) IBOutlet UILabel *datenLabel;
@property (weak, nonatomic) IBOutlet UITextField *daten;
@property (weak, nonatomic) IBOutlet UILabel *tokutenLabel;
@property (weak, nonatomic) IBOutlet UITextField *tokuten;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *error;
@property (weak, nonatomic) IBOutlet UILabel *stealLabel;
@property (weak, nonatomic) IBOutlet UITextField *steal;
@property (weak, nonatomic) IBOutlet UILabel *stealOutLabel;
@property (weak, nonatomic) IBOutlet UITextField *stealOut;

@property (strong, nonatomic) IBOutlet UILabel *memoLabel;
@property (strong, nonatomic) IBOutlet UIPlaceHolderTextView *memo;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (strong, nonatomic) GameResult *gameResult;

@property (strong, nonatomic) NSMutableArray *battingResultViewArray;

@property (strong, nonatomic) UIView *pickerBaseView;
@property (strong, nonatomic) UIToolbar *resultToolbar;
@property (strong, nonatomic) UIPickerView *resultPicker;
@property (strong, nonatomic) UIPickerView *selectPicker;
@property (strong, nonatomic) RectView *rectView;

@property int inputtype;
@property BOOL edited;
@property BOOL showDetail;

@property (weak, nonatomic) IBOutlet UIButton *toPitchingButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (strong, nonatomic) IBOutlet UIButton *detailBtn;

- (IBAction)onTap:(id)sender;

- (IBAction)detailButton:(id)sender;

- (IBAction)semeButton:(id)sender;
- (IBAction)dajunShubiInputButton:(id)sender;
- (IBAction)dajunShubiChangeButton:(id)sender;
- (IBAction)toPitchingButton:(id)sender;
- (IBAction)saveButton:(id)sender;
- (IBAction)backButton:(id)sender;

@end
