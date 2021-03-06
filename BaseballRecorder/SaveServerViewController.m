//
//  SaveServerViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "SaveServerViewController.h"
#import "AppDelegate.h"
#import "S3Manager.h"
#import "Utility.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "ConfigManager.h"

@interface SaveServerViewController ()

@end

@implementation SaveServerViewController

@synthesize gadView;
@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLabel];
    
    // お知らせを表示
    [AppDelegate adjustForiPhone5:_infoText];
    [self updateInfoText];
    
    // お知らせの取得日が１日以上前なら再取得を試みる
    NSDate* updateDate = [ConfigManager getS3InfoUpdateDate];
    NSTimeInterval since = [[NSDate date] timeIntervalSinceDate:updateDate];
    if(updateDate == nil || since > 24*60*60){
        [self updateInfo];
    }
        
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
    
    // TextViewの大きさ定義＆iPhone5対応
    _infoText.frame = CGRectMake(0, 370, 320, 60);
    [AppDelegate adjustForiPhone5:_infoText];
}

- (void)updateLabel {
    _migrationIdLabel.text = [ConfigManager getMigrationId];
    _migrationPasswordLabel.text = [ConfigManager getMigrationPassword];
    
    NSDate* createDate = [ConfigManager getCreateDate];
    if(createDate != nil){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        [formatter setLocale:[NSLocale systemLocale]];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        _createDateLabel.text = [formatter stringFromDate:createDate];
    } else {
        _createDateLabel.text = @"";
    }
}

- (void)updateInfoText {
    NSString* infoText = [ConfigManager getS3Info];
    _infoText.text = infoText;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveServer:(id)sender {
    if(indicator != nil && [indicator isAnimating]){
        // ぐるぐるの最中なら無視
        return;
    }
    
    // データ件数が０件なら保存しない
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    if(gameResultList == nil || gameResultList.count == 0){
        [Utility showAlert:@"試合結果がありません。"];
        return;
    }
    
    // １日に６回以上は登録させない
    int createCount = [ConfigManager getCreateCount];
    if(createCount >= 5 && [Utility isToday:[ConfigManager getCreateDate]]){
        [Utility showAlert:@"１日にできるバックアップは５回までです。"];
        return;
    }
    
    // 最新形式で保存しなおし
    for(GameResult* gameResult in gameResultList){
        if([gameResult isLatestVersion] == NO){
            [GameResultManager saveGameResult:gameResult];
        }
    }
    
    // ぐるぐるを出す
    indicator = [Utility getIndicatorView:self];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self saveGameResult];
    }];
}

- (void)saveGameResult {
    int uploadCount = 0;
    BOOL failed = NO;
    
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    
    NSString* migrationId = [GameResultManager getMigrationId];
    NSString* migrationPassword = [GameResultManager getMigrationPassword:migrationId];
    if(migrationId == nil){
        failed = YES;
    }
    
    if(failed == NO){
        NSString* prefix = [NSString stringWithFormat:@"%@/", migrationId];
        NSArray* gameResultList = [GameResultManager loadGameResultList];
        for(GameResult* gameResult in gameResultList){
            NSString* filename = [NSString stringWithFormat:@"gameresult%d.dat", gameResult.resultid];
            NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
        
            BOOL succeed = [S3Manager S3Upload:prefix fileName:filename filePath:filepath];
            if(succeed == YES){
                uploadCount++;
            } else {
                failed = YES;
            }
        }
    }
    
    // ぐるぐるを止める
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [indicator stopAnimating];
        if(failed == NO){
            [ConfigManager setMigrationId:migrationId];
            [ConfigManager setMigrationPassword:migrationPassword];
            int createCount = 1;
            if([Utility isToday:[ConfigManager getCreateDate]]){
                createCount = [ConfigManager getCreateCount] + 1;
            }
            [ConfigManager setCreateCount:createCount];
            [ConfigManager setCreateDate:[NSDate date]];
            
            [self updateLabel];
            
            [Utility showAlert:[NSString stringWithFormat:@"%d件のデータをバックアップしました。\nIDとパスワードは画面を確認してください。", uploadCount]];
        } else {
            [Utility showAlert:@"データのバックアップに失敗しました。ネットワークに接続されているかを確認してください。"];
        }
    }];
    
}

- (IBAction)updateInfo:(id)sender {
    [self updateInfo];
}

- (void)updateInfo {
    if(indicator != nil && [indicator isAnimating]){
        // ぐるぐるの最中なら無視
        return;
    }
    
    // ぐるぐるを出す
    indicator = [Utility getIndicatorView:self];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self loadInfo];
    }];
}

- (void)loadInfo {
    NSString* tempInfoPath = [S3Manager S3GetInfo];
    NSString* infoString = [NSString stringWithContentsOfFile:tempInfoPath encoding:NSUTF8StringEncoding error:nil];
    
    // NSLog(@"info => %@", infoString);
    
    if(infoString != nil && [infoString isEqualToString:@""] == NO){
        [ConfigManager setS3Info:infoString];
        [ConfigManager setS3InfoUpdateDate:[NSDate date]];
    }
    
    [[NSFileManager defaultManager] removeItemAtPath:tempInfoPath error:nil];
    
    // ぐるぐるを止める
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self updateInfoText];
        [indicator stopAnimating];
    }];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
