//
//  LoadServerViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "LoadServerViewController.h"
#import "AppDelegate.h"
#import "S3Manager.h"
#import "ConfigManager.h"
#import "Utility.h"
#import "GameResult.h"
#import "GameResultManager.h"

@interface LoadServerViewController ()

@end

@implementation LoadServerViewController

@synthesize gadView;
@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // _migrationCdText.text = @"12345678";
    
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
    
    // TableViewの大きさ定義＆iPhone5対応
    _infoText.frame = CGRectMake(0, 275, 320, 155);
    [AppDelegate adjustForiPhone5:_infoText];
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

- (IBAction)onTap:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)loadServer:(id)sender {
    if(indicator != nil && [indicator isAnimating]){
        // ぐるぐるの最中なら無視
        return;
    }
    
    NSString* migrationCd = _migrationCdText.text;
    if(migrationCd == nil || [@"" isEqualToString:migrationCd]){
        [Utility showAlert:@"機種変更コードを入力してください。"];
        return;
    }
    int migrationCdInt = [migrationCd intValue];
    if(migrationCdInt < 10000000 || migrationCdInt > 99999999){
        [Utility showAlert:@"機種変更コードは8桁の数字を入力してください。"];
        return;
    }
    
    [self.view endEditing:YES];
    
    // 確認ダイアログを表示
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:nil
        message:@"機種変更コードを使ってデータを取り込みます。\nよろしいですか？"
        preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
        handler:^(UIAlertAction* action) {
            // ぐるぐるを出す
            indicator = [Utility getIndicatorView:self];
            [indicator startAnimating];
            [self.view addSubview:indicator];
                                                         
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            [queue addOperationWithBlock:^{
                [self restoreGameResult:[NSString stringWithFormat:@"%@/", migrationCd]];
            }];
        }];
    
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)restoreGameResult:(NSString*)migrationCd {
    NSArray* resultArray = [S3Manager S3GetFileList:migrationCd];
    
    BOOL dataExists = YES;
    NSString* message = @"";
    if(resultArray == nil){
        message = @"データの取得に失敗しました。ネットワークに接続されているかを確認してください。";
        dataExists = NO;
    } else if(resultArray.count == 0){
        message = @"データが存在しません。機種変更コードが正しいかどうかを確認してください。";
        dataExists = NO;
    }
    
    // データが取れなかったときはアラートを出して終了
    if(dataExists == NO){
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [indicator stopAnimating];
            [Utility showAlert:message];
        }];
        return;
    }
    
    int saveCount = 0;
    int sameDataCount = 0;
    
    NSMutableArray* resultFileArray = [NSMutableArray array];
    for(NSString* targetKey in resultArray){
        if([targetKey containsString:@".dat"] == NO){
            continue;
        }
        NSString* filepath = [S3Manager S3Download:targetKey];
        if(filepath != nil){
            // NSLog(@"filepath : %@", filepath);
            [resultFileArray addObject:filepath];
        }
    }
    
    NSArray* gameResultArray = [GameResultManager loadGameResultList];
    for(NSString* targetPath in resultFileArray){
        NSData* readdata = [NSData dataWithContentsOfFile:targetPath];
        GameResult* gameResult = [GameResult makeGameResult:readdata];
        if(gameResult == nil){
            // NSLog(@"GameResult is nil");
            continue;
        }
        gameResult.resultid = 0;
        
        // すでに同じデータがあるかを確認
        BOOL exists = NO;
        for(GameResult* tmpGameResult in gameResultArray){
            if([tmpGameResult.UUID isEqualToString:gameResult.UUID]){
                exists = YES;
                sameDataCount++;
                // NSLog(@"Same GameResult exists");
                break;
            }
        }
        
        if(exists == NO){
            // ファイルに保存
            [GameResultManager saveGameResult:gameResult];
            saveCount++;
            // NSLog(@"GameResult saved");
        }
    }
    
    // ファイル削除
    for(NSString* filePath in resultFileArray){
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    // ぐるぐるを止める
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [indicator stopAnimating];
        if(sameDataCount > 0){
            [Utility showAlert:[NSString stringWithFormat:@"%d件のデータを取り込みました。\n%d件は重複データのため取り込みませんでした。", saveCount, sameDataCount]];
        } else {
            [Utility showAlert:[NSString stringWithFormat:@"%d件のデータを取り込みました。", saveCount]];
        }
    }];
}

- (IBAction)updateInfo:(id)sender {
    [self.view endEditing:YES];
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
