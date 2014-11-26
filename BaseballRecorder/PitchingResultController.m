//
//  PitchingResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/05.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingResultController.h"
#import "InputViewController.h"
#import "GameResult.h"
#import "GameResultManager.h"
#import "CheckBoxButton.h"
#import "Utility.h"
#import "TrackingManager.h"

#define PICKER_INNING  1
#define PICKER_SEKININ 2

#define ALERT_BACK 1
#define ALERT_TO_BATTING 2
#define ALERT_SAVE 3
#define ALERT_SAVE_ONLY_BATTING 4

@interface PitchingResultController ()

@end

@implementation PitchingResultController

@synthesize scrollView;
@synthesize saveButton;
@synthesize inningButton;
@synthesize sekininButton;
@synthesize pickerBaseView;
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
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"投手成績入力画面"];
    
    [self showPitchingResult];
}

- (void)showPitchingResult {
    
    InputViewController* controller = (InputViewController*)self.presentingViewController;
    _inning = controller.gameResult.inning;
    _inning2 = controller.gameResult.inning2;
    _hianda.text = [NSString stringWithFormat:@"%d",controller.gameResult.hianda];
    _hihomerun.text = [NSString stringWithFormat:@"%d",controller.gameResult.hihomerun];
    _dassanshin.text = [NSString stringWithFormat:@"%d",controller.gameResult.dassanshin];
    _yoshikyu.text = [NSString stringWithFormat:@"%d",controller.gameResult.yoshikyu];
    _yoshikyu2.text = [NSString stringWithFormat:@"%d",controller.gameResult.yoshikyu2];
    _shitten.text = [NSString stringWithFormat:@"%d",controller.gameResult.shitten];
    _jisekiten.text = [NSString stringWithFormat:@"%d",controller.gameResult.jisekiten];
    _kanto.checkBoxSelected = controller.gameResult.kanto;
    _sekinin = controller.gameResult.sekinin;
    
    [self showInning];
    [self showSekinin];
    [_kanto setState];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    // 数値入力項目で「0」の場合は入力時に「0」を消す
    if(textField.tag == 1 && [textField.text isEqualToString:@"0"]){
        textField.text = @"";
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    CGSize size = CGSizeMake(320, 500);
    scrollView.contentSize = size;
    [scrollView setContentOffset:CGPointMake(0.0f, 85.0f) animated:YES];
    
    [self showDoneButton];
    
    [self closeSelectPicker];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // 数値入力項目で空の場合は「0」を設定
    if(textField.tag == 1 && [textField.text isEqualToString:@""]){
        textField.text = @"0";
    }
    [self hiddenDoneButton];
    return YES;
}

- (void)showDoneButton {
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStylePlain target:self action:@selector(doneButton)];
    _inputNavi.rightBarButtonItem = btn;
}

- (void)hiddenDoneButton {
    _inputNavi.rightBarButtonItem = saveButton;
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
    
    // PickerViewを乗せるView。アニメーションで出すのでとりあえず画面下に出す。
    pickerBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 250)];
    pickerBaseView.backgroundColor = [UIColor clearColor];
    
    // PickerView
    selectPicker = [[UIPickerView alloc] init];
    selectPicker.center = CGPointMake(width/2, 135);
//    selectPicker.center = CGPointMake(width/2, height+125+60);
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
    
    // ToolBar
    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
//    pickerToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height, 320, 44)];
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
    
    [pickerBaseView addSubview:selectPicker];
    [pickerBaseView addSubview:pickerToolbar];
    
    [self.view addSubview:pickerBaseView];
    
//    [self.view addSubview:pickerToolbar];
//    [self.view addSubview:selectPicker];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
    
//    selectPicker.center = CGPointMake(width/2, height-125);    // 表示する中心座標を表示画面中央に
//    pickerToolbar.center = CGPointMake(width/2, height-255);
    
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
        _inning  = [Utility convert2int:[selectPicker selectedRowInComponent:0]];
        _inning2 = [Utility convert2int:[selectPicker selectedRowInComponent:1]];
        [self showInning];
    } else if(selectPicker.tag == PICKER_SEKININ){
        _sekinin = [Utility convert2int:[selectPicker selectedRowInComponent:0]];
        [self showSekinin];
    }
    
    [self closeSelectPicker];
}

- (void)closeSelectPicker {
    [selectPicker removeFromSuperview];
    [pickerToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    
    pickerBaseView = nil;
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
        _inningLabel.text = [GameResult getInningString:_inning inning2:_inning2];
        [inningButton setTitle:@"変更" forState:UIControlStateNormal];
        [inningButton setTitle:@"変更" forState:UIControlStateHighlighted];
        if(_inning == 0 || _inning2 == 0){
            inningButton.frame = CGRectMake(155,51,60,30);
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
        sekininButton.frame = CGRectMake(100,246,60,30);
    } else {
        NSArray* array = [GameResult getSekininPickerArray];
        _sekininLabel.text = [array objectAtIndex:_sekinin];
        [sekininButton setTitle:@"変更" forState:UIControlStateNormal];
        [sekininButton setTitle:@"変更" forState:UIControlStateHighlighted];
        sekininButton.frame = CGRectMake(180,246,60,30);
    }
    
}

- (IBAction)backToBatting:(id)sender {
    NSArray* errorArray = [self inputCheck];
    
    // 入力エラーがある場合はダイアログを表示して戻らない
    if(errorArray.count >= 1){
        NSMutableString *errorStr = [NSMutableString string];
        for(int i=0;i<errorArray.count;i++){
            [errorStr appendString:[errorArray objectAtIndex:i]];
            if(i != errorArray.count){
                [errorStr appendString:@"\n"];
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:errorStr delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // 投球回が０で何らかの入力がある場合は、入力がクリアされる旨の確認メッセージを表示
    if(_inning == 0 && _inning2 == 0 &&
       ([_hianda.text isEqualToString:@"0"] == NO ||
        [_hihomerun.text isEqualToString:@"0"] == NO ||
        [_dassanshin.text isEqualToString:@"0"] == NO ||
        [_yoshikyu.text isEqualToString:@"0"] == NO ||
        [_yoshikyu2.text isEqualToString:@"0"] == NO ||
        [_shitten.text isEqualToString:@"0"] == NO ||
        [_jisekiten.text isEqualToString:@"0"] == NO ||
        _kanto.checkBoxSelected == YES ||
        _sekinin != 0)){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果入力"
            message:@"投球回が空のため入力内容はクリアされます。よろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_TO_BATTING];
        [alert show];
    } else {
        [self backToBattingView];
    }
}

- (void)backToBattingView {
    [self updateGameResult];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateGameResult {
    // 入力内容をGameResultオブジェクトに保存
    InputViewController* controller = (InputViewController*)self.presentingViewController;
    controller.gameResult.inning     = _inning;
    controller.gameResult.inning2    = _inning2;
    controller.gameResult.hianda     = [_hianda.text intValue];
    controller.gameResult.hihomerun  = [_hihomerun.text intValue];
    controller.gameResult.dassanshin = [_dassanshin.text intValue];
    controller.gameResult.yoshikyu   = [_yoshikyu.text intValue];
    controller.gameResult.yoshikyu2  = [_yoshikyu2.text intValue];
    controller.gameResult.shitten    = [_shitten.text intValue];
    controller.gameResult.jisekiten  = [_jisekiten.text intValue];
    controller.gameResult.kanto      = [_kanto checkBoxSelected];
    controller.gameResult.sekinin    = _sekinin;
}

- (void)clearGameResult {
    // GameResultオブジェクトの投手成績部分を初期化
    InputViewController* controller = (InputViewController*)self.presentingViewController;
    controller.gameResult.inning     = 0;
    controller.gameResult.inning2    = 0;
    controller.gameResult.hianda     = 0;
    controller.gameResult.hihomerun  = 0;
    controller.gameResult.dassanshin = 0;
    controller.gameResult.yoshikyu   = 0;
    controller.gameResult.yoshikyu2  = 0;
    controller.gameResult.shitten    = 0;
    controller.gameResult.jisekiten  = 0;
    controller.gameResult.kanto      = NO;
    controller.gameResult.sekinin    = 0;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ALERT_TO_BATTING:
            if(buttonIndex == 1){
                // 投手成績を初期化して戻る（入力内容は無視）
                [self clearGameResult];
                [self dismissViewControllerAnimated:YES completion:nil];
//                [self dismissModalViewControllerAnimated:YES];
            }
            break;
        case ALERT_SAVE:
            if(buttonIndex == 1){
                [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"投手成績入力画面―保存" value:nil screen:@"投手成績入力画面"];
                
                // 入力内容をGameResultオブジェクトに反映
                [self updateGameResult];
                
                // ファイルに保存
                InputViewController* controller = (InputViewController*)self.presentingViewController;
                [GameResultManager saveGameResult:controller.gameResult];
                
                // 一覧画面に戻る
                self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//                [self.presentingViewController.presentingViewController dismissModalViewControllerAnimated:YES];
            }
            break;
        case ALERT_SAVE_ONLY_BATTING:
            if(buttonIndex == 1){
                // 投手成績の入力内容をGameResultオブジェクトから削除
                [self clearGameResult];
                
                // ファイルに保存
                InputViewController* controller = (InputViewController*)self.presentingViewController;
                [GameResultManager saveGameResult:controller.gameResult];
                
                // 一覧画面に戻る
                self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
//                [self.presentingViewController.presentingViewController dismissModalViewControllerAnimated:YES];
            }
            break;
        default:
            break;
    }
}

- (NSArray*)inputCheck {
    NSMutableArray* errorArray = [NSMutableArray array];
    // 未入力フラグ
    BOOL blankFlg = NO;
    
    if(_hianda.text.length == 0 || _hihomerun.text.length == 0 ||
       _dassanshin.text.length == 0 || _yoshikyu.text.length == 0 || _yoshikyu2.text.length == 0 ||
       _shitten.text.length == 0 || _jisekiten.text.length == 0){
        blankFlg = YES;
    }
    
    // 数字以外が入っていたらエラーにする
    int hianda = [_hianda.text intValue];
    int hihomerun = [_hihomerun.text intValue];
    int dassanshin = [_dassanshin.text intValue];
    int yoshikyu = [_yoshikyu.text intValue];
    int yoshikyu2 = [_yoshikyu2.text intValue];
    int shitten = [_shitten.text intValue];
    int jisekiten = [_jisekiten.text intValue];    
    if((hianda == 0 && [_hianda.text isEqualToString:@"0"] == NO) ||
       (hihomerun == 0 && [_hihomerun.text isEqualToString:@"0"] == NO) ||
       (dassanshin == 0 && [_dassanshin.text isEqualToString:@"0"] == NO) ||
       (yoshikyu == 0 && [_yoshikyu.text isEqualToString:@"0"] == NO) ||
       (yoshikyu2 == 0 && [_yoshikyu2.text isEqualToString:@"0"] == NO) ||
       (shitten == 0 && [_shitten.text isEqualToString:@"0"] == NO) ||
       (jisekiten == 0 && [_jisekiten.text isEqualToString:@"0"] == NO) ){
        [errorArray addObject:@"入力が正しくありません"];
    }
    
    if(blankFlg == YES){
        [errorArray addObject:@"入力されていない項目があります。"];
    }
    
    return errorArray;
}

- (void)viewDidUnload {
    [self setHianda:nil];
    [self setHihomerun:nil];
    [self setDassanshin:nil];
    [self setYoshikyu:nil];
    [self setYoshikyu2:nil];
    [self setShitten:nil];
    [self setJisekiten:nil];
    [self setInputNavi:nil];
    [self setScrollView:nil];
    [self setKanto:nil];
    [self setInningLabel:nil];
    [self setSekininLabel:nil];
    [self setInningButton:nil];
    [self setSekininButton:nil];
    [self setSaveButton:nil];
    [super viewDidUnload];
}

- (IBAction)toBattingButton:(id)sender {
    // 入力中状態を解除
    [self doneButton];
    
    NSArray* errorArray = [self inputCheck];
    
    // 入力エラーがある場合はダイアログを表示して戻らない
    if(errorArray.count >= 1){
        NSMutableString *errorStr = [NSMutableString string];
        for(int i=0;i<errorArray.count;i++){
            [errorStr appendString:[errorArray objectAtIndex:i]];
            if(i != errorArray.count){
                [errorStr appendString:@"\n"];
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:errorStr delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // 投球回が０で何らかの入力がある場合は、入力がクリアされる旨の確認メッセージを表示
    if(_inning == 0 && _inning2 == 0 &&
       ([_hianda.text isEqualToString:@"0"] == NO ||
        [_hihomerun.text isEqualToString:@"0"] == NO ||
        [_dassanshin.text isEqualToString:@"0"] == NO ||
        [_yoshikyu.text isEqualToString:@"0"] == NO ||
        [_yoshikyu2.text isEqualToString:@"0"] == NO ||
        [_shitten.text isEqualToString:@"0"] == NO ||
        [_jisekiten.text isEqualToString:@"0"] == NO ||
        _kanto.checkBoxSelected == YES ||
        _sekinin != 0)){
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                message:@"投球回が空のため投手成績の入力内容はクリアされます。\nよろしいですか？"
                delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
           [alert setTag:ALERT_TO_BATTING];
           [alert show];
       } else {
           [self backToBattingView];
       }
}

- (IBAction)saveButton:(id)sender {
    NSArray* errorArray = [self inputCheck];
    
    // 入力エラーがある場合はダイアログを表示して保存しない
    if(errorArray.count >= 1){
        NSMutableString *errorStr = [NSMutableString string];
        for(int i=0;i<errorArray.count;i++){
            [errorStr appendString:[errorArray objectAtIndex:i]];
            if(i != errorArray.count){
                [errorStr appendString:@"\n"];
            }
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:errorStr delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil];
        [alert show];
        
        return;
    }
    
    // 入力エラーでない場合は保存確認のダイアログを表示
    UIAlertView* alert = nil;
    if(_inning == 0 && _inning2 == 0 &&
            ([_hianda.text isEqualToString:@"0"] == NO ||
             [_hihomerun.text isEqualToString:@"0"] == NO ||
             [_dassanshin.text isEqualToString:@"0"] == NO ||
             [_yoshikyu.text isEqualToString:@"0"] == NO ||
             [_yoshikyu2.text isEqualToString:@"0"] == NO ||
             [_shitten.text isEqualToString:@"0"] == NO ||
             [_jisekiten.text isEqualToString:@"0"] == NO ||
             _kanto.checkBoxSelected == YES || _sekinin != 0)){
        // 投球回が０で何らかの入力がある場合は、投手成績の入力内容が消える旨のダイアログを表示
        alert = [[UIAlertView alloc] initWithTitle:@"試合結果の保存"
            message:@"投球回が空のため投手成績の入力内容はクリアされます。\n保存してよろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_SAVE_ONLY_BATTING];
    } else {
        // 通常の保存確認のダイアログを表示
        alert = [[UIAlertView alloc] initWithTitle:@"試合結果の保存" message:@"保存してよろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_SAVE];
    }
    [alert show];
}

@end
