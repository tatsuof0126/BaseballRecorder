//
//  LoadServerViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "LoadServerViewController.h"
#import "S3Manager.h"
#import "Utility.h"
#import "GameResult.h"
#import "GameResultManager.h"

@interface LoadServerViewController ()

@end

@implementation LoadServerViewController

@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _migrationCdText.text = @"12345678";

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
    
    // ぐるぐるを出す
    indicator = [Utility getIndicatorView:self];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self restoreGameResult:[NSString stringWithFormat:@"%@/", migrationCd]];
    }];

}

- (void)restoreGameResult:(NSString*)migrationCd {
    NSArray* resultArray = [S3Manager S3GetFileList:migrationCd];
    int saveCount = 0;
    int sameDataCount = 0;
    
    NSMutableArray* resultFileArray = [NSMutableArray array];
    for(NSString* targetKey in resultArray){
        if([targetKey containsString:@".dat"] == NO){
            continue;
        }
        NSString* filepath = [S3Manager S3Download:targetKey];
        if(filepath != nil){
            NSLog(@"filepath : %@", filepath);
            [resultFileArray addObject:filepath];
        }
    }
    
    NSArray* gameResultArray = [GameResultManager loadGameResultList];
    for(NSString* targetPath in resultFileArray){
        NSData* readdata = [NSData dataWithContentsOfFile:targetPath];
        GameResult* gameResult = [GameResult makeGameResult:readdata];
        if(gameResult == nil){
            NSLog(@"GameResult is nil");
            continue;
        }
        gameResult.resultid = 0;
        
        // すでに同じデータがあるかを確認
        BOOL exists = NO;
        for(GameResult* tmpGameResult in gameResultArray){
            if([tmpGameResult.UUID isEqualToString:gameResult.UUID]){
                exists = YES;
                sameDataCount++;
                NSLog(@"Same GameResult exists");
                break;
            }
        }
        
        if(exists == NO){
            // ファイルに保存
            [GameResultManager saveGameResult:gameResult];
            saveCount++;
            NSLog(@"GameResult saved");
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

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
