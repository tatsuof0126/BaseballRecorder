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
#import "InputViewController.h"
#import "ConfigManager.h"
#import "TrackingManager.h"
#import "Utility.h"

@interface GameResultListController ()

@end

@implementation GameResultListController

@synthesize adg = adg_;
@synthesize gameResultYearList;
@synthesize gameResultListOfYear;
@synthesize gameResultListTableView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"試合結果一覧画面"];
    
    // TableViewの大きさ定義＆iPhone5対応
    gameResultListTableView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:gameResultListTableView];
    [AppDelegate adjustOriginForBeforeiOS6:gameResultListTableView];
    
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        NSDictionary *adgparam = @{@"locationid" : @"21680", @"adtype" : @(kADG_AdType_Sp),
            @"originx" : @(0), @"originy" : @(581), @"w" : @(320), @"h" : @(50)};
        ADGManagerViewController *adgvc
            = [[ADGManagerViewController alloc] initWithAdParams:adgparam adView:self.view];
        self.adg = adgvc;
        adg_.delegate = self;
        [adg_ loadRequest];
    }
}

- (void)ADGManagerViewControllerReceiveAd:(ADGManagerViewController *)adgManagerViewController {
    // 読み込みに成功したら広告を見える場所に移動
    self.adg.view.frame = CGRectMake(0, 381, 320, 50);
    [AppDelegate adjustOriginForiPhone5:self.adg.view];
    [AppDelegate adjustOriginForBeforeiOS6:self.adg.view];
    
    // TableViewの大きさ定義＆iPhone5対応
    gameResultListTableView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:gameResultListTableView];
    [AppDelegate adjustOriginForBeforeiOS6:gameResultListTableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setGameResultListTableView:nil];
    [self setGameResultListOfYear:nil];
    [super viewDidUnload];
}

- (void)loadGameResult {
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    
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

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* array = [gameResultListOfYear objectAtIndex:section];
    return array.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* array = [gameResultListOfYear objectAtIndex:indexPath.section];
    GameResult* result = [array objectAtIndex:indexPath.row];
    
    NSString* cellName = @"GameResultCell";

    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
                                      reuseIdentifier:cellName];
    }
    
    // メイン行に試合結果（月日、勝敗、チーム、得点など）
    NSString* mainText = nil;
    int fontsize = 0;
    
    NSString* resultStr = result.myscore == result.otherscore ? @"△" :
        result.myscore > result.otherscore ? @"○" : @"●";
    
    if([ConfigManager isShowMyteamFlg] == YES){
        NSString* myteam = result.myteam;
        mainText = [NSString stringWithFormat:@"%d/%d %@ %@ %d‐%d %@",
                    result.month, result.day, resultStr, myteam,
                    result.myscore, result.otherscore, result.otherteam];
        fontsize = 15;
    } else {
        mainText = [NSString stringWithFormat:@"%d月%d日 %@ %d‐%d %@",
                    result.month, result.day, resultStr,
                    result.myscore, result.otherscore, result.otherteam];
        fontsize = 17;
    }
    
    // iOS6以上が担保されるのでAttributedTextを使ってヒラギノ角ゴで表示
    cell.textLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:fontsize];
        
    NSMutableParagraphStyle *paragrahStyle = [[NSMutableParagraphStyle alloc] init];
    paragrahStyle.lineSpacing = - 2.0f;
    paragrahStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
    NSMutableAttributedString *attributedText
        = [[NSMutableAttributedString alloc] initWithString:mainText];
        
    [attributedText addAttribute:NSParagraphStyleAttributeName
                           value:paragrahStyle
                           range:NSMakeRange(0, attributedText.length)];
    
    cell.textLabel.attributedText = attributedText;
    
    // サブ行に詳細成績（打撃成績 / 投手成績）
    NSMutableAttributedString* detailStr = [[NSMutableAttributedString alloc] initWithString:@""];
    
    NSAttributedString* blank = [[NSAttributedString alloc] initWithString:@" "];
    
    for (int i=0;i<result.battingResultArray.count;i++){
        BattingResult* battingResult = [result.battingResultArray objectAtIndex:i];
        [detailStr appendAttributedString:blank];
        NSAttributedString *btresult = [[NSAttributedString alloc]
            initWithString:[battingResult getResultShortString]
            attributes:@{NSForegroundColorAttributeName : [battingResult getResultColorForListView]}];
        [detailStr appendAttributedString:btresult];
    }
    
    if( result.inning != 0 || result.inning2 != 0 ){
        if([[[NSMutableAttributedString alloc] initWithString:@""] isEqual:detailStr] == NO){
            [detailStr appendAttributedString:[[NSAttributedString alloc] initWithString:@"  /  "]];
        } else {
            [detailStr appendAttributedString:blank];
        }
        
        [detailStr appendAttributedString:[[NSAttributedString alloc] initWithString:[result getInningString]]];
        [detailStr appendAttributedString:blank];
        [detailStr appendAttributedString:[[NSAttributedString alloc] initWithString:result.shitten == 0 ? @"無失点" : [NSString stringWithFormat:@"%d失点",result.shitten]]];
        [detailStr appendAttributedString:blank];
        [detailStr appendAttributedString:[[NSAttributedString alloc] initWithString:[result getSekininString]]];
    }
    
    cell.detailTextLabel.attributedText = detailStr;
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 	return gameResultYearList.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
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
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果一覧画面―削除" value:nil screen:@"試合結果一覧画面"];

        int resultid = [Utility convert2int:alertView.tag];
        
        [GameResultManager removeGameResult:resultid];
        
        [self loadGameResult];
        [gameResultListTableView reloadData];
    }
    
}

- (void)prepareForSegue:(UIStoryboardSegue*)segue sender:(id)sender {
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    int tag = [Utility convert2int:((UIView*)sender).tag];

    if(tag == 1){
        // 追加ボタン
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果一覧画面―追加" value:nil screen:@"試合結果一覧画面"];
        
        InputViewController* controller = [segue destinationViewController];
        controller.inputtype = INPUT_TYPE_NEW;
        
        appDelegate.targetGameResult = nil;
    } else {
        // 個別の試合結果を選択
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"試合結果一覧画面―既存選択" value:nil screen:@"試合結果一覧画面"];
        
        NSIndexPath* indexPath = [gameResultListTableView indexPathForSelectedRow];
        
        NSArray* array = [gameResultListOfYear objectAtIndex:indexPath.section];
        GameResult* result = [array objectAtIndex:indexPath.row];

        appDelegate.targetGameResult = result;
    }
}

- (void)checkUpdated {
    NSString* useVersion = [ConfigManager getUseVersion];
    NSString* nowVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    /*
    [ConfigManager setUseVersion:@"1.0"];
    NSLog(@"use version is null : %@", useVersion == nil ? @"TRUE" : @"FALSE");
    NSLog(@"use version : %@  now version : %@", useVersion, nowversion);
     */
    
    if(useVersion == nil || [useVersion isEqualToString:nowVersion] == NO || VERUP_DIALOG_VIEW == 1){
        NSArray* gameResultList = [GameResultManager loadGameResultList];
        if(gameResultList.count > 0 && [UIAlertController class]){
            // アップデート時 かつ １件以上試合結果があるときはダイアログを表示する。
            // UIAlertControllerが使える場合のみ
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"アップデートいただき\nありがとうございます" message:@"バージョン2.6では打撃成績/投手成績にセイバーメトリクスの指標（IsoD/IsoP/RC27/FIP）を追加しました。\n試合結果の入力が楽しくなりますね。" preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        
        [ConfigManager setUseVersion:nowVersion];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(adg_){
        [adg_ resumeRefresh];
    }
    
    [gameResultListTableView deselectRowAtIndexPath:
        [gameResultListTableView indexPathForSelectedRow] animated:NO];

    [self loadGameResult];
    [gameResultListTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [self checkUpdated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if(adg_){
        [adg_ pauseRefresh];
    }
}

- (void)dealloc {
    adg_.delegate = nil;
    adg_ = nil;
}

@end
