//
//  GameResultListController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResultListController.h"
#import "AppDelegate.h"
#import "GameResultManager.h"

@interface GameResultListController ()

@end

@implementation GameResultListController

@synthesize gameResultYearList;
@synthesize gameResultListOfYear;
@synthesize gameResultListTableView;
@synthesize adView;
@synthesize bannerIsVisible;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // iPhone5対応
    [AppDelegate adjustForiPhone5:gameResultListTableView];
    
    // iAdの初期設定
    [AppDelegate adjustOriginForiPhone5:adView];
    adView.currentContentSizeIdentifier = ADBannerContentSizeIdentifierPortrait;
    adView.delegate = self;
    bannerIsVisible = NO;
    [self hiddenAdView];
}

- (void)bannerViewDidLoadAd:(ADBannerView*)banner{
    if (bannerIsVisible == NO){
        [self showAdView];
        bannerIsVisible = YES;
    }
}

-(void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError*)error{
    if (bannerIsVisible == YES){
        [self hiddenAdView];
        bannerIsVisible = NO;
    }
}

- (void)hiddenAdView {
    CGRect oldRect = gameResultListTableView.frame;
    CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y,
                                oldRect.size.width, oldRect.size.height+50);
    gameResultListTableView.frame = newRect;
    adView.hidden = YES;
}

- (void)showAdView {
    CGRect oldRect = gameResultListTableView.frame;
    CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y,
                                oldRect.size.width, oldRect.size.height-50);
    gameResultListTableView.frame = newRect;
    adView.hidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGameResultListTableView:nil];
    [self setGameResultListOfYear:nil];
    [self setAdView:nil];
    [super viewDidUnload];
}

- (void)loadGameResult {
//    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSArray* gameResultList = [GameResultManager loadGameResultList];
//    appDelegate.gameResultList = resultList;
    
    gameResultYearList = [NSMutableArray array];
    gameResultListOfYear = [NSMutableArray array];
    
    int listyear = 0;
    NSMutableArray* resultArray = [NSMutableArray array];
    
    for (int i=0; i<gameResultList.count; i++) {
        GameResult* result = [gameResultList objectAtIndex:i];
        
        if(listyear != result.year){
            [gameResultYearList addObject:[NSString stringWithFormat:@"%d年",result.year]];
            listyear = result.year;
            
            resultArray = [NSMutableArray array];
            [gameResultListOfYear addObject:resultArray];
        }
        
        [resultArray addObject:result];
    }
    
    // 試合結果が0件の場合はメッセージを表示
    if(gameResultList.count == 0){
        UILabel* initLabel = [[UILabel alloc] initWithFrame:CGRectMake(40,120,240,35)];
        initLabel.text = @" 「追加」ボタンを押して";
        initLabel.tag = 9;
        UILabel* initLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(40,155,240,35)];
        initLabel2.text = @" 試合結果を入力してください";
        initLabel2.tag = 9;
        
        [self.view addSubview:initLabel];
        [self.view addSubview:initLabel2];
    } else {
        NSMutableArray* deleteArray = [NSMutableArray array];
        for(int i=0;i<self.view.subviews.count;i++){
            UIView* view = [self.view.subviews objectAtIndex:i];
            if(view.tag == 9){
                [deleteArray addObject:view];
            }
        }
        
        for(int i=0;i<deleteArray.count;i++){
            UIView* view = [deleteArray objectAtIndex:i];
            [view removeFromSuperview];
        }
    }
    
}

-(NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* array = [gameResultListOfYear objectAtIndex:section];
    return array.count;
}

-(UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* array = [gameResultListOfYear objectAtIndex:indexPath.section];
    GameResult* result = [array objectAtIndex:indexPath.row];
    
    NSString* cellName = @"GameResultCell";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellName];
    }
    
//    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[NSString stringWithFormat:@"%d",result.resultid]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d月%d日  %@ %d-%d %@",
        result.month, result.day, result.myteam, result.myscore, result.otherscore, result.otherteam];
    
    NSMutableString* battingStr = [NSMutableString string];
    for (int i=0;i<result.battingResultArray.count;i++){
        BattingResult* battingResult = [result.battingResultArray objectAtIndex:i];
        [battingStr appendString:@" "];
        [battingStr appendString:[battingResult getResultString]];
    }
    cell.detailTextLabel.text = battingStr;
    
    return cell;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 	return gameResultYearList.count;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [gameResultYearList objectAtIndex:section];
}

- (void)tableView:(UITableView *)tableView
        commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
        forRowAtIndexPath:(NSIndexPath*)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSArray* array = [gameResultListOfYear objectAtIndex:indexPath.section];
        GameResult* result = [array objectAtIndex:indexPath.row];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"試合結果の削除"
            message:@"削除してよろしいですか？" delegate:self
            cancelButtonTitle:@"キャンセル" otherButtonTitles:@"OK", nil];
        alert.tag = result.resultid;
        [alert show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        int resultid = alertView.tag;

//        NSLog(@"Deleting resultid : %d",resultid);

        [GameResultManager removeGameResult:resultid];
        
        [self loadGameResult];
        [gameResultListTableView reloadData];
    }
    
}

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"Selected %d-%d",indexPath.section, indexPath.row);
}
*/

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    int tag = ((UIView*)sender).tag;
    
//    NSLog(@"Tag : %d",tag);
    
    if(tag == 1){
        // 追加ボタン
        appDelegate.targetGameResult = nil;
//        appDelegate.targatResultid = NO_TARGET;
    } else {
        // 個別の試合結果を選択
        NSIndexPath* indexPath = [gameResultListTableView indexPathForSelectedRow];
        
//        int section = indexPath.section;
//        int row = indexPath.row;
//        NSLog(@"Selected in Segue %d-%d",section, row);

        NSArray* array = [gameResultListOfYear objectAtIndex:indexPath.section];
        GameResult* result = [array objectAtIndex:indexPath.row];

        AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
        appDelegate.targetGameResult = result;
//        appDelegate.targatResultid = result.resultid;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [gameResultListTableView deselectRowAtIndexPath:
        [gameResultListTableView indexPathForSelectedRow] animated:NO];

    [self loadGameResult];
    [gameResultListTableView reloadData];
}

@end
