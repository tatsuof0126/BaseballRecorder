//
//  InputViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "InputViewController.h"
#import "AppDelegate.h"
#import "ConfigManager.h"
#import "GameResultManager.h"
#import "ResultPickerViewController.h"
#import "SelectInputViewController.h"

#define NEW_INPUT 999
#define ALERT_BACK 1
#define ALERT_SAVE 2

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize gameResult;
@synthesize battingResultViewArray;
@synthesize scroolview;
@synthesize resultPicker;
@synthesize resultToolbar;
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
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    //    int resultid = appDelegate.targatResultid;
    
    gameResult = appDelegate.targetGameResult;

    if(gameResult == nil){
        gameResult = [[GameResult alloc] init];
        
        // 日付を今日に初期設定
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDate *date = [NSDate date];
        NSDateComponents *dateComps
        = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
        
        gameResult.year = dateComps.year;
        gameResult.month = dateComps.month;
        gameResult.day = dateComps.day;
        
        // 場所・チームにデフォルト値を設定
        NSString* defaultPlace = [ConfigManager getDefaultPlace];
        NSString* defaultMyteam = [ConfigManager getDefaultMyTeam];
        
        gameResult.place = defaultPlace;
        gameResult.myteam = defaultMyteam;
    }
    
    _year.text = [NSString stringWithFormat:@"%d",gameResult.year];
    _month.text = [NSString stringWithFormat:@"%d",gameResult.month];
    _day.text = [NSString stringWithFormat:@"%d",gameResult.day];
    
    _place.text = gameResult.place;
    _myteam.text = gameResult.myteam;
    _otherteam.text = gameResult.otherteam;
    _myscore.text = [NSString stringWithFormat:@"%d",gameResult.myscore];
    _otherscore.text = [NSString stringWithFormat:@"%d",gameResult.otherscore];
    
    battingResultViewArray = [NSMutableArray array];
    
    [self makeBattingResult];
    
    // iPhone5対応
    [AppDelegate adjustForiPhone5:scroolview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self showDoneButton];
    // ResultPickerを閉じる
    [self closeResultPicker];
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
    _inputNavi.rightBarButtonItem = nil;
}

- (void)doneButton {
    [_year endEditing:YES];
    [_month endEditing:YES];
    [_day endEditing:YES];
    [_place endEditing:YES];
    [_myteam endEditing:YES];
    [_otherteam endEditing:YES];
    [_myscore endEditing:YES];
    [_otherscore endEditing:YES];
}

- (void)makeBattingResult {
    for (int i=0; i<battingResultViewArray.count; i++) {
        NSDictionary *dic = [battingResultViewArray objectAtIndex:i];
        
        NSArray *uiViewArray = [dic allValues];
        for (int j=0; j<uiViewArray.count; j++) {
            UIView *uiView = [uiViewArray objectAtIndex:j];
            [uiView removeFromSuperview];
        }
    }
    
    battingResultViewArray = [NSMutableArray array];
    
    NSArray *battingResultArray = gameResult.battingResultArray;
    
    for (int i=0; i<battingResultArray.count; i++) {
        BattingResult *battingResult = [battingResultArray objectAtIndex:i];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,265+i*40,80,21)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        
        UILabel *resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(110,265+i*40,160,21)];
        resultlabel.text = [battingResult getResultString];
        
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
        
        [scroolview addSubview:titlelabel];
        [scroolview addSubview:resultlabel];
        [scroolview addSubview:changebutton];
    }
    
    UILabel *nlabel = [[UILabel alloc] initWithFrame:CGRectMake(30,265+battingResultArray.count*40,80,21)];
    nlabel.text = [NSString stringWithFormat:@"第%d打席",battingResultArray.count+1];
    
    UIButton *nbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nbutton.frame = CGRectMake(110,260+battingResultArray.count*40,55,30);
    [nbutton setTitle:@"入力" forState:UIControlStateNormal];
    [nbutton addTarget:self action:@selector(inputResult:) forControlEvents:UIControlEventTouchDown];
    
    NSMutableDictionary *nmdic = [NSMutableDictionary dictionary];
    [nmdic setObject:nlabel forKey:@"title"];
    [nmdic setObject:nbutton forKey:@"inputbutton"];
    
    [battingResultViewArray addObject:nmdic];
    
    [scroolview addSubview:nlabel];
    [scroolview addSubview:nbutton];
    
    int saveY = 320+battingResultArray.count*40;
    if(saveY < 340){saveY = 340;}
    
    saveButton.frame = CGRectMake(90,saveY,140,43);
    
    CGSize size = CGSizeMake(320, saveY+160);
    scroolview.contentSize = size;
    
    
//    NSLog(@"height : %f",scroolview.contentSize.height);
    
}

- (void)inputResult:(UIButton*)button{
    [self makeResultPiker:NEW_INPUT];
}

- (void)changeResult:(UIButton*)button{
    [self makeResultPiker:button.tag];
}

- (void)makeResultPiker:(NSInteger)resultno {
    // 初めに他の編集項目の編集を終了させる
    [self doneButton];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    resultPicker = [[UIPickerView alloc] init];
    
    resultPicker.center = CGPointMake(width/2, height+125+60);
    resultPicker.delegate = self;  // デリゲートを自分自身に設定
    resultPicker.dataSource = self;  // データソースを自分自身に設定
    resultPicker.showsSelectionIndicator = YES;
    
    if(resultno != NEW_INPUT){
        BattingResult *battingResult = [gameResult getBattingResult:resultno];
        [resultPicker selectRow:battingResult.position inComponent:0 animated:NO];
        [resultPicker selectRow:battingResult.result inComponent:1 animated:NO];
    }
    
    resultToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height, 320, 44)];
    resultToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarClearButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [clearButton setTag:resultno];
    [doneButton setTag:resultno];
    
    NSArray *items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    if(resultno == NEW_INPUT){
        items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    } else {
        items = [NSArray arrayWithObjects:backButton, clearButton, spacer, doneButton, nil];
    }
    
    [resultToolbar setItems:items animated:YES];
    
    [self.view addSubview:resultToolbar];
    [self.view addSubview:resultPicker];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    resultPicker.center = CGPointMake(width/2, height-125);    // 表示する中心座標を表示画面中央に
    resultToolbar.center = CGPointMake(width/2, height-255);
    
    [UIView commitAnimations];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[BattingResult getBattingResultTypeArray] objectAtIndex:component] count];
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return [[[BattingResult getBattingResultTypeArray] objectAtIndex:component] objectAtIndex:row];
}


- (void)toolbarBackButton:(UIBarButtonItem*)sender {
    [self closeResultPicker];
}

- (void)toolbarClearButton:(id)sender {
    int resultno = [sender tag];
    
    [gameResult removeBattingResult:resultno];
    
    [self closeResultPicker];
    
    [self makeBattingResult];
}

- (void)toolbarDoneButton:(id)sender {
    int resultno = [sender tag];
    
    int position = [resultPicker selectedRowInComponent:0];
    int result = [resultPicker selectedRowInComponent:1];
    
    BattingResult *battingResult = [BattingResult makeBattingResult:position result:result];
    
    if( battingResult != nil){
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
    
    resultPicker = nil;
    resultToolbar = nil;
}

- (IBAction)backButton:(id)sender {
//    NSLog(@"Back resultid : %d",gameResult.resultid);
    
    if(gameResult.resultid != 0){
        // 入力エラーがない場合は保存確認のダイアログを表示
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果入力"
            message:@"編集内容は保存されませんが、\nよろしいですか？"
            delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        [alert setTag:ALERT_BACK];
        [alert show];
    } else {
        [self dismissModalViewControllerAnimated:YES];
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
    
    // 入力エラーがない場合は保存確認のダイアログを表示
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果入力" message:@"保存してよろしいですか？"
                              delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
    [alert setTag:ALERT_SAVE];
    [alert show];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {

//    NSLog(@"buttonIndex : %d",buttonIndex);

    switch (alertView.tag) {
        case ALERT_BACK:
            if(buttonIndex == 1){
                [self dismissModalViewControllerAnimated:YES];
            }
            break;
            
        case ALERT_SAVE:
            if(buttonIndex == 1){
                // 入力内容をオブジェクトに反映
                [self updateGameResult];
                
                // ファイルに保存
                [GameResultManager saveGameResult:gameResult];
                
                [self dismissModalViewControllerAnimated:YES];
            }
            break;
            
        default:
            break;
    }
}

- (NSArray*)inputCheck {
    NSMutableArray* errorArray = [NSMutableArray array];
    // 未入力フラグ
    BOOL blankFlg = false;    
    
    if(_year.text.length == 0 || _month.text.length == 0 || _day.text.length == 0){
        blankFlg = true;
    } else {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ 09:00",
                             _year.text, _month.text, _day.text];
        
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"YYYY-MM-dd HH:mm"];
        
        NSDate *date = [formatter dateFromString:dateStr];
        
        if(date == NULL){
            [errorArray addObject:@"日付が正しくありません。"];
        }
    }
    
    if(_place.text.length == 0){
        blankFlg = true;
    }
    
    if(_myteam.text.length == 0){
        blankFlg = true;
    }
    
    if(_otherteam.text.length == 0){
        blankFlg = true;
    }
    
    if(_myscore.text.length == 0 || _otherscore.text.length == 0){
        blankFlg = true;
    } else {
        int myscore = [_myscore.text intValue];
        int otherscore = [_otherscore.text intValue];
        
        if((myscore == 0 && [_myscore.text isEqualToString:@"0"] == false) ||
           (otherscore == 0 && [_otherscore.text isEqualToString:@"0"] == false)){
            [errorArray addObject:@"試合結果が正しくありません"];
        }
    }
    
    if(blankFlg == true){
        [errorArray addObject:@"入力されていない項目があります。"];
    }    
    
    return errorArray;
}

- (void)updateGameResult {
    
    // 日付は一度カレンダーに変換してから取得する。
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%@ 09:00",
                         _year.text, _month.text, _day.text];
    
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"]; // YYYYだとiOS6で1年ずれる
    NSDate *date = [formatter dateFromString:dateStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 日時をカレンダーで年月日に分解する
    NSDateComponents *dateComps
        = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    gameResult.year = dateComps.year;
    gameResult.month = dateComps.month;
    gameResult.day = dateComps.day;
    
    gameResult.place = [self escapeString:_place.text];
    gameResult.myteam = [self escapeString:_myteam.text];
    gameResult.otherteam = [self escapeString:_otherteam.text];
    gameResult.myscore = [_myscore.text intValue];
    gameResult.otherscore = [_otherscore.text intValue];
    
}

- (NSString*)escapeString:(NSString*)sourceString {
    // カンマをピリオドに置換
    return [sourceString stringByReplacingOccurrencesOfString:@"," withString:@"."];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSString* segueStr = [segue identifier];
    
//    NSLog(@"%@",segueStr);
    
    SelectInputViewController *viewController = [segue destinationViewController];
    if ([segueStr isEqualToString:@"place"] == true) {
        viewController.selecttype = PLACE;
        viewController.targetField = _place;
    } else if ([segueStr isEqualToString:@"myteam"] == true) {
        viewController.selecttype = MYTEAM;
        viewController.targetField = _myteam;
    } else if ([segueStr isEqualToString:@"otherteam"] == true) {
        viewController.selecttype = OTHERTEAM;
        viewController.targetField = _otherteam;
    }
}

- (void)viewDidUnload {
    [self setGameResult:nil];
    [self setBattingResultViewArray:nil];
    [self setScroolview:nil];
    [self setResultPicker:nil];
    [self setResultToolbar:nil];
    [self setSaveButton:nil];

    [self setMyscore:nil];
    [self setOtherscore:nil];
    [super viewDidUnload];
}

@end