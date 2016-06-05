//
//  StatisticsCommonController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/14.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "StatisticsCommonController.h"
#import "ConfigManager.h"
#import "GameResult.h"
#import "GameResultManager.h"
#import "TargetTerm.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "TrackingManager.h"

@interface StatisticsCommonController ()

@end

@implementation StatisticsCommonController

//@synthesize gameResultList;
//@synthesize gameResultListOfYear;
//@synthesize yearList;
@synthesize teamList;
@synthesize termBeginList;
@synthesize termEndList;
@synthesize termList;
//@synthesize targetyear;
//@synthesize targetteam;
@synthesize pickerBaseView;
@synthesize targetPicker;
@synthesize targetToolbar;
@synthesize posted;
@synthesize adg = adg_;

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

    // 子クラスでオーバーライドする前提
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    // 子クラスでオーバーライドする前提

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateStatistics {
//    [self loadGameResult];
//    [self setCalcTarget];
    NSArray* gameResultListForCalc = [self getGameResultListForCalc];
    [self showStatistics:gameResultListForCalc];
}

- (NSArray*)getGameResultListForCalc {
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    NSString* targetTeam = [ConfigManager getCalcTargetTeam];
    
    if ([targetTeam isEqualToString:@"すべて"]) {
        targetTeam = @"";
    }
    
    NSMutableArray* gameResultListForCalc = [NSMutableArray arrayWithArray:
        [GameResultManager loadGameResultList:targetTerm targetTeam:targetTeam]];
    
    // 「最近５試合」の場合は直近の５件に絞る
    if (targetTerm.type == TERM_TYPE_RECENT5) {
        [self adjustGameResultListForRecent5:gameResultListForCalc];
    }
    
    return gameResultListForCalc;
}

- (void)adjustGameResultListForRecent5:(NSMutableArray*)gameResultListForCalc {
    // 子クラスでオーバーライドする前提
    
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
    // 子クラスでオーバーライドする前提

}

- (void)showTarget:(UILabel*)year team:(UILabel*)team leftBtn:(UIButton*)leftBtn rightBtn:(UIButton*)rightBtn {
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    year.text = [targetTerm getTermStringForView];
    team.text = [ConfigManager getCalcTargetTeam];
    
    // 左右の矢印を出すかどうかを判定
    NSArray* targetTermList = [TargetTerm getActiveTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
    TargetTerm* firstTerm = [targetTermList firstObject];
    TargetTerm* lastTerm = [targetTermList lastObject];
    
    leftBtn.hidden = YES;
    rightBtn.hidden = YES;
    
    switch (targetTerm.type) {
        case TERM_TYPE_ALL:
            break;
        case TERM_TYPE_RECENT5:
            break;
        case TERM_TYPE_YEAR:{
            if(firstTerm != nil && firstTerm.beginyear > targetTerm.beginyear){
                rightBtn.hidden = NO;
            }
            if(lastTerm != nil && targetTerm.beginyear > lastTerm.beginyear){
                leftBtn.hidden = NO;
            }
            break;
        }
        case TERM_TYPE_MONTH:{
            if(firstTerm != nil &&
               (firstTerm.beginyear > targetTerm.beginyear ||
                (firstTerm.beginyear == targetTerm.beginyear && firstTerm.beginmonth > targetTerm.beginmonth))){
                rightBtn.hidden = NO;
            }
            if(lastTerm != nil &&
               (targetTerm.beginyear > lastTerm.beginyear ||
                (targetTerm.beginyear == lastTerm.beginyear && targetTerm.beginmonth > lastTerm.beginmonth))){
                   
                leftBtn.hidden = NO;
            }
            break;
        }
        case TERM_TYPE_RANGE_YEAR:
            break;
        case TERM_TYPE_RANGE_MONTH:
            break;
        default:
            break;
    }
}

- (void)moveLeftTargetTerm {
    // Picker起動時は無視
    if( targetPicker != nil ){
        return;
    }
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    NSArray* targetTermList = [TargetTerm getActiveTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
    
    TargetTerm* newTargetTerm = targetTerm;
    for (TargetTerm* compTerm in targetTermList){
        if(targetTerm.type == TERM_TYPE_YEAR &&
           (targetTerm.beginyear > compTerm.beginyear)){
            newTargetTerm = compTerm;
            break;
        }
        if(targetTerm.type == TERM_TYPE_MONTH &&
           (targetTerm.beginyear > compTerm.beginyear ||
            (targetTerm.beginyear == compTerm.beginyear && targetTerm.beginmonth > compTerm.beginmonth))){
               newTargetTerm = compTerm;
               break;
           }
    }
    
    if(newTargetTerm != nil){
        [ConfigManager setCalcTargetTerm:newTargetTerm];
    }
    
    [self updateStatistics];

}

- (void)moveRightTargetTerm {
    // Picker起動時は無視
    if( targetPicker != nil ){
        return;
    }
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    NSArray* targetTermList = [TargetTerm getActiveTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
    
    TargetTerm* newTargetTerm = targetTermList.firstObject;
    for (TargetTerm* compTerm in targetTermList){
        if(targetTerm.type == TERM_TYPE_YEAR &&
           (targetTerm.beginyear >= compTerm.beginyear)){
            break;
        }
        if(targetTerm.type == TERM_TYPE_MONTH &&
           (targetTerm.beginyear > compTerm.beginyear ||
            (targetTerm.beginyear == compTerm.beginyear && targetTerm.beginmonth >= compTerm.beginmonth))){
               break;
           }
        newTargetTerm = compTerm;
    }
    
    if(newTargetTerm != nil){
        [ConfigManager setCalcTargetTerm:newTargetTerm];
    }
    
    [self updateStatistics];
    
}

- (void)makeTeamPicker {
    // すでにPickerが立ち上がっていたら無視
    if(targetPicker != nil){
        return;
    }
    
    // PickerViewを準備
    [self preparePickerView];
    
    targetPicker.tag = PICKER_TEAM;
    
    // teamListを最新化
    NSArray* resultList = [GameResultManager loadGameResultList];
    teamList = [NSMutableArray array];
    [teamList addObject:@"すべて"];
    for(GameResult* result in resultList){
        NSString* team = result.myteam;
        if ([teamList containsObject:team] == NO){
            [teamList addObject:team];
        }
    }
    
    // Pickerのデフォルトを設定
    NSString* calcTargetTeam = [ConfigManager getCalcTargetTeam];
    for (int i=0;i<teamList.count;i++){
        NSString* team = [teamList objectAtIndex:i];
        if([team isEqualToString:calcTargetTeam]){
            [targetPicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    
    [self showPicker];
}

- (void)makeTermPicker {
    // すでにPickerが立ち上がっていたら無視
    if(targetPicker != nil){
        return;
    }
    
    [self doMakeTermPicker];
}

- (void)doMakeTermPicker {
    // PickerViewを準備
    [self preparePickerView];
    targetPicker.tag = PICKER_TERM;
    
    // termBeginList,termEndListを作る
    termBeginList = [NSMutableArray array];
    termEndList = [NSMutableArray array];
    
    // 現データの開始年と終了年を探る
    NSArray* resultList = [GameResultManager loadGameResultList];
    int beginYear = 9999;
    int endYear = 0;
    for(GameResult* result in resultList){
        if(result.year < beginYear){
            beginYear = result.year;
        }
        if(result.year > endYear){
            endYear = result.year;
        }
    }
    
    // Pickerの中身を作る、合わせてデフォルトを探す
    TargetTerm* allTerm = [[TargetTerm alloc] init];
    allTerm.type = TERM_TYPE_ALL;
    TargetTerm* recent5Term = [[TargetTerm alloc] init];
    recent5Term.type = TERM_TYPE_RECENT5;
    
    [termBeginList addObject:allTerm];
    [termBeginList addObject:recent5Term];
    [termEndList addObject:allTerm];
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    int beginDefault = 0;
    int endDefault = 0;
    if(targetTerm.type == TERM_TYPE_RECENT5){
        beginDefault = 1;
    }
    
    for (int i=beginYear; i<=endYear; i++) {
        TargetTerm* yearTerm = [[TargetTerm alloc] init];
        yearTerm.type = TERM_TYPE_YEAR;
        yearTerm.beginyear = i;
        
        [termBeginList addObject:yearTerm];
        [termEndList addObject:yearTerm];
        
        // 年が一致していればデフォルトとして設定
        if(targetTerm.type == TERM_TYPE_YEAR){
            if(targetTerm.beginyear == i){
                beginDefault = (int)termBeginList.count-1;
                endDefault = (int)termEndList.count-1;
            }
        }
        if(targetTerm.type == TERM_TYPE_RANGE_YEAR){
            if(targetTerm.beginyear == i){
                beginDefault = (int)termBeginList.count-1;
            }
            if(targetTerm.endyear == i){
                endDefault = (int)termEndList.count-1;
            }
        }
    }
    
    for (int i=beginYear; i<=endYear; i++) {
        for(int j=1; j<=12; j++){
            TargetTerm* monthTerm = [[TargetTerm alloc] init];
            monthTerm.type = TERM_TYPE_MONTH;
            monthTerm.beginyear = i;
            monthTerm.beginmonth = j;
            
            [termBeginList addObject:monthTerm];
            [termEndList addObject:monthTerm];
            
            // 年月が一致していればデフォルトとして設定
            if(targetTerm.type == TERM_TYPE_MONTH){
                if(targetTerm.beginyear == i && targetTerm.beginmonth == j){
                    beginDefault = (int)termBeginList.count-1;
                    endDefault = (int)termEndList.count-1;
                }
            }
            if(targetTerm.type == TERM_TYPE_RANGE_MONTH){
                if(targetTerm.beginyear == i && targetTerm.beginmonth == j){
                    beginDefault = (int)termBeginList.count-1;
                }
                if(targetTerm.endyear == i && targetTerm.endmonth == j){
                    endDefault = (int)termEndList.count-1;
                }
            }
        }
    }
    
    // Pickerのデフォルトを設定
    [targetPicker selectRow:beginDefault inComponent:0 animated:NO];
    [targetPicker selectRow:endDefault inComponent:1 animated:NO];
    
    [self showPicker];
}

- (void)preparePickerView {
    targetPicker = [[UIPickerView alloc] init];
    targetPicker.center = CGPointMake([[UIScreen mainScreen] bounds].size.width/2, 135);
    targetPicker.delegate = self;
    targetPicker.dataSource = self;
    targetPicker.showsSelectionIndicator = YES;
    targetPicker.backgroundColor = [UIColor whiteColor];
}

- (void)showPicker {
    CGFloat height = [[UIScreen mainScreen] bounds].size.height;
    
    // PickerViewを乗せるView。アニメーションで出すのでとりあえず画面下に出す。
    pickerBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 250)];
    pickerBaseView.backgroundColor = [UIColor clearColor];
    
    targetToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    targetToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"設定"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray* items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    [targetToolbar setItems:items animated:YES];
    
    [pickerBaseView addSubview:targetPicker];
    [pickerBaseView addSubview:targetToolbar];
    
    [self.view addSubview:pickerBaseView];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
    
    [UIView commitAnimations];
}

// あとで消すメソッド
/*
- (void)makeResultPicker {
    // すでにPickerが立ち上がっていたら無視
    if( targetPicker != nil ){
        return;
    }
    
    // termListを最新化
    NSArray* resultList = [GameResultManager loadGameResultList];
    termList = [TargetTerm getTargetTermListForPicker:resultList];
    
    // teamListを最新化
    teamList = [NSMutableArray array];
    [teamList addObject:@"すべて"];
    for(GameResult* result in resultList){
        NSString* team = result.myteam;
        if ([teamList containsObject:team] == NO){
            [teamList addObject:team];
        }
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    // PickerViewを乗せるView。アニメーションで出すのでとりあえず画面下に出す。
    pickerBaseView = [[UIView alloc] initWithFrame:CGRectMake(0, height, 320, 250)];
    pickerBaseView.backgroundColor = [UIColor clearColor];
    
    targetPicker = [[UIPickerView alloc] init];
//    targetPicker.center = CGPointMake(width/2, height+125+60);
    targetPicker.center = CGPointMake(width/2, 135);
    targetPicker.delegate = self;  // デリゲートを自分自身に設定
    targetPicker.dataSource = self;  // データソースを自分自身に設定
    targetPicker.showsSelectionIndicator = YES;
    targetPicker.backgroundColor = [UIColor whiteColor];
    
    // Pickerのデフォルトを設定
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    NSString* calcTargetTeam = [ConfigManager getCalcTargetTeam];
    
    for (int i=0;i<termList.count;i++){
        TargetTerm* term = [termList objectAtIndex:i];
        if([[term getTermString] isEqualToString:[targetTerm getTermString]]){
            [targetPicker selectRow:i inComponent:0 animated:NO];
            break;
        }
    }
    
    for (int i=0;i<teamList.count;i++){
        NSString* team = [teamList objectAtIndex:i];
        if([team isEqualToString:calcTargetTeam]){
            [targetPicker selectRow:i inComponent:1 animated:NO];
            break;
        }
    }
    
//    [targetPicker selectRow:targetyear inComponent:0 animated:NO];
//    [targetPicker selectRow:targetteam inComponent:1 animated:NO];
    
    targetToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    targetToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"設定"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    
    [targetToolbar setItems:items animated:YES];
    
    [pickerBaseView addSubview:targetPicker];
    [pickerBaseView addSubview:targetToolbar];
    
    [self.view addSubview:pickerBaseView];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    pickerBaseView.frame = CGRectMake(0, height-250, 320, 250);
//    targetPicker.center = CGPointMake(width/2, height-125);    // 表示する中心座標を表示画面中央に
//    targetToolbar.center = CGPointMake(width/2, height-255);
    
    [UIView commitAnimations];
}
*/

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    if(pickerView.tag == PICKER_TERM){
        return 2;
    } else if(pickerView.tag == PICKER_TEAM){
        return 1;
    }
    return 1;
}

- (NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    if(pickerView.tag == PICKER_TERM){
        return component == 0 ? termBeginList.count : termEndList.count;
    } else if(pickerView.tag == PICKER_TEAM){
        return teamList.count;
    }
    return 0;
}

- (NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if(pickerView.tag == PICKER_TERM){
        return component == 0 ? [[termBeginList objectAtIndex:row] getTermStringForView] : [[termEndList objectAtIndex:row] getTermStringForView];
    } else if(pickerView.tag == PICKER_TEAM){
        return [teamList objectAtIndex:row];
    }
    return @"";
}

- (void)toolbarBackButton:(UIBarButtonItem*)sender {
    [self closePicker];
}

- (void)toolbarDoneButton:(id)sender {
    if(targetPicker.tag == PICKER_TERM){
        TargetTerm* beginTerm = [termBeginList objectAtIndex:[targetPicker selectedRowInComponent:0]];
        TargetTerm* endTerm = [termEndList objectAtIndex:[targetPicker selectedRowInComponent:1]];
        
        // 入力チェック
        if (beginTerm.type != TERM_TYPE_ALL && endTerm.type != TERM_TYPE_ALL) {
            if(beginTerm.type == TERM_TYPE_MONTH && endTerm.type == TERM_TYPE_MONTH){
                if(beginTerm.beginyear > endTerm.beginyear ||
                   (beginTerm.beginyear == endTerm.beginyear && beginTerm.beginmonth > endTerm.beginmonth)){
                    return;
                }
            } else {
                if(beginTerm.beginyear > endTerm.beginyear){
                    return;
                }
            }
        }
        
        // 保存すべきTargetTermを作る
        TargetTerm* targetTerm = [[TargetTerm alloc] init];
        if(beginTerm.type == TERM_TYPE_ALL && endTerm.type == TERM_TYPE_ALL){
            // すべて＋すべてならすべて
            targetTerm.type = TERM_TYPE_ALL;
        } else if(beginTerm.type == TERM_TYPE_RECENT5){
            // 最近５試合が入っていたら最近５試合
            targetTerm.type = TERM_TYPE_RECENT5;
        } else if(beginTerm.type == TERM_TYPE_YEAR && endTerm.type == TERM_TYPE_YEAR &&
                  beginTerm.beginyear == endTerm.beginyear){
            // 両方年指定で等しい場合は年指定扱い
            targetTerm.type = TERM_TYPE_YEAR;
            targetTerm.beginyear = beginTerm.beginyear;
        } else if(beginTerm.type == TERM_TYPE_MONTH && endTerm.type == TERM_TYPE_MONTH &&
                  beginTerm.beginyear == endTerm.beginyear && beginTerm.beginmonth == endTerm.beginmonth){
            // 両方年月指定で等しい場合は年月指定扱い
            targetTerm.type = TERM_TYPE_MONTH;
            targetTerm.beginyear = beginTerm.beginyear;
            targetTerm.beginmonth = beginTerm.beginmonth;
        } else if((beginTerm.type == TERM_TYPE_ALL || beginTerm.type == TERM_TYPE_YEAR) &&
           (endTerm.type == TERM_TYPE_ALL || endTerm.type == TERM_TYPE_YEAR)){
            // 年＋年なら年の範囲指定
            targetTerm.type = TERM_TYPE_RANGE_YEAR;
            targetTerm.beginyear = beginTerm.beginyear;
            targetTerm.endyear = endTerm.beginyear;
        } else {
            // 年月＋年月なら年月の範囲指定
            targetTerm.type = TERM_TYPE_RANGE_MONTH;
            targetTerm.beginyear = beginTerm.beginyear;
            targetTerm.beginmonth = beginTerm.beginmonth == 0 ? 1 : beginTerm.beginmonth;
            targetTerm.endyear = endTerm.beginyear;
            targetTerm.endmonth = endTerm.beginmonth == 0 ? 12 : endTerm.beginmonth;
            
            if(targetTerm.beginyear == targetTerm.endyear &&
               targetTerm.beginmonth == targetTerm.endmonth){
                // 年指定の調整の結果、両方年月指定で等しくなった場合は年月指定扱い
                targetTerm.type = TERM_TYPE_MONTH;
                targetTerm.endyear = 0;
                targetTerm.endmonth = 0;
            }
        }
        
        [ConfigManager setCalcTargetTerm:targetTerm];
        
        [self updateStatistics];
        [self closePicker];
        return;
    } else if(targetPicker.tag == PICKER_TEAM){
        [ConfigManager setCalcTargetTeam:[teamList objectAtIndex:[targetPicker selectedRowInComponent:0]]];
        [self updateStatistics];
        [self closePicker];
        return;
    }
    
    [ConfigManager setCalcTargetTerm:[termList objectAtIndex:[targetPicker selectedRowInComponent:0]]];
    [ConfigManager setCalcTargetTeam:[teamList objectAtIndex:[targetPicker selectedRowInComponent:1]]];
    
    [self updateStatistics];
    
    [targetPicker removeFromSuperview];
    [targetToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    
    targetPicker = nil;
    targetToolbar = nil;
    pickerBaseView = nil;
}

- (void)closePicker {
    [targetPicker removeFromSuperview];
    [targetToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    
    targetPicker = nil;
    targetToolbar = nil;
    pickerBaseView = nil;
}

- (void)shareStatistics:(int)shareType {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    actionSheet.tag = shareType;
    [actionSheet addButtonWithTitle:@"Twitterにつぶやく"];
    [actionSheet addButtonWithTitle:@"Facebookに投稿"];
    [actionSheet addButtonWithTitle:@"Lineに送る"];
    [actionSheet addButtonWithTitle:@"キャンセル"];
    actionSheet.cancelButtonIndex = 3;
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self postToTwitter:(int)actionSheet.tag];
            break;
        case 1:
            [self postToFacebook:(int)actionSheet.tag];
            break;
        case 2:
            [self postToLine:(int)actionSheet.tag];
            break;
    }
}

- (void)postToTwitter:(int)shareType{
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃/投手成績参照・打撃分析画面―Twitterシェア" value:nil screen:@"打撃/投手成績参照・打撃分析画面"];
    
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_TWITTER shareType:(int)shareType];
    NSString* shareURLString = [self getShareURLString:POST_TWITTER shareType:(int)shareType];
    UIImage* shareImage = [self getShareImage:POST_TWITTER shareType:(int)shareType];
    
    SLComposeViewController* vc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [vc setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultDone:
                posted = YES;
                break;
            default:
                break;
        }
        [self dismissViewControllerAnimated:YES completion:^{
            if(posted == YES){
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                                message:@"つぶやきました" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
        }];
    }];
    
    if (shareURLString != nil){
        shareString = [[shareString stringByAppendingString:@" "] stringByAppendingString:shareURLString];
    }
    [vc setInitialText:shareString];
    if (shareImage != nil){
        [vc addImage:shareImage];
    }
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)postToFacebook:(int)shareType{
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃/投手成績参照・打撃分析画面―Facebookシェア" value:nil screen:@"打撃/投手成績参照・打撃分析画面"];
    
    NSString* shareString = [self makeShareString:POST_FACEBOOK shareType:(int)shareType];
    NSString* shareURLString = [self getShareURLString:POST_FACEBOOK shareType:(int)shareType];
    UIImage* shareImage = [self getShareImage:POST_FACEBOOK shareType:(int)shareType];
    
    if(shareType == SHARE_TYPE_TEXT){
        FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
        content.contentURL = [NSURL URLWithString:shareURLString];
        content.hashtag = [FBSDKHashtag hashtagWithString:@"#ベボレコ"];
        content.quote = shareString;
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
    } else if(shareType == SHARE_TYPE_IMAGE){
        FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
        photo.image = shareImage;
        photo.userGenerated = YES;
        photo.caption = shareString;
        
        FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
        content.photos = @[photo];
        content.hashtag = [FBSDKHashtag hashtagWithString:@"#ベボレコ"];
        
        [FBSDKShareDialog showFromViewController:self withContent:content delegate:nil];
    }
}

/*
- (void)postToFacebook:(int)shareType{
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃/投手成績参照・打撃分析画面―Facebookシェア" value:nil screen:@"打撃/投手成績参照・打撃分析画面"];
    
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_FACEBOOK shareType:(int)shareType];
    NSString* shareURLString = [self getShareURLString:POST_FACEBOOK shareType:(int)shareType];
    UIImage* shareImage = [self getShareImage:POST_FACEBOOK shareType:(int)shareType];
    
    SLComposeViewController *vc = [SLComposeViewController
                                   composeViewControllerForServiceType:SLServiceTypeFacebook];
    [vc setCompletionHandler:^(SLComposeViewControllerResult result){
        switch (result) {
            case SLComposeViewControllerResultDone:
                posted = YES;
                break;
            default:
                break;
        }
        if(posted == YES){
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"投稿しました" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
    [vc setInitialText:shareString];
    if (shareURLString != nil){
        [vc addURL:[NSURL URLWithString:shareURLString]];
    }
    if (shareImage != nil){
        [vc addImage:shareImage];
    }
    
    [self presentViewController:vc animated:YES completion:nil];
}
*/

- (void)postToLine:(int)shareType{
    [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"打撃/投手成績参照・打撃分析画面―Lineシェア" value:nil screen:@"打撃/投手成績参照・打撃分析画面"];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"line://msg/text/test"]] == NO) {
        [Utility showAlert:@"Lineがインストールされていません。"];
    }
    
    posted = NO;
    
    if(shareType == SHARE_TYPE_TEXT){
        NSString* shareString = [self makeShareString:POST_LINE shareType:(int)shareType];
        NSString* shareURLString = [self getShareURLString:POST_LINE shareType:(int)shareType];
        
        NSString* encodedString = [[NSString stringWithFormat:@"%@ %@",shareString, shareURLString]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSString *LINEUrlString = [NSString stringWithFormat:@"line://msg/text/%@", encodedString];
    
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINEUrlString]];
    } else if(shareType == SHARE_TYPE_IMAGE){
        UIImage* shareImage = [self getShareImage:POST_LINE shareType:(int)shareType];
        
        UIPasteboard *pasteboard = nil;

        //iOS7.0以降では共有のクリップボードしか使えない。その際クリップボードが上書きされてしまうので注意。
        if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0) {
            pasteboard = [UIPasteboard generalPasteboard];
        } else {
            pasteboard = [UIPasteboard pasteboardWithUniqueName];
        }
        
        [pasteboard setData:UIImagePNGRepresentation(shareImage) forPasteboardType:@"public.png"];
        NSString *LINEUrlString = [NSString stringWithFormat:@"line://msg/image/%@", pasteboard.name];

        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:LINEUrlString]];
    }
}

- (NSString*)makeShareString:(int)type shareType:(int)shareType {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (NSString*)getShareURLString:(int)type shareType:(int)shareType {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (UIImage*)getShareImage:(int)type shareType:(int)shareType {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (NSString*)getMailTitle:(int)type {
    NSString* term = @"";
    NSString* team = @"";
    NSString* tsusan = @"";
    NSString* today = @"";
    
    // 今日の日付を取得する
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComps
    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    today = [NSString stringWithFormat:@"（%zd年%zd月%zd日現在）",dateComps.year,dateComps.month,dateComps.day];
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    if(targetTerm.type == TERM_TYPE_ALL){
        tsusan = @"通算";
    } else if(targetTerm.type == TERM_TYPE_RECENT5){
        tsusan = @"最近5試合の";
        today = @""; // 最近５試合の場合は◯◯現在という言葉は入れない
    } else if(targetTerm.type == TERM_TYPE_YEAR){
        term = [targetTerm getTermStringForShare];
        if(targetTerm.beginyear != dateComps.year){
            // 当年以外なら◯◯現在という言葉は入れない
            today = @"";
        }
    } else if(targetTerm.type == TERM_TYPE_MONTH){
        term = [targetTerm getTermStringForShare];
        if(targetTerm.beginyear != dateComps.year || targetTerm.beginmonth != dateComps.month){
            // 当年当月以外なら◯◯現在という言葉は入れない
            today = @"";
        }
    } else if(targetTerm.type == TERM_TYPE_RANGE_YEAR){
        term = [targetTerm getTermStringForShare];
        today = @"";
    } else if(targetTerm.type == TERM_TYPE_RANGE_MONTH){
        term = [targetTerm getTermStringForShare];
        today = @"";
    }
    //「から」・「まで」で終わる場合は「の」をつけて「2015年からの」「2015年12月までの」にする。
    if([term containsString:@"から"] || [term containsString:@"まで"]){
        term = [NSString stringWithFormat:@"%@の",term];
    }
    
    NSString* targetTeam = [ConfigManager getCalcTargetTeam];
    if([targetTeam isEqualToString:@"すべて"] == NO){
        team = targetTeam;
    }
    
    // MailTitleを返す（例．2013年バットマンズ打撃成績、通算打撃成績（2013年3月27日現在））
    if (type == BATTING_RESULT) {
        return [NSString stringWithFormat:@"%@%@%@打撃成績%@",term,team,tsusan,today];
    } else {
        return [NSString stringWithFormat:@"%@%@%@投手成績%@",term,team,tsusan,today];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateStatistics];
}

@end
