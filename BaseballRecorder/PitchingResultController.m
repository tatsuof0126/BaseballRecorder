//
//  PitchingResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/05.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingResultController.h"
#import "InputViewController.h"
#import "ShowGameResultController.h"
#import "GameResult.h"
#import "GameResultManager.h"
#import "CheckBoxButton.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "Utility.h"

#define PICKER_INNING  1
#define PICKER_SEKININ 2

#define ALERT_BACK 1
#define ALERT_TO_BATTING 2
#define ALERT_SAVE 3
#define ALERT_SAVE_ONLY_BATTING 4

@interface PitchingResultController ()

@end

@implementation PitchingResultController

@synthesize gadView;
@synthesize scrollView;
@synthesize saveButton;
@synthesize inningButton;
@synthesize changeInningButton;
@synthesize sekininButton;
@synthesize changeSekininButton;
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
    
    [self showPitchingResult];
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:scrollView];
    
    // 広告表示（admob）
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        gadView = [AppDelegate makeGadView:self];
    }
}

- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    // 読み込みに成功したら広告を表示
    gadView.frame = CGRectMake(0, 430, 320, 50);
    [AppDelegate adjustOriginForiPhone5:gadView];
    [self.view addSubview:gadView];
    
    // TableViewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:scrollView];
}

- (void)showPitchingResult {
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    _inning = gameResult.inning;
    _inning2 = gameResult.inning2;
    _hianda.text = [NSString stringWithFormat:@"%d",gameResult.hianda];
    _hihomerun.text = [NSString stringWithFormat:@"%d",gameResult.hihomerun];
    _dassanshin.text = [NSString stringWithFormat:@"%d",gameResult.dassanshin];
    _yoshikyu.text = [NSString stringWithFormat:@"%d",gameResult.yoshikyu];
    _yoshikyu2.text = [NSString stringWithFormat:@"%d",gameResult.yoshikyu2];
    _shitten.text = [NSString stringWithFormat:@"%d",gameResult.shitten];
    _jisekiten.text = [NSString stringWithFormat:@"%d",gameResult.jisekiten];
    _kanto.checkBoxSelected = gameResult.kanto;
    _sekinin = gameResult.sekinin;
    if(gameResult.tamakazu == TAMAKAZU_NONE){
        _tamakazu.text = @"---";
    } else {
        _tamakazu.text = [NSString stringWithFormat:@"%d",gameResult.tamakazu];
    }
    
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
    // 投球数が「---」の場合は入力時に消す
    if(textField == _tamakazu && [textField.text isEqualToString:@"---"]){
        textField.text = @"";
    }
    
    // 投球数以外の数値入力項目で「0」の場合は入力時に消す
    if(textField.tag == 1 && textField != _tamakazu && [textField.text isEqualToString:@"0"]){
        textField.text = @"";
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    scrollView.contentSize = CGSizeMake(320, [UIScreen mainScreen].bounds.size.height+90);
    [scrollView setContentOffset:CGPointMake(0.0f, 85.0f) animated:YES];
    
    [self showDoneButton];
    
    [self closeSelectPicker];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // 投球数が空の場合は「---」を設定
    if(textField == _tamakazu && [textField.text isEqualToString:@""]){
        textField.text = @"---";
    }
    
    // 投球数以外の数値入力項目で空の場合は「0」を設定
    if(textField.tag == 1 && textField != _tamakazu && [textField.text isEqualToString:@""]){
        textField.text = @"0";
    }
    
    [self hiddenDoneButton];
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer*)gestureRecognizer shouldReceiveTouch:(UITouch*)touch {
    if ([touch.view isKindOfClass:[UIControl class]]) {
        return NO;
    }
    return YES;
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
    [self closeSelectPicker];
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
    [_tamakazu endEditing:YES];
    
    scrollView.contentSize = CGSizeMake(320, 280);
}

- (IBAction)inputInning:(id)sender {
    if(selectPicker == nil){
        [self makeSelectPicker:PICKER_INNING];
    }
}

- (IBAction)changeInning:(id)sender {
    if(selectPicker == nil){
        [self makeSelectPicker:PICKER_INNING];
    }
}

- (IBAction)inputResult:(id)sender {
    if(selectPicker == nil){
        [self makeSelectPicker:PICKER_SEKININ];
    }
}

- (IBAction)changeResult:(id)sender {
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
    pickerBaseView.backgroundColor = [UIColor whiteColor];
    
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
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarClearButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarDoneButton:)];
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
        inningButton.hidden = NO;
        changeInningButton.hidden = YES;
    } else {
        _inningLabel.text = [GameResult getInningString:_inning inning2:_inning2];
        inningButton.hidden = YES;
        changeInningButton.hidden = NO;
    }
    
}

- (void)showSekinin {
    if(_sekinin == 0){
        _sekininLabel.text = @"";
        sekininButton.hidden = NO;
        changeSekininButton.hidden = YES;
    } else {
        NSArray* array = [GameResult getSekininPickerArray];
        _sekininLabel.text = [array objectAtIndex:_sekinin];
        sekininButton.hidden = YES;
        changeSekininButton.hidden = NO;
    }
}

/*
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
        [_tamakazu.text isEqualToString:@"---"] == NO ||
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
*/

- (void)backToBattingView {
    [self updateGameResult];
    [self dismissViewControllerAnimated:YES completion:nil];
//    [self dismissModalViewControllerAnimated:YES];
}

- (void)updateGameResult {
    // 入力内容をGameResultオブジェクトに保存
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    gameResult.inning     = _inning;
    gameResult.inning2    = _inning2;
    gameResult.hianda     = [_hianda.text intValue];
    gameResult.hihomerun  = [_hihomerun.text intValue];
    gameResult.dassanshin = [_dassanshin.text intValue];
    gameResult.yoshikyu   = [_yoshikyu.text intValue];
    gameResult.yoshikyu2  = [_yoshikyu2.text intValue];
    gameResult.shitten    = [_shitten.text intValue];
    gameResult.jisekiten  = [_jisekiten.text intValue];
    gameResult.kanto      = [_kanto checkBoxSelected];
    gameResult.sekinin    = _sekinin;
    if([_tamakazu.text isEqualToString:@"---"]){
        gameResult.tamakazu    = TAMAKAZU_NONE;
    } else {
        gameResult.tamakazu    = [_tamakazu.text intValue];
    }
    
    [self showPitchingResult];
    
}

- (void)clearGameResult {
    // GameResultオブジェクトの投手成績部分を初期化
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    GameResult* gameResult = appDelegate.targetGameResult;
    
    gameResult.inning     = 0;
    gameResult.inning2    = 0;
    gameResult.hianda     = 0;
    gameResult.hihomerun  = 0;
    gameResult.dassanshin = 0;
    gameResult.yoshikyu   = 0;
    gameResult.yoshikyu2  = 0;
    gameResult.shitten    = 0;
    gameResult.jisekiten  = 0;
    gameResult.kanto      = NO;
    gameResult.sekinin    = 0;
    gameResult.tamakazu   = TAMAKAZU_NONE;
}

/*
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
                // 入力内容をGameResultオブジェクトに反映
                [self updateGameResult];
                
                AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                // ファイルに保存
                [GameResultManager saveGameResult:appDelegate.targetGameResult];
                
                // インタースティシャル広告表示をセット
                if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
                    appDelegate.showInterstitialFlg = YES;
                }
                
                // 試合結果参照画面へ
                [self moveNextView];
            }
            break;
        case ALERT_SAVE_ONLY_BATTING:
            if(buttonIndex == 1){
                // 投手成績の入力内容をGameResultオブジェクトから削除
                [self clearGameResult];
                
                AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                // ファイルに保存
                [GameResultManager saveGameResult:appDelegate.targetGameResult];
                
                // インタースティシャル広告表示をセット
                if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
                    appDelegate.showInterstitialFlg = YES;
                }
                
                // 試合結果参照画面へ
                [self moveNextView];
            }
            break;
        default:
            break;
    }
}
*/

- (void)saveGameResult {
    // 入力内容をGameResultオブジェクトに反映
    [self updateGameResult];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // ファイルに保存
    [GameResultManager saveGameResult:appDelegate.targetGameResult];
    
    // インタースティシャル広告表示をセット
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        appDelegate.showInterstitialFlg = YES;
    }
    
    // 試合結果参照画面へ
    [self moveNextView];
}

- (void)saveGameResultOnlyBatting {
    // 投手成績の入力内容をGameResultオブジェクトから削除
    [self clearGameResult];
    
    AppDelegate* appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    // ファイルに保存
    [GameResultManager saveGameResult:appDelegate.targetGameResult];
    
    // インタースティシャル広告表示をセット
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        appDelegate.showInterstitialFlg = YES;
    }
    
    // 試合結果参照画面へ
    [self moveNextView];
}

- (void)moveNextView {
    InputViewController* controller = (InputViewController*)self.presentingViewController;
    if(controller.inputtype == INPUT_TYPE_NEW){
        // 試合結果参照画面へ進む
        [self performSegueWithIdentifier:@"registsegue" sender:self];
    } else if(controller.inputtype == INPUT_TYPE_UPDATE){
        // 試合結果参照画面へ戻る
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    NSString* segueStr = [segue identifier];
    if ([segueStr isEqualToString:@"registsegue"] == YES) {
        // とりあえず何もなし
    }
}

- (NSArray*)inputCheck {
    NSMutableArray* errorArray = [NSMutableArray array];
    // 未入力フラグ
    BOOL blankFlg = NO;
    
    if(_hianda.text.length == 0 || _hihomerun.text.length == 0 ||
       _dassanshin.text.length == 0 || _yoshikyu.text.length == 0 || _yoshikyu2.text.length == 0 ||
       _shitten.text.length == 0 || _jisekiten.text.length == 0 || _tamakazu.text.length == 0){
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
    int tamakazu = [_tamakazu.text intValue];
    if((hianda == 0 && [_hianda.text isEqualToString:@"0"] == NO) ||
       (hihomerun == 0 && [_hihomerun.text isEqualToString:@"0"] == NO) ||
       (dassanshin == 0 && [_dassanshin.text isEqualToString:@"0"] == NO) ||
       (yoshikyu == 0 && [_yoshikyu.text isEqualToString:@"0"] == NO) ||
       (yoshikyu2 == 0 && [_yoshikyu2.text isEqualToString:@"0"] == NO) ||
       (shitten == 0 && [_shitten.text isEqualToString:@"0"] == NO) ||
       (jisekiten == 0 && [_jisekiten.text isEqualToString:@"0"] == NO) ||
       (tamakazu == 0 && [_tamakazu.text isEqualToString:@"0"] == NO && [_tamakazu.text isEqualToString:@"---"] == NO)){
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
    [self setTamakazu:nil];
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
        
        [Utility showAlert:@"" message:errorStr buttonText:@"閉じる"];
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:errorStr delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil];
        [alert show];
         */
        
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
        [_tamakazu.text isEqualToString:@"---"] == NO ||
        _kanto.checkBoxSelected == YES ||
        _sekinin != 0)){
        
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction* action) {
                                    // 投手成績を初期化して戻る（入力内容は無視）
                                    [self clearGameResult];
                                    [self dismissViewControllerAnimated:YES completion:nil];
                                   }];
        UIAlertController* alertController = [Utility makeConfirmAlert:@"" message:@"投球回が空のため投手成績の入力内容はクリアされます。\nよろしいですか？" okAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
            /*
           UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                message:@"投球回が空のため投手成績の入力内容はクリアされます。\nよろしいですか？"
                delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
           [alert setTag:ALERT_TO_BATTING];
           [alert show];
             */
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
        
        [Utility showAlert:@"" message:errorStr buttonText:@"閉じる"];
        
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:errorStr delegate:self cancelButtonTitle:@"閉じる" otherButtonTitles:nil];
        [alert show];
         */
        
        return;
    }
    
    // 入力エラーでない場合は保存確認のダイアログを表示
    // UIAlertView* alert = nil;
    if(_inning == 0 && _inning2 == 0 &&
            ([_hianda.text isEqualToString:@"0"] == NO ||
             [_hihomerun.text isEqualToString:@"0"] == NO ||
             [_dassanshin.text isEqualToString:@"0"] == NO ||
             [_yoshikyu.text isEqualToString:@"0"] == NO ||
             [_yoshikyu2.text isEqualToString:@"0"] == NO ||
             [_shitten.text isEqualToString:@"0"] == NO ||
             [_jisekiten.text isEqualToString:@"0"] == NO ||
             [_tamakazu.text isEqualToString:@"---"] == NO ||
             _kanto.checkBoxSelected == YES || _sekinin != 0)){
        // 投球回が０で何らかの入力がある場合は、投手成績の入力内容が消える旨のダイアログを表示
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction* action) {
                                    [self saveGameResultOnlyBatting];
                                   }];
        UIAlertController* alertController = [Utility makeConfirmAlert:@"" message:@"投球回が空のため投手成績の入力内容はクリアされます。\n保存してよろしいですか？" okAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
        
        /*
        alert = [[UIAlertView alloc] initWithTitle:@"試合結果の保存"
            message:@"投球回が空のため投手成績の入力内容はクリアされます。\n保存してよろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_SAVE_ONLY_BATTING];
         */
    } else {
        // 通常の保存確認のダイアログを表示
        UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction* action) {
                                    [self saveGameResult];
                                   }];
        UIAlertController* alertController = [Utility makeConfirmAlert:@"試合結果の保存" message:@"保存してよろしいですか？" okAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];

        /*
        alert = [[UIAlertView alloc] initWithTitle:@"試合結果の保存" message:@"保存してよろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_SAVE];
         */
    }
    // [alert show];
}

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end
