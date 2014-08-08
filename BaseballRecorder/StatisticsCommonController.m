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
#import "AppDelegate.h"
#import "Utility.h"

@interface StatisticsCommonController ()

@end

@implementation StatisticsCommonController

@synthesize gameResultList;
@synthesize gameResultListOfYear;
@synthesize yearList;
@synthesize teamList;
@synthesize targetyear;
@synthesize targetteam;
@synthesize pickerBaseView;
@synthesize targetPicker;
@synthesize targetToolbar;
@synthesize posted;

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


-(void)nadViewDidFinishLoad:(NADView *)adView {
    // 子クラスでオーバーライドする前提
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateStatistics {
    [self loadGameResult];
    [self setCalcTarget];
    NSArray* gameResultListForCalc = [self getGameResultListForCalc];
    [self showStatistics:gameResultListForCalc];
}

- (void)loadGameResult {
    gameResultList = [GameResultManager loadGameResultList];
    
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

- (NSArray*)getGameResultListForCalc {
    NSMutableArray* gameResultListForCalc = nil;
    
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
    
    // 「最近５試合」の場合は直近の５件に絞る
    if (targetyear == RECENT5_TARGET) {
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

- (void)showTarget:(UILabel*)year team:(UILabel*)team {
//    NSString* oldyear = year.text;
//    NSString* oldteam = team.text;
    year.text = [yearList objectAtIndex:targetyear];
    team.text = [teamList objectAtIndex:targetteam];
    
    // 変更していなければNOを返す
//    if([oldyear isEqualToString:year.text] && [oldteam isEqualToString:team.text]){
//        return NO;
//    }
//    return YES;
}

- (void)makeResultPicker {
    // すでにPickerが立ち上がっていたら無視
    if( targetPicker != nil ){
        return;
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
    
    [targetPicker selectRow:targetyear inComponent:0 animated:NO];
    [targetPicker selectRow:targetteam inComponent:1 animated:NO];
    
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
    return component == 0 ? yearList.count : teamList.count;
}

-(NSString*)pickerView:(UIPickerView*)pickerView
           titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return component == 0 ? [yearList objectAtIndex:row] : [teamList objectAtIndex:row];
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
    targetyear = [Utility convert2int:[targetPicker selectedRowInComponent:0]];
    targetteam = [Utility convert2int:[targetPicker selectedRowInComponent:1]];
    
    [ConfigManager setCalcTargetYear:[yearList objectAtIndex:targetyear]];
    [ConfigManager setCalcTargetTeam:[teamList objectAtIndex:targetteam]];
    
    [self updateStatistics];
    
    [targetPicker removeFromSuperview];
    [targetToolbar removeFromSuperview];
    [pickerBaseView removeFromSuperview];
    
    targetPicker = nil;
    targetToolbar = nil;
    pickerBaseView = nil;
}

- (void)shareStatistics {
    UIActionSheet* actionSheet = [[UIActionSheet alloc] init];
    actionSheet.delegate = self;
    [actionSheet addButtonWithTitle:@"Twitterにつぶやく"];
    [actionSheet addButtonWithTitle:@"Facebookに投稿"];
    [actionSheet addButtonWithTitle:@"キャンセル"];
    actionSheet.cancelButtonIndex = 2;
    [actionSheet showInView:self.view.window];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            [self postToTwitter];
            break;
        case 1:
            [self postToFacebook];
            break;
    }
}

- (void)postToTwitter {
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_TWITTER];
    NSString* shareURLString = [self getShareURLString:POST_TWITTER];
    UIImage* shareImage = [self getShareImage:POST_TWITTER];
    
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

- (void)postToFacebook {
    posted = NO;
    
    NSString* shareString = [self makeShareString:POST_FACEBOOK];
    NSString* shareURLString = [self getShareURLString:POST_FACEBOOK];
    UIImage* shareImage = [self getShareImage:POST_FACEBOOK];
    
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


- (NSString*)makeShareString:(int)type {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (NSString*)getShareURLString:(int)type {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (UIImage*)getShareImage:(int)type {
    // 子クラスでオーバーライドする前提
    return nil;
}

- (NSString*)getMailTitle:(int)type {
    NSString* year = @"";
    NSString* team = @"";
    NSString* tsusan = @"";
    NSString* today = @"";
    
    // 今日の日付を取得する
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDate *date = [NSDate date];
    NSDateComponents *dateComps
    = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    
    today = [NSString stringWithFormat:@"（%zd年%zd月%zd日現在）",dateComps.year,dateComps.month,dateComps.day];
    
    if(targetyear == 0){
        // targetyearが0（すべて）なら通算成績
        tsusan = @"通算";
    } else if(targetyear == 1){
        // targetyearが1（最近５試合）なら最近５試合の成績
        tsusan = @"最近5試合の";
    } else {
        year = [yearList objectAtIndex:targetyear];
        
        // 今日の年を取得する
        NSString* todayYear = [NSString stringWithFormat:@"%zd年",dateComps.year];
        if([year isEqualToString:todayYear] == NO){
            // 年指定かつ去年以前の年なら「◯日現在」の文言は追加しない
            today = @"";
        }
    }
    
    if(targetteam != 0){
        team = [teamList objectAtIndex:targetteam];
    }
    
    // MailTitleを返す（例．2013年バットマンズ打撃成績、通算打撃成績（2013年3月27日現在））
    if (type == BATTING_RESULT) {
        return [NSString stringWithFormat:@"%@%@%@打撃成績%@",year,team,tsusan,today];
    } else {
        return [NSString stringWithFormat:@"%@%@%@投手成績%@",year,team,tsusan,today];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self updateStatistics];
}

@end
