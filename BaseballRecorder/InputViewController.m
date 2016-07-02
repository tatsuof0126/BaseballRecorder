//
//  InputViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "InputViewController.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "ConfigManager.h"
#import "GameResultManager.h"
#import "ShowGameResultController.h"
#import "ResultPickerViewController.h"
#import "SelectInputViewController.h"
#import "TrackingManager.h"

#define NEW_INPUT 999
#define ALERT_BACK 1
#define ALERT_SAVE 2

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize adg = adg_;
@synthesize gameResult;
@synthesize battingResultViewArray;
@synthesize scrollView;
@synthesize pickerBaseView;
@synthesize resultPicker;
@synthesize resultToolbar;
@synthesize rectView;
@synthesize inputtype;
@synthesize edited;
@synthesize toPitchingButton;
@synthesize saveButton;

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
    [TrackingManager sendScreenTracking:@"打撃成績入力画面"];
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //    int resultid = appDelegate.targatResultid;
    
    gameResult = appDelegate.targetGameResult;

    if(gameResult == nil){
        gameResult = [[GameResult alloc] init];
        appDelegate.targetGameResult = gameResult;
        
        // 日付を今日に初期設定
//        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDate *date = [NSDate date];
        NSDateComponents *dateComps
        = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
        
        gameResult.year = [Utility convert2int:dateComps.year];
        gameResult.month = [Utility convert2int:dateComps.month];
        gameResult.day = [Utility convert2int:dateComps.day];
        
        // 場所・チームにデフォルト値を設定
        NSString* defaultPlace = [ConfigManager getDefaultPlace];
        NSString* defaultMyteam = [ConfigManager getDefaultMyTeam];
        
        if(defaultPlace == nil){
            defaultPlace = @"";
        }
        if(defaultMyteam == nil){
            defaultMyteam = @"";
        }
        
        // 場所やチームが１種類しか登録がない場合はそれをデフォルトにする
        if([defaultPlace isEqualToString:@""] || [defaultMyteam isEqualToString:@""]){
            NSMutableArray* placeArray = [NSMutableArray array];
            NSMutableArray* teamArray = [NSMutableArray array];
        
            NSArray* gameResultList = [GameResultManager loadGameResultList];
            for (GameResult* result in gameResultList){
                if([placeArray containsObject:result.place] == NO){
                    [placeArray addObject:result.place];
                }
                if([teamArray containsObject:result.myteam] == NO){
                    [teamArray addObject:result.myteam];
                }
            }
            
            if([defaultPlace isEqualToString:@""] && placeArray.count == 1){
                defaultPlace = [placeArray objectAtIndex:0];
            }
            if([defaultMyteam isEqualToString:@""] && teamArray.count == 1){
                defaultMyteam = [teamArray objectAtIndex:0];
            }
        }
        
        gameResult.place = defaultPlace;
        gameResult.myteam = defaultMyteam;
    }
    
    // 初期値をセット
    _year.text = [NSString stringWithFormat:@"%d",gameResult.year];
    _month.text = [NSString stringWithFormat:@"%d",gameResult.month];
    _day.text = [NSString stringWithFormat:@"%d",gameResult.day];
    
    _place.text = gameResult.place;
    _myteam.text = gameResult.myteam;
    _otherteam.text = gameResult.otherteam;
    _tagtext.text = gameResult.tagtext;
    _myscore.text = [NSString stringWithFormat:@"%d",gameResult.myscore];
    _otherscore.text = [NSString stringWithFormat:@"%d",gameResult.otherscore];
    
    _daten.text = [NSString stringWithFormat:@"%d",gameResult.daten];
    _tokuten.text = [NSString stringWithFormat:@"%d",gameResult.tokuten];
    _steal.text = [NSString stringWithFormat:@"%d",gameResult.steal];
    
    _memo.text = gameResult.memo;
    _memo.placeholder = @"打順や守備位置、サヨナラ勝ちなど　試合のメモが入力できます";
    
    // TextViewを整形
    _memo.font = [UIFont systemFontOfSize:14];
    _memo.layer.borderWidth = 1;
    _memo.layer.borderColor = [[UIColor grayColor] CGColor];
	_memo.layer.cornerRadius = 8;
    [self adjustMemoHeight];

    // 打撃成績の部分を作る
    [self makeBattingResult];
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 416);
    [AppDelegate adjustForiPhone5:scrollView];
    
    // 広告を表示
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        NSDictionary *adgparam = @{@"locationid" : @"21680", @"adtype" : @(kADG_AdType_Sp),
                                   @"originx" : @(0), @"originy" : @(630), @"w" : @(320), @"h" : @(50)};
        ADGManagerViewController *adgvc
            = [[ADGManagerViewController alloc] initWithAdParams:adgparam adView:self.view];
        self.adg = adgvc;
        adg_.delegate = self;
        [adg_ loadRequest];
    }
    
    edited = NO;
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    // 読み込みに成功したら広告を見える場所に移動
    self.adg.view.frame = CGRectMake(0, 430, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    
    // Scrollviewの大きさ定義＆iPhone5対応
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:scrollView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
//    NSLog(@"y : %f", scroolview.contentOffset.y);
    
    if ((textField == _daten || textField == _tokuten || textField == _error ||
         textField == _steal || textField == _stealOut) &&
        scrollView.contentOffset.y < 215.0f+gameResult.battingResultArray.count*40){
        [scrollView setContentOffset:CGPointMake(0.0f, 215.0f+gameResult.battingResultArray.count*40) animated:YES];
    }
    
    if ((textField == _myscore || textField == _otherscore) &&
        scrollView.contentOffset.y < 60.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 60.0f) animated:YES];
    }
    
    [self showDoneButton];
    
    // ResultPickerを閉じる
    [self closeResultPicker];
    
    edited = YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    // 数値入力項目で「0」の場合は入力時に「0」を消す
    if(textField.tag == 1 && [textField.text isEqualToString:@"0"]){
        textField.text = @"";
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    // 数値入力項目で空の場合は「0」を設定
    if(textField.tag == 1 && [textField.text isEqualToString:@""]){
        textField.text = @"0";
    }
    
    // タグ欄の場合はカンマを調整
    if(textField == _tagtext){
        _tagtext.text = [GameResult adjustTagText:_tagtext.text];
    }
    
    [self hiddenDoneButton];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
//    NSLog(@"y : %f", scrollView.contentOffset.y);
    
    if (textView == _memo &&
        scrollView.contentOffset.y < 385.0f+gameResult.battingResultArray.count*40){
        [scrollView setContentOffset:CGPointMake(0.0f, 385.0f+gameResult.battingResultArray.count*40) animated:YES];
    }
    
    [self showDoneButton];
    
    // ResultPickerを閉じる
    [self closeResultPicker];
    
    edited = YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [self hiddenDoneButton];
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView {
    [self adjustMemoHeight];
    
    // コンテンツの配置を調整（投手成績へボタンとScrollViewの高さ）
    [self adjustContentFrame];
}

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
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
    [self endTextEdit];
}

- (void)endTextEdit {
    [_year endEditing:YES];
    [_month endEditing:YES];
    [_day endEditing:YES];
    [_place endEditing:YES];
    [_myteam endEditing:YES];
    [_otherteam endEditing:YES];
    [_tagtext endEditing:YES];
    [_myscore endEditing:YES];
    [_otherscore endEditing:YES];
    [_daten endEditing:YES];
    [_tokuten endEditing:YES];
    [_error endEditing:YES];
    [_steal endEditing:YES];
    [_stealOut endEditing:YES];
    [_memo endEditing:YES];
}

- (void)makeBattingResult {
    // 表示しているViewを一度削除
    for (int i=0; i<battingResultViewArray.count; i++) {
        NSDictionary *dic = [battingResultViewArray objectAtIndex:i];
        
        NSArray *uiViewArray = [dic allValues];
        for (int j=0; j<uiViewArray.count; j++) {
            UIView *uiView = [uiViewArray objectAtIndex:j];
            [uiView removeFromSuperview];
        }
    }
    
    battingResultViewArray = [NSMutableArray array];
    
    // 打撃結果表示用のViewを作って配置（第◯打席、打撃結果、変更ボタン）
    NSArray *battingResultArray = gameResult.battingResultArray;
    
    for (int i=0; i<battingResultArray.count; i++) {
        BattingResult *battingResult = [battingResultArray objectAtIndex:i];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,265+i*40,80,21)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        
        UILabel *resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(110,265+i*40,160,21)];
        resultlabel.text = [battingResult getResultShortString];
        resultlabel.textColor = [battingResult getResultColor];
        
        UIButton *changebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        changebutton.frame = CGRectMake(210,260+i*40,55,30);
        [changebutton setTitle:@"変更" forState:UIControlStateNormal];
        [changebutton setTag:i];
        [changebutton addTarget:self action:@selector(changeResult:) forControlEvents:UIControlEventTouchDown];
        
        NSMutableDictionary *mdic = [NSMutableDictionary dictionary];
        [mdic setObject:titlelabel forKey:@"title"];
        [mdic setObject:resultlabel forKey:@"result"];
        [mdic setObject:changebutton forKey:@"changebutton"];
        
        [battingResultViewArray addObject:mdic];
        
        [scrollView addSubview:titlelabel];
        [scrollView addSubview:resultlabel];
        [scrollView addSubview:changebutton];
    }
    
    // 一番下に入力用の打撃成績（第◯打席、入力ボタン）
    UILabel *nlabel = [[UILabel alloc] initWithFrame:CGRectMake(30,265+battingResultArray.count*40,80,21)];
    nlabel.text = [NSString stringWithFormat:@"第%zd打席",battingResultArray.count+1];
    
    UIButton *nbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nbutton.frame = CGRectMake(110,260+battingResultArray.count*40,55,30);
    [nbutton setTitle:@"入力" forState:UIControlStateNormal];
    [nbutton addTarget:self action:@selector(inputResult:) forControlEvents:UIControlEventTouchDown];
    nbutton.tag = NEW_INPUT;
    
    NSMutableDictionary *nmdic = [NSMutableDictionary dictionary];
    [nmdic setObject:nlabel forKey:@"title"];
    [nmdic setObject:nbutton forKey:@"inputbutton"];
    
    [battingResultViewArray addObject:nmdic];
    
    [scrollView addSubview:nlabel];
    [scrollView addSubview:nbutton];
    
    [self adjustContentFrame];
}

- (void)adjustContentFrame {
    // 打点・得点・盗塁入力欄とメモ欄・投手成績へボタンの配置を調整
    // タグを隠す対応で350→310、410→370に修正
    int battingAdjust = 310+[Utility convert2int:gameResult.battingResultArray.count]*40;
    int memoAdjust = _memo.frame.size.height;
    
    [self setFrameOriginY:_datenLabel originY:battingAdjust+4];
    [self setFrameOriginY:_daten originY:battingAdjust];
    [self setFrameOriginY:_tokutenLabel originY:battingAdjust+4];
    [self setFrameOriginY:_tokuten originY:battingAdjust];
    [self setFrameOriginY:_errorLabel originY:battingAdjust+4];
    [self setFrameOriginY:_error originY:battingAdjust];
    [self setFrameOriginY:_stealLabel originY:battingAdjust+44];
    [self setFrameOriginY:_steal originY:battingAdjust+40];
    [self setFrameOriginY:_stealOutLabel originY:battingAdjust+44];
    [self setFrameOriginY:_stealOut originY:battingAdjust+40];
    [self setFrameOriginY:_memoLabel originY:battingAdjust+85];
    [self setFrameOriginY:_memo originY:battingAdjust+115];
    [self setFrameOriginY:toPitchingButton originY:battingAdjust+memoAdjust+135];
    
    // ScrollViewの長さを調整
    CGSize size = CGSizeMake(320, battingAdjust+memoAdjust+450);
    scrollView.contentSize = size;
}

- (void)setFrameOriginY:(UIView*)view originY:(int)originY {
    view.frame = CGRectMake(view.frame.origin.x, originY, view.frame.size.width, view.frame.size.height);
}

- (void)adjustMemoHeight {
    // 入力内容の高さに合わせてTextViewの高さを変える（最低は90.0f）
    CGRect f = _memo.frame;
    f.size.height = _memo.contentSize.height > 90.0f ? _memo.contentSize.height : 90.0f;
    _memo.frame = f;
}

- (void)inputResult:(UIButton*)button{
    if(resultPicker == nil){
        [self makeResultPicker:NEW_INPUT animated:YES];
        edited = YES;
    } else if(resultPicker.tag != NEW_INPUT){
        [self closeResultPicker];
        [self makeResultPicker:NEW_INPUT animated:NO];
    }
}

- (void)changeResult:(UIButton*)button{
    if(resultPicker == nil){
        [self makeResultPicker:button.tag animated:YES];
        edited = YES;
    } else if(resultPicker.tag != button.tag){
        [self closeResultPicker];
        [self makeResultPicker:button.tag animated:NO];
    }
}

- (void)makeResultPicker:(NSInteger)resultno animated:(BOOL)animated {
    [self doneButton]; // 初めに他の編集項目の編集を終了させる
    
    // スクロール位置を設定
    NSInteger count = 0;
    if(resultno == NEW_INPUT){
        count = gameResult.battingResultArray.count;
    } else {
        count = resultno;
    }
    
    // タグを隠す対応で、250→210
    [scrollView setContentOffset:CGPointMake(0.0f, 210.0f+count*40) animated:YES];
    
    // 入力対象の打撃結果を赤線で囲う
    // タグを隠す対応で、295→255
    rectView = [[RectView alloc] initWithFrame:CGRectMake(20, 255+count*40, 280, 40)];
    [scrollView addSubview:rectView];
    
    // ResultPickerを作る
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    // PickerViewを乗せるView。アニメーションで出すのでとりあえず画面下に出す。
    pickerBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 250)];
    pickerBaseView.backgroundColor = [UIColor clearColor];
    
    // PickerView
    resultPicker = [[UIPickerView alloc] init];
    resultPicker.center = CGPointMake(width/2, 135);
    resultPicker.backgroundColor = [UIColor whiteColor];
    resultPicker.delegate = self;  // デリゲートを自分自身に設定
    resultPicker.dataSource = self;  // データソースを自分自身に設定
    resultPicker.showsSelectionIndicator = YES;
    resultPicker.tag = resultno;
    
    if(resultno != NEW_INPUT){
        BattingResult *battingResult = [gameResult getBattingResult:resultno];
        [resultPicker selectRow:battingResult.position inComponent:0 animated:NO];
        [resultPicker selectRow:battingResult.result inComponent:1 animated:NO];
    }
    
    // Toolbar（既存の成績の編集の場合のみクリアボタンを出す）
    resultToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    resultToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" 閉じる "
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarClearButton:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"決定して次へ"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarNextButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"  決定  "
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [clearButton setTag:resultno];
    [nextButton setTag:resultno];
    [doneButton setTag:resultno];
    
    NSArray *items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    if(resultno == NEW_INPUT){
        items = [NSArray arrayWithObjects:backButton, spacer, nextButton, doneButton, nil];
    } else {
        items = [NSArray arrayWithObjects:backButton, clearButton, spacer, doneButton, nil];
    }
    
    [resultToolbar setItems:items animated:YES];
    
    [pickerBaseView addSubview:resultPicker];
    [pickerBaseView addSubview:resultToolbar];
    
    [self.view addSubview:pickerBaseView];
    
    if(animated == YES){
        //アニメーションの設定開始
        CGContextRef context = UIGraphicsGetCurrentContext();
        [UIView beginAnimations:nil context:context];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
        [UIView setAnimationDuration:0.3];    // 時間の指定
        pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
        [UIView commitAnimations];
    } else {
        pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0){
        return [[BattingResult getBattingPositionStringArray:P_STR_PICKER] count];
    } else {
        return [[BattingResult getBattingResultStringArray:R_STR_PICKER] count];
    }
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{    
    if (component == 0){
        return [[BattingResult getBattingPositionStringArray:P_STR_PICKER] objectAtIndex:row];
    } else {
        return [[BattingResult getBattingResultStringArray:R_STR_PICKER] objectAtIndex:row];
    }
}

- (void)toolbarBackButton:(UIBarButtonItem*)sender {
    [self closeResultPicker];
}

- (void)toolbarClearButton:(id)sender {
    int resultno = [Utility convert2int:[sender tag]];
    
    [gameResult removeBattingResult:resultno];
    
    [self closeResultPicker];
    
    [self makeBattingResult];
}

- (void)toolbarNextButton:(id)sender {
    int resultno = [Utility convert2int:[sender tag]];
    
    int position = [Utility convert2int:[resultPicker selectedRowInComponent:0]];
    int result = [Utility convert2int:[resultPicker selectedRowInComponent:1]];
    
    BattingResult *battingResult = [BattingResult makeBattingResult:position result:result];
    
    if(battingResult != nil){
        if(resultno == NEW_INPUT){
            [gameResult addBattingResult:battingResult];
        } else {
            [gameResult replaceBattingResult:battingResult resultno:resultno];
        }
        [self closeResultPicker];
        
        [self makeBattingResult];
        
        [self makeResultPicker:NEW_INPUT animated:NO];
    }
}

- (void)toolbarDoneButton:(id)sender {
    int resultno = [Utility convert2int:[sender tag]];
    
    int position = [Utility convert2int:[resultPicker selectedRowInComponent:0]];
    int result = [Utility convert2int:[resultPicker selectedRowInComponent:1]];
    
    BattingResult *battingResult = [BattingResult makeBattingResult:position result:result];
    
    if(battingResult != nil){
        if(resultno == NEW_INPUT){
            [gameResult addBattingResult:battingResult];
        } else {
            [gameResult replaceBattingResult:battingResult resultno:resultno];
        }
        
        [self closeResultPicker];
        
        [self makeBattingResult];
    }
}

- (void)closeResultPicker {
    [resultPicker removeFromSuperview];
    [resultToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    [rectView removeFromSuperview];

    pickerBaseView = nil;
    resultPicker = nil;
    resultToolbar = nil;
    rectView = nil;
}

- (IBAction)backButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃成績入力画面―戻る" value:nil screen:@"打撃成績入力画面"];
    
    if(edited == YES){
        // 入力・編集していたら警告ダイアログを出す
        NSString* messageStr = nil;
        if(gameResult.resultid == 0){
            messageStr = @"入力内容は保存されませんが、\nよろしいですか？";
        } else {
            messageStr = @"編集内容は保存されませんが、\nよろしいですか？";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
            message:messageStr delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_BACK];
        [alert show];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
//        [self dismissModalViewControllerAnimated:YES];
    }
}

- (IBAction)commentButton:(id)sender {
    // 投手成績へボタンの配置を調整
    [self setFrameOriginY:_memo originY:_memo.frame.origin.y+120];
    [self setFrameOriginY:toPitchingButton originY:toPitchingButton.frame.origin.y+120];
    
    // ScrollViewの長さを調整
    CGSize size = CGSizeMake(320, scrollView.frame.size.height+120);
    scrollView.contentSize = size;
}

- (IBAction)toPitchingButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃成績入力画面―投手成績へ" value:nil screen:@"打撃成績入力画面"];
    
    // 入力中状態を解除
    [self endTextEdit];
    [self closeResultPicker];
    
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
    
    // GameResultオブジェクトに入力内容を反映
    [self updateGameResult];
    
    // 投手成績入力画面に画面遷移
    [self performSegueWithIdentifier:@"toPitching" sender:self];
}

- (IBAction)saveButton:(id)sender {
//    NSLog(@"y : %f", scrollView.contentOffset.y);
    
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
    
    // 入力エラーがない場合は保存確認のダイアログを表示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果の保存" message:@"保存してよろしいですか？"
                              delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [alert setTag:ALERT_SAVE];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case ALERT_BACK:
            if(buttonIndex == 1){
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            break;
            
        case ALERT_SAVE:
            if(buttonIndex == 1){
                // 入力内容をオブジェクトに反映
                [self updateGameResult];
                
                if(gameResult.resultid == 0){
                    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃成績入力画面―保存（新規）" value:nil screen:@"打撃成績入力画面"];
                } else {
                    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃成績入力画面―保存（更新）" value:nil screen:@"打撃成績入力画面"];
                }
                
                // ファイルに保存
                [GameResultManager saveGameResult:gameResult];
                
                // インタースティシャル広告表示をセット
                if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
                    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
                    appDelegate.showInterstitialFlg = YES;
                }
                
                [self moveNextView];
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
    
    if(_year.text.length == 0 || _month.text.length == 0 || _day.text.length == 0){
        blankFlg = YES;
    } else {
        // 日付チェック
        NSDate* date = [self getDate:_year.text month:_month.text day:_day.text];
        if(date == NULL){
            [errorArray addObject:@"日付が正しくありません。"];
        }
    }
    
    if(_place.text.length == 0){
        blankFlg = YES;
    }
    
    if(_myteam.text.length == 0){
        blankFlg = YES;
    }
    
    if(_otherteam.text.length == 0){
        blankFlg = YES;
    }
    
    if(_myscore.text.length == 0 || _otherscore.text.length == 0 ||
       _daten.text.length == 0 || _tokuten.text.length == 0 ||
        _error.text.length == 0 || _steal.text.length == 0 || _stealOut.text.length == 0){
        blankFlg = YES;
    } else {
        // 数字以外が入っていたらエラーにする
        int myscore = [_myscore.text intValue];
        int otherscore = [_otherscore.text intValue];
        int daten = [_daten.text intValue];
        int tokuten = [_tokuten.text intValue];
        int error = [_error.text intValue];
        int steal = [_steal.text intValue];
        int stealOut = [_stealOut.text intValue];
        
        if((myscore == 0 && [_myscore.text isEqualToString:@"0"] == NO) ||
           (otherscore == 0 && [_otherscore.text isEqualToString:@"0"] == NO)){
            [errorArray addObject:@"試合結果が正しくありません"];
        }
        
        if((daten == 0 && [_daten.text isEqualToString:@"0"] == NO) ||
           (tokuten == 0 && [_tokuten.text isEqualToString:@"0"] == NO) ||
           (error == 0 && [_error.text isEqualToString:@"0"] == NO) ||
           (steal == 0 && [_steal.text isEqualToString:@"0"] == NO) ||
           (stealOut == 0 && [_stealOut.text isEqualToString:@"0"] == NO)){
            [errorArray addObject:@"打撃成績が正しくありません"];
        }
        
    }
    
    if(blankFlg == YES){
        [errorArray addObject:@"入力されていない項目があります。"];
    }    
    
    return errorArray;
}

- (void)updateGameResult {
    // 日付は一度カレンダーに変換してから取得する。
    NSDate* date = [self getDate:_year.text month:_month.text day:_day.text];
    
    // 日時をカレンダーで年月日に分解する
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps
        = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    
    gameResult.year = [Utility convert2int:dateComps.year];
    gameResult.month = [Utility convert2int:dateComps.month];
    gameResult.day = [Utility convert2int:dateComps.day];
    
    gameResult.place = [self escapeString:_place.text];
    gameResult.myteam = [self escapeString:_myteam.text];
    gameResult.otherteam = [self escapeString:_otherteam.text];
    gameResult.tagtext = _tagtext.text;
    gameResult.myscore = [_myscore.text intValue];
    gameResult.otherscore = [_otherscore.text intValue];
    
    gameResult.daten = [_daten.text intValue];
    gameResult.tokuten = [_tokuten.text intValue];
    gameResult.steal = [_steal.text intValue];
    
    // 末尾の空白・改行はカット
    gameResult.memo = [[self escapeString:_memo.text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    
    
    
    // ★テストコード★
//    gameResult.tagtext = gameResult.memo;
    
    
    
}

- (NSString*)escapeString:(NSString*)sourceString {
    // カンマをピリオドに置換
    return [sourceString stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

- (void)moveNextView {
    if(inputtype == INPUT_TYPE_NEW){
        // 試合結果参照画面へ進む
        [self performSegueWithIdentifier:@"registsegue" sender:self];
    } else if(inputtype == INPUT_TYPE_UPDATE){
        // 試合結果参照画面へ戻る
//        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    NSString* segueStr = [segue identifier];
    
    NSString* labelStr = [NSString stringWithFormat:@"打撃成績入力画面―%@",segueStr];
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:labelStr value:nil screen:@"打撃成績入力画面"];
    
    if ([segueStr isEqualToString:@"registsegue"] == YES) {
        // とりあえず何もなし
    } else if ([segueStr isEqualToString:@"place"] == YES) {
        SelectInputViewController* controller = [segue destinationViewController];
        controller.selecttype = PLACE;
        controller.targetField = _place;
    } else if ([segueStr isEqualToString:@"myteam"] == YES) {
        SelectInputViewController* controller = [segue destinationViewController];
        controller.selecttype = MYTEAM;
        controller.targetField = _myteam;
    } else if ([segueStr isEqualToString:@"otherteam"] == YES) {
        SelectInputViewController* controller = [segue destinationViewController];
        controller.selecttype = OTHERTEAM;
        controller.targetField = _otherteam;
    } else if ([segueStr isEqualToString:@"tagtext"] == YES) {
        SelectInputViewController* controller = [segue destinationViewController];
        _tagtext.text = [GameResult adjustTagText:_tagtext.text];
        controller.selecttype = TAGTEXT;
        controller.targetField = _tagtext;
    }
    
    edited = YES;
}

-(NSDate*)getDate:(NSString*)year month:(NSString*)month day:(NSString*)day {
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ 00:00", year, month, day];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [formatter setLocale:[NSLocale systemLocale]];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];

    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [formatter setCalendar:calendar];
    
    NSDate *date = [formatter dateFromString:dateStr];
    
    return date;
}


- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(adg_){
        [adg_ resumeRefresh];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(adg_){
        [adg_ pauseRefresh];
    }
}

- (void)dealloc {
    adg_.delegate = nil;
    adg_ = nil;
}

- (void)viewDidUnload {
    [self setGameResult:nil];
    [self setBattingResultViewArray:nil];
    [self setScrollView:nil];
    [self setResultPicker:nil];
    [self setResultToolbar:nil];
    [self setMyscore:nil];
    [self setOtherscore:nil];
    [self setDatenLabel:nil];
    [self setDaten:nil];
    [self setTokutenLabel:nil];
    [self setTokuten:nil];
    [self setErrorLabel:nil];
    [self setError:nil];
    [self setStealLabel:nil];
    [self setSteal:nil];
    [self setStealOutLabel:nil];
    [self setStealOut:nil];
    [self setSaveButton:nil];
    [self setToPitchingButton:nil];
    [self setMemoLabel:nil];
    [self setMemo:nil];
    [super viewDidUnload];
}

@end
