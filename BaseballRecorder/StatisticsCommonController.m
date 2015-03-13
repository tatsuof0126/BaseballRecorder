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

/*
- (void)loadGameResult {
//    gameResultList = [GameResultManager loadGameResultList];
    
    yearList = [NSMutableArray array];
    teamList = [NSMutableArray array];
    gameResultListOfYear = [NSMutableArray array];
    
    [yearList addObject:@"すべて"];
    [yearList addObject:@"最近5試合"];
    [teamList addObject:@"すべて"];
    [gameResultListOfYear addObject:gameResultList];
    [gameResultListOfYear addObject:gameResultList]; // とりあえず全件を登録
    
    int listyear = -999;
    NSMutableArray* resultArray = [NSMutableArray array];
    for (int i=0; i<gameResultList.count; i++) {
        GameResult* result = [gameResultList objectAtIndex:i];
        
        if(listyear != result.year){
            [yearList addObject:[NSString stringWithFormat:@"%d年",result.year]];
            listyear = result.year;
            
            resultArray = [NSMutableArray array];
            [gameResultListOfYear addObject:resultArray];
        }
        
        [resultArray addObject:result];        
    }
    
    for (int i=0; i<gameResultList.count; i++) {
        GameResult* result = [gameResultList objectAtIndex:i];
        
        NSString* team = result.myteam;
        
        if ([teamList containsObject:team] == NO){
            [teamList addObject:team];
        }
    }
}
*/

/*
- (void)setCalcTarget {
    NSString* targetYearStr = [ConfigManager getCalcTargetYear];
    NSString* targetTeamStr = [ConfigManager getCalcTargetTeam];
    
    targetyear = ALL_TARGET;
    targetteam = ALL_TARGET;
    
    BOOL yearFlg = NO;
    BOOL teamFlg = NO;
    
    for(int i=0;i<yearList.count;i++){
        if([targetYearStr isEqualToString:[yearList objectAtIndex:i]]){
            targetyear = i;
            yearFlg = YES;
            break;
        }
    }
    
    for(int i=0;i<teamList.count;i++){
        if([targetTeamStr isEqualToString:[teamList objectAtIndex:i]]){
            targetteam = i;
            teamFlg = YES;
            break;
        }
    }
    
    if(yearFlg == NO){
        [ConfigManager setCalcTargetYear:@"すべて"];
    }
    if(teamFlg == NO){
        [ConfigManager setCalcTargetTeam:@"すべて"];
    }
}
 */

- (NSArray*)getGameResultListForCalc {
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    NSString* targetTeam = [ConfigManager getCalcTargetTeam];
    
    if ([targetTeam isEqualToString:@"すべて"]) {
        targetTeam = @"";
    }
    
    NSMutableArray* gameResultListForCalc = [NSMutableArray arrayWithArray:
        [GameResultManager loadGameResultList:targetTerm targetTeam:targetTeam]];
    
/*
    NSArray* listOfYear = [gameResultListOfYear objectAtIndex:targetyear];
    NSString* targetTeamname = [teamList objectAtIndex:targetteam];
    
    if(targetteam == ALL_TARGET){
        gameResultListForCalc = [NSMutableArray arrayWithArray:listOfYear];
    } else {
        gameResultListForCalc = [NSMutableArray array];
        
        for(int i=0;i<listOfYear.count;i++){
            GameResult* result = [listOfYear objectAtIndex:i];
            if([targetTeamname isEqualToString:result.myteam] == YES){
                [gameResultListForCalc addObject:result];
            }
        }
    }
*/
    
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

/*
- (void)showTarget:(UILabel*)year team:(UILabel*)team {
//    NSString* oldyear = year.text;
//    NSString* oldteam = team.text;
//    year.text = [yearList objectAtIndex:targetyear];
//    team.text = [teamList objectAtIndex:targetteam];
    
    year.text = [[ConfigManager getCalcTargetTerm] getTermString];
    team.text = [ConfigManager getCalcTargetTeam];
    
    
    // 変更していなければNOを返す
//    if([oldyear isEqualToString:year.text] && [oldteam isEqualToString:team.text]){
//        return NO;
//    }
//    return YES;
}
*/

- (void)showTarget:(UILabel*)year team:(UILabel*)team leftBtn:(UIButton*)leftBtn rightBtn:(UIButton*)rightBtn {
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    
    year.text = [targetTerm getTermString];
    team.text = [ConfigManager getCalcTargetTeam];
    
    // 左右の矢印を出すかどうかを判定
    NSArray* targetTermList = [TargetTerm getTargetTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
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
            if(firstTerm != nil && firstTerm.year > targetTerm.year){
                leftBtn.hidden = NO;
            }
            if(lastTerm != nil && targetTerm.year > lastTerm.year){
                rightBtn.hidden = NO;
            }
            break;
        }
        case TERM_TYPE_MONTH:{
            if(firstTerm != nil &&
               (firstTerm.year > targetTerm.year ||
                (firstTerm.year == targetTerm.year && firstTerm.month > targetTerm.month))){
                leftBtn.hidden = NO;
            }
            if(lastTerm != nil &&
               (targetTerm.year > lastTerm.year ||
                (targetTerm.year == lastTerm.year && targetTerm.month > lastTerm.month))){
                rightBtn.hidden = NO;
            }
            break;
        }
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
    
    NSArray* targetTermList = [TargetTerm getTargetTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
    
    TargetTerm* newTargetTerm = targetTermList.firstObject;
    for (TargetTerm* compTerm in targetTermList){
        if(targetTerm.type == TERM_TYPE_YEAR &&
           (targetTerm.year >= compTerm.year)){
            break;
        }
        if(targetTerm.type == TERM_TYPE_MONTH &&
           (targetTerm.year > compTerm.year ||
            (targetTerm.year == compTerm.year && targetTerm.month >= compTerm.month))){
            break;
        }
        newTargetTerm = compTerm;
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
    
    NSArray* targetTermList = [TargetTerm getTargetTermList:targetTerm.type gameResultList:[GameResultManager loadGameResultList]];
    
    TargetTerm* newTargetTerm = targetTerm;
    for (TargetTerm* compTerm in targetTermList){
        if(targetTerm.type == TERM_TYPE_YEAR &&
           (targetTerm.year > compTerm.year)){
            newTargetTerm = compTerm;
            break;
        }
        if(targetTerm.type == TERM_TYPE_MONTH &&
           (targetTerm.year > compTerm.year ||
            (targetTerm.year == compTerm.year && targetTerm.month > compTerm.month))){
               newTargetTerm = compTerm;
               break;
           }
    }
    
    if(newTargetTerm != nil){
        [ConfigManager setCalcTargetTerm:newTargetTerm];
    }
    
    [self updateStatistics];
    
}

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

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView*)pickerView{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView*)pickerView numberOfRowsInComponent:(NSInteger)component {
    return component == 0 ? termList.count : teamList.count;
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return component == 0 ? [[termList objectAtIndex:row] getTermString] : [teamList objectAtIndex:row];
}

- (void)toolbarBackButton:(UIBarButtonItem*)sender {
    [targetPicker removeFromSuperview];
    [targetToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    
    targetPicker = nil;
    targetToolbar = nil;
    pickerBaseView = nil;
}

- (void)toolbarDoneButton:(id)sender {
//    targetyear = [Utility convert2int:[targetPicker selectedRowInComponent:0]];
//    targetteam = [Utility convert2int:[targetPicker selectedRowInComponent:1]];
    
//    [ConfigManager setCalcTargetYear:[yearList objectAtIndex:targetyear]];
    
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
    NSString* targetTeam = [ConfigManager getCalcTargetTeam];
    
    if(targetTerm.type == TERM_TYPE_ALL){
        tsusan = @"通算";
    } else if(targetTerm.type == TERM_TYPE_RECENT5){
        tsusan = @"最近5試合の";
        today = @""; // 最近５試合の場合は◯◯現在という言葉は入れない
    } else if(targetTerm.type == TERM_TYPE_YEAR){
        term = [targetTerm getTermString];
        if(targetTerm.year != dateComps.year){
            // 当年以外なら◯◯現在という言葉は入れない
            today = @"";
        }
    } else if(targetTerm.type == TERM_TYPE_MONTH){
        term = [targetTerm getTermString];
        if(targetTerm.year != dateComps.year || targetTerm.month != dateComps.month){
            // 当年当月以外なら◯◯現在という言葉は入れない
            today = @"";
        }
    }
    
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
