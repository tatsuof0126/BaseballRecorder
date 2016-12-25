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
// #import "ResultPickerViewController.h"
#import "SelectInputViewController.h"
#import "TrackingManager.h"

#define NEW_INPUT 999
#define ALERT_BACK 1
#define ALERT_SAVE 2

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize gadView;
@synthesize gameResult;
@synthesize battingResultViewArray;
@synthesize scrollView;
@synthesize pickerBaseView;
@synthesize resultPicker;
@synthesize selectPicker;
@synthesize resultToolbar;
@synthesize rectView;
@synthesize inputtype;
@synthesize showDetail;
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
    _error.text = [NSString stringWithFormat:@"%d",gameResult.error];
    _steal.text = [NSString stringWithFormat:@"%d",gameResult.steal];
    _stealOut.text = [NSString stringWithFormat:@"%d",gameResult.stealOut];
    
    _dajun = gameResult.dajun;
    _shubiArray = [NSMutableArray array];
    if(gameResult.shubi1 != 0){
        [_shubiArray addObject:[NSNumber numberWithInt:gameResult.shubi1]];
    }
    if(gameResult.shubi2 != 0){
        [_shubiArray addObject:[NSNumber numberWithInt:gameResult.shubi2]];
    }
    if(gameResult.shubi3 != 0){
        [_shubiArray addObject:[NSNumber numberWithInt:gameResult.shubi3]];
    }
    
    _semeBtn.tag = gameResult.seme;
    [self setSemeButton];
    
    showDetail = NO;
    if([gameResult.place isEqualToString:@""] == NO ||
       _semeBtn.tag != 0 || _dajun != 0 || _shubiArray.count > 0){
        showDetail = YES;
    }
    
    _memo.text = gameResult.memo;
    _memo.placeholder = @"その日の天候やサヨナラ勝ちなど\n試合のメモが入力できます";
    
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
    
    edited = NO;
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    // NSLog(@"y : %f", scrollView.contentOffset.y);
    
    int detailAdjust = showDetail ? 110 : 0;
    
    if ((textField == _daten || textField == _tokuten || textField == _error ||
         textField == _steal || textField == _stealOut) &&
        scrollView.contentOffset.y < 250.0f+detailAdjust+gameResult.battingResultArray.count*40){
        [scrollView setContentOffset:CGPointMake(0.0f, 250.0f+detailAdjust+gameResult.battingResultArray.count*40) animated:YES];
    }
    
    if ((textField == _place) &&
        scrollView.contentOffset.y < 175.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 175.0f) animated:YES];
    }
    
    /*
    if ((textField == _myscore || textField == _otherscore) &&
        scrollView.contentOffset.y < 52.0f){
        [scrollView setContentOffset:CGPointMake(0.0f, 52.0f) animated:YES];
    }
    */
    
    [self showDoneButton];
    
    // ResultPickerを閉じる
    [self closePicker];
    
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
    // NSLog(@"y : %f", scrollView.contentOffset.y);
    
    int detailAdjust = showDetail ? 110 : 0;
    
    if (textView == _memo &&
        scrollView.contentOffset.y < 345.0f+detailAdjust+gameResult.battingResultArray.count*40){
        [scrollView setContentOffset:CGPointMake(0.0f, 345.0f+detailAdjust+gameResult.battingResultArray.count*40) animated:YES];
    }
    
    [self showDoneButton];
    
    // ResultPickerを閉じる
    [self closePicker];
    
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

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
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
    [self closePicker];
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
    
    int battingBaseY = 220;
    if(showDetail == YES){
        battingBaseY = 330;
    }
    
    for (int i=0; i<battingResultArray.count; i++) {
        BattingResult *battingResult = [battingResultArray objectAtIndex:i];
        
        UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,battingBaseY+5+i*40,80,21)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        
        UILabel *resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(110,battingBaseY+5+i*40,160,21)];
        resultlabel.text = [battingResult getResultShortString];
        resultlabel.textColor = [battingResult getResultColor];
        
        UIButton *changebutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        changebutton.frame = CGRectMake(210,battingBaseY+i*40,55,30);
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
    UILabel *nlabel = [[UILabel alloc] initWithFrame:CGRectMake(30,battingBaseY+5+battingResultArray.count*40,80,21)];
    nlabel.text = [NSString stringWithFormat:@"第%zd打席",battingResultArray.count+1];
    
    UIButton *nbutton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    nbutton.frame = CGRectMake(110,battingBaseY+battingResultArray.count*40,55,30);
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
    int detailAdjust = showDetail ? 110 : 0;
    int battingAdjust = 270+[Utility convert2int:gameResult.battingResultArray.count]*40;
    int memoAdjust = _memo.frame.size.height;
    
    NSString* detailBtnStr = showDetail ? @"▼" : @"詳細";
    [_detailBtn setTitle:detailBtnStr forState:UIControlStateNormal];
    _placeLabel.hidden = !showDetail;
    _place.hidden = !showDetail;
    _placeBtn.hidden = !showDetail;
    _semeLabel.hidden = !showDetail;
    _semeBtn.hidden = !showDetail;
    _dajunShubiLabel.hidden = !showDetail;
    _dajunShubi.hidden = !showDetail;
    _dajunShubiInputBtn.hidden = !showDetail;
    _dajunShubiChangeBtn.hidden = !showDetail;
    
    if(showDetail == YES){
        if(_dajun == 0 && _shubiArray.count == 0){
            _dajunShubiChangeBtn.hidden = YES;
            _dajunShubi.hidden = YES;
        } else {
            // 打順/守備欄の文字列を設定
            NSArray* dajunStr = [[GameResult getDajunPickerArray] objectAtIndex:_dajun];
            NSArray* shubiStrArray = _shubiArray.count > 1 ? [GameResult getShortShubiPickerArray] : [GameResult getShubiPickerArray];
            NSMutableString* shubiStr = [NSMutableString string];
            for(NSNumber* num in _shubiArray){
                [shubiStr appendString:@" "];
                [shubiStr appendString:[shubiStrArray objectAtIndex:[num intValue]]];
            }
            _dajunShubi.text = [NSString stringWithFormat:@"%@%@",dajunStr, shubiStr];
            
            _dajunShubiInputBtn.hidden = YES;
        }
    }
    
    [self setFrameOriginY:_battingResultLabel originY:189+detailAdjust];
    
    [self setFrameOriginY:_datenLabel originY:detailAdjust+battingAdjust+4];
    [self setFrameOriginY:_daten originY:detailAdjust+battingAdjust];
    [self setFrameOriginY:_tokutenLabel originY:detailAdjust+battingAdjust+4];
    [self setFrameOriginY:_tokuten originY:detailAdjust+battingAdjust];
    [self setFrameOriginY:_errorLabel originY:detailAdjust+battingAdjust+4];
    [self setFrameOriginY:_error originY:detailAdjust+battingAdjust];
    [self setFrameOriginY:_stealLabel originY:detailAdjust+battingAdjust+44];
    [self setFrameOriginY:_steal originY:detailAdjust+battingAdjust+40];
    [self setFrameOriginY:_stealOutLabel originY:detailAdjust+battingAdjust+44];
    [self setFrameOriginY:_stealOut originY:detailAdjust+battingAdjust+40];
    [self setFrameOriginY:_memoLabel originY:detailAdjust+battingAdjust+85];
    [self setFrameOriginY:_memo originY:detailAdjust+battingAdjust+115];
    [self setFrameOriginY:toPitchingButton originY:detailAdjust+battingAdjust+memoAdjust+135];
    
    // ScrollViewの長さを調整
    CGSize size = CGSizeMake(320, detailAdjust+battingAdjust+memoAdjust+450);
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
        [self closePicker];
        [self makeResultPicker:NEW_INPUT animated:NO];
    }
}

- (void)changeResult:(UIButton*)button{
    if(resultPicker == nil){
        [self makeResultPicker:button.tag animated:YES];
        edited = YES;
    } else if(resultPicker.tag != button.tag){
        [self closePicker];
        [self makeResultPicker:button.tag animated:NO];
    }
}

- (void)makeResultPicker:(NSInteger)resultno animated:(BOOL)animated {
    [self doneButton]; // 初めに他の編集項目の編集を終了させる
    [self closePicker];
    
    // 広告ビューを隠す
    if(gadView != nil){
        [gadView setHidden:YES];
    }
    
    // スクロール位置を設定
    NSInteger count = 0;
    if(resultno == NEW_INPUT){
        count = gameResult.battingResultArray.count;
    } else {
        count = resultno;
    }
    
    int detailAdjust = showDetail ? 110 : 0;
    
    // タグを隠す対応で、250→210
    [scrollView setContentOffset:CGPointMake(0.0f, 170.0f+detailAdjust+count*40) animated:YES];
    
    // 入力対象の打撃結果を赤線で囲う
    // タグを隠す対応で、295→255
    rectView = [[RectView alloc] initWithFrame:CGRectMake(20, 215+detailAdjust+count*40, 280, 40)];
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
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarCloseButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarResultClearButton:)];
    UIBarButtonItem *nextButton = [[UIBarButtonItem alloc] initWithTitle:@"決定して次へ"
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarResultNextButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"  決定  "
        style:UIBarButtonItemStylePlain target:self action:@selector(toolbarResultDoneButton:)];
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

- (void)makeSelectPicker {
    [self doneButton]; // 初めに他の編集項目の編集を終了させる
    [self closePicker];
    
    // 広告ビューを隠す
    if(gadView != nil){
        [gadView setHidden:YES];
    }
    
    // SelectPickerを作る
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    // PickerViewを乗せるView。アニメーションで出すのでとりあえず画面下に出す。
    pickerBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 250)];
    pickerBaseView.backgroundColor = [UIColor clearColor];
    
    // PickerView
    selectPicker = [[UIPickerView alloc] init];
    selectPicker.center = CGPointMake(width/2, 135);
    selectPicker.backgroundColor = [UIColor whiteColor];
    selectPicker.delegate = self;  // デリゲートを自分自身に設定
    selectPicker.dataSource = self;  // データソースを自分自身に設定
    selectPicker.showsSelectionIndicator = YES;
    selectPicker.tag = _shubiArray.count > 1 ? 1+_shubiArray.count : 2; // 項目（列）の数
    
    // Pickerの値を初期設定
    [selectPicker selectRow:_dajun inComponent:0 animated:NO];
    int i=1;
    for(NSNumber* num in _shubiArray){
        int numInt = [num intValue];
        [selectPicker selectRow:numInt inComponent:i animated:NO];
        i++;
    }
    
    // Toolbar（既存の成績の編集の場合のみクリアボタンを出す）
    resultToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    resultToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@" 閉じる "
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(toolbarCloseButton:)];
    UIBarButtonItem *clearButton = [[UIBarButtonItem alloc] initWithTitle:@"クリア"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(toolbarSelectClearButton:)];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithTitle:@"守備追加"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(toolbarSelectAddButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"  決定  "
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(toolbarSelectDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = nil;
    if(_dajun == 0 && _shubiArray.count == 0){
        items = [NSArray arrayWithObjects:backButton, spacer, addButton, spacer,doneButton, nil];
    } else {
        items = [NSArray arrayWithObjects:backButton, clearButton, spacer, addButton, spacer,doneButton, nil];
    }
    
    [resultToolbar setItems:items animated:YES];
    
    [pickerBaseView addSubview:selectPicker];
    [pickerBaseView addSubview:resultToolbar];
    
    [self.view addSubview:pickerBaseView];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
    [UIView commitAnimations];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView {
    if(pickerView == resultPicker){
        return 2;
    } else if(pickerView == selectPicker){
        return pickerView.tag;
    }
    
    return 1; // 来ないはず
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView == resultPicker){
        if (component == 0){
            return [[BattingResult getBattingPositionStringArray:P_STR_PICKER] count];
        } else {
            return [[BattingResult getBattingResultStringArray:R_STR_PICKER] count];
        }
    } else if(pickerView == selectPicker){
        if(component == 0){
            return [[GameResult getDajunPickerArray] count];
        } else {
            return [[GameResult getShubiPickerArray] count];
        }
    }
    return 1; // 来ないはず
}

- (NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{    
    if(pickerView == resultPicker){
        if (component == 0){
            return [[BattingResult getBattingPositionStringArray:P_STR_PICKER] objectAtIndex:row];
        } else {
            return [[BattingResult getBattingResultStringArray:R_STR_PICKER] objectAtIndex:row];
        }
    } else if(pickerView == selectPicker){
        if(component == 0){
            if(selectPicker.tag == 2){
                return [[GameResult getDajunPickerArray] objectAtIndex:row];
            } else {
                return [[GameResult getShortDajunPickerArray] objectAtIndex:row];
            }
        } else {
            if(selectPicker.tag == 2){
                return [[GameResult getShubiPickerArray] objectAtIndex:row];
            } else {
                return [[GameResult getShortShubiPickerArray] objectAtIndex:row];
            }
        }
    }
    return @""; // 来ないはず
}

- (void)toolbarCloseButton:(UIBarButtonItem*)sender {
    [self closePicker];
}

- (void)toolbarResultClearButton:(id)sender {
    int resultno = [Utility convert2int:[sender tag]];
    
    [gameResult removeBattingResult:resultno];
    
    [self closePicker];
    
    [self makeBattingResult];
}

- (void)toolbarResultNextButton:(id)sender {
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
        [self closePicker];
        
        [self makeBattingResult];
        
        [self makeResultPicker:NEW_INPUT animated:NO];
    }
}

- (void)toolbarResultDoneButton:(id)sender {
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
        
        [self closePicker];
        
        [self makeBattingResult];
    }
}

- (void)toolbarSelectClearButton:(id)sender {
    _dajun = 0;
    _shubiArray = [NSMutableArray array];
    
    [self makeBattingResult];
    [self closePicker];
}

- (void)toolbarSelectAddButton:(id)sender {
    if(selectPicker.tag < 4){
        selectPicker.tag++;
        [selectPicker reloadAllComponents];
    }
}

- (void)toolbarSelectDoneButton:(id)sender {
    // Pickerでの設定値を変数に格納
    _dajun = (int)[selectPicker selectedRowInComponent:0];
    _shubiArray = [NSMutableArray array];
    for(int i=1;i<selectPicker.tag;i++){
        int selectShubi = (int)[selectPicker selectedRowInComponent:i];
        int lastShubi = [_shubiArray lastObject] != nil ? [[_shubiArray lastObject] intValue] : 0;
        
        if(selectShubi != 0 && selectShubi != lastShubi){
            [_shubiArray addObject:[NSNumber numberWithInteger:selectShubi]];
        }
    }
    
    [self makeBattingResult];
    [self closePicker];
}

- (void)closePicker {
    [selectPicker removeFromSuperview];
    [resultPicker removeFromSuperview];
    [resultToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    [rectView removeFromSuperview];

    selectPicker = nil;
    pickerBaseView = nil;
    resultPicker = nil;
    resultToolbar = nil;
    rectView = nil;
    
    // 広告ビューを再表示
    if(gadView != nil){
        [gadView setHidden:NO];
    }
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

- (IBAction)detailButton:(id)sender {
    showDetail = !showDetail;
    [self.view endEditing:YES];
    [self closePicker];
    [self makeBattingResult];
}

- (IBAction)semeButton:(id)sender {
    [self.view endEditing:YES];
    [self closePicker];
    
    _semeBtn.tag++;
    if(_semeBtn.tag >= 3){
        _semeBtn.tag = 0;
    }
    
    [self setSemeButton];
}

- (void)setSemeButton {
    UIFont* font18 = [UIFont systemFontOfSize:18];
    UIFont* font15 = [UIFont systemFontOfSize:15];
    NSAttributedString* attrStr = nil;
    
    switch (_semeBtn.tag) {
        case 0:
            attrStr = [[NSAttributedString alloc] initWithString:@"未設定" attributes:@{NSFontAttributeName:font15}];
            break;
        case 1:
            attrStr = [[NSAttributedString alloc] initWithString:@"先攻" attributes:@{NSFontAttributeName:font18}];
            break;
        case 2:
            attrStr = [[NSAttributedString alloc] initWithString:@"後攻" attributes:@{NSFontAttributeName:font18}];
            break;
        default:
            break;
    }
    
    [_semeBtn setAttributedTitle:attrStr forState:UIControlStateNormal];
}

- (IBAction)dajunShubiInputButton:(id)sender {
    [self makeSelectPicker];
}

- (IBAction)dajunShubiChangeButton:(id)sender {
    [self makeSelectPicker];
}

- (IBAction)toPitchingButton:(id)sender {
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃成績入力画面―投手成績へ" value:nil screen:@"打撃成績入力画面"];
    
    // 入力中状態を解除
    [self endTextEdit];
    [self closePicker];
    
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
        NSDate* date = [Utility getDate:_year.text month:_month.text day:_day.text];
        if(date == nil){
            [errorArray addObject:@"日付が正しくありません。"];
        }
    }

    // 場所は必須項目からはずした
//    if(_place.text.length == 0){
//        blankFlg = YES;
//    }
    
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
    NSDate* date = [Utility getDate:_year.text month:_month.text day:_day.text];
    
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
    gameResult.stealOut = [_stealOut.text intValue];
    gameResult.error = [_error.text intValue];
    
    gameResult.dajun = _dajun;
    gameResult.seme = (int)_semeBtn.tag;
    gameResult.shubi1 = 0;
    gameResult.shubi2 = 0;
    gameResult.shubi3 = 0;
    if(_shubiArray.count >= 1){
        gameResult.shubi1 = [[_shubiArray objectAtIndex:0] intValue];
    }
    if(_shubiArray.count >= 2){
        gameResult.shubi2 = [[_shubiArray objectAtIndex:1] intValue];
    }
    if(_shubiArray.count >= 3){
        gameResult.shubi3 = [[_shubiArray objectAtIndex:2] intValue];
    }
    
    
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

/*
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
*/

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
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
