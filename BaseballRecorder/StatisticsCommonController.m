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

@interface StatisticsCommonController ()

@end

@implementation StatisticsCommonController

@synthesize gameResultList;
@synthesize gameResultListOfYear;
@synthesize yearList;
@synthesize teamList;
@synthesize targetyear;
@synthesize targetteam;
@synthesize targetPicker;
@synthesize targetToolbar;

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
    year.text = [yearList objectAtIndex:targetyear];
    team.text = [teamList objectAtIndex:targetteam];
}

- (void)makeResultPicker {
    // すでにPickerが立ち上がっていたら無視
    if( targetPicker != nil ){
        return;
    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGFloat width = rect.size.width;
    CGFloat height = rect.size.height;
    
    targetPicker = [[UIPickerView alloc] init];
    
    targetPicker.center = CGPointMake(width/2, height+125+60);
    targetPicker.delegate = self;  // デリゲートを自分自身に設定
    targetPicker.dataSource = self;  // データソースを自分自身に設定
    targetPicker.showsSelectionIndicator = YES;
    
    [targetPicker selectRow:targetyear inComponent:0 animated:NO];
    [targetPicker selectRow:targetteam inComponent:1 animated:NO];
    
    targetToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, height, 320, 44)];
    targetToolbar.barStyle = UIBarStyleBlack;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"閉じる"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarBackButton:)];
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"設定"
        style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButton:)];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    NSArray *items = [NSArray arrayWithObjects:backButton, spacer, doneButton, nil];
    
    [targetToolbar setItems:items animated:YES];
    
    [self.view addSubview:targetToolbar];
    [self.view addSubview:targetPicker];
    
    //アニメーションの設定開始
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut]; //アニメーションの種類を設定
    [UIView setAnimationDuration:0.3];    // 時間の指定
    targetPicker.center = CGPointMake(width/2, height-125);    // 表示する中心座標を表示画面中央に
    targetToolbar.center = CGPointMake(width/2, height-255);
    
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
    
    targetPicker = nil;
    targetToolbar = nil;
}

- (void)toolbarDoneButton:(id)sender {
    targetyear = [targetPicker selectedRowInComponent:0];
    targetteam = [targetPicker selectedRowInComponent:1];
    
    [ConfigManager setCalcTargetYear:[yearList objectAtIndex:targetyear]];
    [ConfigManager setCalcTargetTeam:[teamList objectAtIndex:targetteam]];
    
    [self updateStatistics];
    
    [targetPicker removeFromSuperview];
    [targetToolbar removeFromSuperview];
    
    targetPicker = nil;
    targetToolbar = nil;
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
    
    today = [NSString stringWithFormat:@"（%d年%d月%d日現在）",dateComps.year,dateComps.month,dateComps.day];
    
    if(targetyear == 0){
        // targetyearが0（すべて）なら通算成績
        tsusan = @"通算";
    } else if(targetyear == 1){
        // targetyearが1（最近５試合）なら最近５試合の成績
        tsusan = @"最近5試合の";
    } else {
        year = [yearList objectAtIndex:targetyear];
        
        // 今日の年を取得する
        NSString* todayYear = [NSString stringWithFormat:@"%d年",dateComps.year];
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
