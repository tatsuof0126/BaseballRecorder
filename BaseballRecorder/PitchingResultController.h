//
//  PitchingResultController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/05.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CheckBoxButton.h"

@interface PitchingResultController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UITextField *hianda;
@property (weak, nonatomic) IBOutlet UITextField *hihomerun;
@property (weak, nonatomic) IBOutlet UITextField *dassanshin;
@property (weak, nonatomic) IBOutlet UITextField *yoshikyu;
@property (weak, nonatomic) IBOutlet UITextField *yoshikyu2;
@property (weak, nonatomic) IBOutlet UITextField *shitten;
@property (weak, nonatomic) IBOutlet UITextField *jisekiten;
@property (weak, nonatomic) IBOutlet CheckBoxButton *kanto;
@property (weak, nonatomic) IBOutlet UITextField *tamakazu;

@property (weak, nonatomic) IBOutlet UILabel *inningLabel;
@property (weak, nonatomic) IBOutlet UILabel *sekininLabel;

@property int inning;
@property int inning2;
@property int sekinin;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *saveButton;

@property (weak, nonatomic) IBOutlet UIButton *inningButton;
@property (strong, nonatomic) IBOutlet UIButton *changeInningButton;

@property (weak, nonatomic) IBOutlet UIButton *sekininButton;
@property (strong, nonatomic) IBOutlet UIButton *changeSekininButton;

@property (strong, nonatomic) UIView *pickerBaseView;
@property (strong, nonatomic) UIToolbar *pickerToolbar;
@property (strong, nonatomic) UIPickerView *selectPicker;

- (IBAction)onTap:(id)sender;

- (IBAction)inputInning:(id)sender;
- (IBAction)changeInning:(id)sender;

- (IBAction)inputResult:(id)sender;
- (IBAction)changeResult:(id)sender;

- (IBAction)toBattingButton:(id)sender;
- (IBAction)saveButton:(id)sender;

@end
