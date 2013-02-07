//
//  PitchingResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/05.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingResultController.h"
#import "GameResult.h"

#define PICKER_INNING  1
#define PICKER_SEKININ 2

@interface PitchingResultController ()

@end

@implementation PitchingResultController

@synthesize scrollView;
@synthesize toBattingButton;
@synthesize inningButton;
@synthesize sekininButton;
@synthesize pickerToolbar;
@synthesize selectPicker;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self showPitchingResult];
}

- (void)showPitchingResult {
    
    
    
    
    
    [self showInning];
    [self showSekinin];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGSize size = CGSizeMake(320, 500);
    scrollView.contentSize = size;
    [scrollView setContentOffset:CGPointMake(0.0f, 85.0f) animated:YES];
    
    [self showDoneButton];
    
    [self closeSelectPicker];
    
//    edited = YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [self hiddenDoneButton];
    return YES;
}

- (void)showDoneButton {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStylePlain target:self action:@selector(doneButton)];
    _inputNavi.rightBarButtonItem = btn;
}

- (void)hiddenDoneButton {
    _inputNavi.rightBarButtonItem = toBattingButton;
}

- (void)doneButton {
    [_hianda endEditing:YES];
    [_hihomerun endEditing:YES];
    [_dassanshin endEditing:YES];
    [_yoshikyu endEditing:YES];
    [_yoshikyu2 endEditing:YES];
    [_shitten endEditing:YES];
    [_jisekiten endEditing:YES];
    
    CGSize size = CGSizeMake(320, 280);
    scrollView.contentSize = size;
}

- (IBAction)inputInning:(id)sender {
    if(selectPicker == nil){
        [self makeSelectPicker:PICKER_INNING];
    }
}

- (IBAction)inputResult:(id)sender {
    if(selectPicker == nil){
        [self makeSelectPicker:PICKER_SEKININ];
    }
}

- (void)makeSelectPicker:(int)type {
    // 初めに他の編集項目の編集を終了させる
    [self doneButton];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    selectPicker = [[UIPickerView alloc] init];
    
    selectPicker.center = CGPointMake(width/2, height+125+60);
    selectPicker.delegate = self;
    selectPicker.dataSource = self;
    selectPicker.showsSelectionIndicator = YES;
    selectPicker.tag = type;
    
    // デフォルト値を設定、クリアボタンを表示するか判定
    BOOL clearBtnFlg = false;
    if(type == PICKER_INNING){
        [selectPicker selectRow:_inning inComponent:0 animated:NO];
        [selectPicker selectRow:_inning2 inComponent:1 animated:NO];
        if(_inning != 0 || _inning2 != 0){
            clearBtnFlg = true;
        }
    } else if(type == PICKER_SEKININ){
        [selectPicker selectRow:_sekinin inComponent:0 animated:NO];
        if(_sekinin != 0){
            clearBtnFlg = true;
        }
    }
    
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height, 320, 44)];
    pickerToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarClearButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    if(clearBtnFlg == true){
        items = [NSArray arrayWithObjects:backButton, clearButton, spacer, doneButton, nil];
    } else {
        items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    }
    
    [pickerToolbar setItems:items animated:YES];
    
    [self.view addSubview:pickerToolbar];
    [self.view addSubview:selectPicker];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    selectPicker.center = CGPointMake(width/2, height-125);    // 表示する中心座標を表示画面中央に
    pickerToolbar.center = CGPointMake(width/2, height-255);
    
    [UIView commitAnimations];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    if(pickerView.tag == PICKER_INNING){
        return 2;
    } else {
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView.tag == PICKER_INNING){
        return [[[GameResult getInningPickerArray] objectAtIndex:component] count];
    } else {
        return [[GameResult getSekininPickerArray] count];
    }
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView.tag == PICKER_INNING){
        NSArray* array = [GameResult getInningPickerArray];
        return [[array objectAtIndex:component] objectAtIndex:row];
    } else {
        NSArray* array = [GameResult getSekininPickerArray];
        return [array objectAtIndex:row];
    }
}


- (void)toolbarBackButton:(UIBarButtonItem*)sender {
    [self closeSelectPicker];
}

- (void)toolbarClearButton:(id)sender {
    if(selectPicker.tag == PICKER_INNING){
        _inning  = 0;
        _inning2 = 0;
        [self showInning];
    } else if(selectPicker.tag == PICKER_SEKININ){
        _sekinin = 0;
        [self showSekinin];
    }
    
    [self closeSelectPicker];
}

- (void)toolbarDoneButton:(id)sender {
    if(selectPicker.tag == PICKER_INNING){
        _inning  = [selectPicker selectedRowInComponent:0];
        _inning2 = [selectPicker selectedRowInComponent:1];
        [self showInning];
    } else if(selectPicker.tag == PICKER_SEKININ){
        _sekinin = [selectPicker selectedRowInComponent:0];
        [self showSekinin];
    }
    
    [self closeSelectPicker];
}

- (void)closeSelectPicker {
    [pickerToolbar removeFromSuperview];
    [selectPicker removeFromSuperview];
    
    pickerToolbar = nil;
    selectPicker = nil;
}

- (void)showInning {
    if(_inning == 0 && _inning2 == 0){
        _inningLabel.text = @"";
        [inningButton setTitle:@"入力" forState:UIControlStateNormal];
        [inningButton setTitle:@"入力" forState:UIControlStateHighlighted];
        inningButton.frame = CGRectMake(100,51,60,30);
    } else {
        NSArray* array = [GameResult getInningPickerArray];
        _inningLabel.text = [NSString stringWithFormat:@"%@%@%@",
                             [[array objectAtIndex:0] objectAtIndex:_inning],
                             [[array objectAtIndex:1] objectAtIndex:_inning2],
                             _inning == 0 ? @"回" : @""];
        [inningButton setTitle:@"変更" forState:UIControlStateNormal];
        [inningButton setTitle:@"変更" forState:UIControlStateHighlighted];
        if(_inning == 0 || _inning2 == 0){
            inningButton.frame = CGRectMake(165,51,60,30);
        } else {
            inningButton.frame = CGRectMake(180,51,60,30);
        }
    }
    
}

- (void)showSekinin {
    if(_sekinin == 0){
        _sekininLabel.text = @"";
        [sekininButton setTitle:@"入力" forState:UIControlStateNormal];
        [sekininButton setTitle:@"入力" forState:UIControlStateHighlighted];
        sekininButton.frame = CGRectMake(110,246,60,30);
    } else {
        NSArray* array = [GameResult getSekininPickerArray];
        _sekininLabel.text = [array objectAtIndex:_sekinin];
        [sekininButton setTitle:@"変更" forState:UIControlStateNormal];
        [sekininButton setTitle:@"変更" forState:UIControlStateHighlighted];
        sekininButton.frame = CGRectMake(190,246,60,30);
    }
    
}

- (IBAction)backToBatting:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload {
    [self setHianda:nil];
    [self setHihomerun:nil];
    [self setDassanshin:nil];
    [self setYoshikyu:nil];
    [self setYoshikyu2:nil];
    [self setShitten:nil];
    [self setJisekiten:nil];
    [self setToBattingButton:nil];
    [self setInputNavi:nil];
    [self setInputNavi:nil];
    [self setScrollView:nil];
    [self setInningLabel:nil];
    [self setSekininLabel:nil];
    [self setInningButton:nil];
    [self setSekininButton:nil];
    [super viewDidUnload];
}
@end
