//
//  SaveServerViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "SaveServerViewController.h"
#import "APIManager.h"
#import "S3Manager.h"
#import "Utility.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "ConfigManager.h"

@interface SaveServerViewController ()

@end

@implementation SaveServerViewController

@synthesize indicator;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self updateLabel];
}

- (void)updateLabel {
    _migrationCdLabel.text = [ConfigManager getMigrationCd];
    
    NSDate* createDate = [ConfigManager getCreateDate];
    if(createDate != nil){
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy年MM月dd日"];
        [formatter setLocale:[NSLocale systemLocale]];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        _createDateLabel.text = [formatter stringFromDate:createDate];
    }
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
    // データ件数が０件なら保存しない
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    if(gameResultList == nil || gameResultList.count == 0){
        [Utility showAlert:@"試合結果がありません。"];
        return;
    }
    
    // １日に６回以上は登録させない
    int createCount = [ConfigManager getCreateCount];
    if(createCount >= 5 && [Utility isToday:[ConfigManager getCreateDate]]){
        [Utility showAlert:@"１日に発行できる機種変更コードは５個までです。"];
        return;
    }
    
    // ぐるぐるを出す
    indicator = [Utility getIndicatorView:self];
    [indicator startAnimating];
    [self.view addSubview:indicator];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        [self saveGameResult:gameResultList];
    }];
}

- (void)saveGameResult:(NSArray*)gameResultList {
    int uploadCount = 0;
    BOOL failed = NO;
    
    
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    
    NSString* migrationCd = [self getMigrationCd];
    NSString* prefix = [NSString stringWithFormat:@"%@/", migrationCd];
    for(GameResult* gameResult in gameResultList){
        NSString* filename = [NSString stringWithFormat:@"gameresult%d.dat",gameResult.resultid];
        NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
        
        BOOL succeed = [S3Manager S3Upload:prefix fileName:filename filePath:filepath];
        if(succeed == YES){
            uploadCount++;
        } else {
            failed = YES;
        }
    }
    
    // ぐるぐるを止める
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [indicator stopAnimating];
        if(failed == NO){
            [ConfigManager setMigrationCd:migrationCd];
            int createCount = 1;
            if([Utility isToday:[ConfigManager getCreateDate]]){
                createCount = [ConfigManager getCreateCount] + 1;
            }
            [ConfigManager setCreateCount:createCount];
            [ConfigManager setCreateDate:[NSDate date]];
            
            [self updateLabel];
            
            [Utility showAlert:[NSString stringWithFormat:@"%d件のデータをサーバーにアップロードしました。\n機種変更コードは［%@］です。", uploadCount, migrationCd]];
        } else {
            [Utility showAlert:@"アップロードに失敗しました。しばらくしてからお試しください。"];
        }
    }];
    
}

- (NSString*)getMigrationCd {
    int migrationCdInt = 0;
    while(true){
        migrationCdInt = arc4random_uniform(89999999) + 10000000;
        
        NSArray* filelist = [S3Manager S3GetFileList:[NSString stringWithFormat:@"%d/", migrationCdInt]];
        if(filelist != nil && filelist.count == 0){
            break;
        }
    }
    
    return [NSString stringWithFormat:@"%d", migrationCdInt];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
