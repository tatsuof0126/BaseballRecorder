//
//  GameResultManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/27.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResultManager.h"
#import "S3Manager.h"
#import "TrackingManager.h"

@implementation GameResultManager

+ (void)saveGameResult:(GameResult*)gameResult {
    if(gameResult.resultid == 0){
        gameResult.resultid = [self getNewResultCount];
    }
    
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    NSString* filename = [NSString stringWithFormat:@"gameresult%d.dat",gameResult.resultid];
    NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
    
    NSData* data = [gameResult getGameResultNSData];
    
    [data writeToFile:filepath atomically:YES];
}

+ (void)removeGameResult:(int)resultid {
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    NSString* filename = [NSString stringWithFormat:@"gameresult%d.dat",resultid];
    NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
    
    [[NSFileManager defaultManager] removeItemAtPath:filepath error:nil];
}

+ (GameResult*)loadGameResult:(int)resultid {
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    NSString* filename = [NSString stringWithFormat:@"gameresult%d.dat",resultid];
    NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
    
//    NSLog(@"filename : %@",filename);
        
    NSData* readdata = [NSData dataWithContentsOfFile:filepath];
        
    GameResult* gameResult = [GameResult makeGameResult:readdata];
    
    // nilが返ってきたらとりあえずresultidだけセットした空オブジェクトを返す
    if(gameResult == nil){
        gameResult = [[GameResult alloc] init];
        gameResult.resultid = resultid;
    }
    
    return gameResult;
}

+ (NSArray*)loadGameResultList {
    NSMutableArray* resultList = [NSMutableArray array];
    
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    NSArray* filenameArray = [[NSFileManager defaultManager]subpathsAtPath:dirpath];

    // NSLog(@"dirpath -> %@",dirpath);

    for (int i=0; i<filenameArray.count; i++) {
        NSString* filename = [filenameArray objectAtIndex:i];
        NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
        
        // NSLog(@"filename -> %@",filename);
        
        if([filename isEqualToString:@"shareimage.igo"]){
            continue;
        }
        
        if([filename containsString:@"gameresult"] == NO){
            NSString* message = [NSString stringWithFormat:@"filename -> %@",filename];
            [TrackingManager sendEventTracking:@"Warning" action:@"Warning" label:message value:nil screen:@"GameResultManager"];
            // NSLog(@"WARNING -> %@", message);
        }
        
        NSData* readdata = [NSData dataWithContentsOfFile:filepath];
        
        GameResult* gameResult = [GameResult makeGameResult:readdata];
        
        // nilが返ってきたらリストに追加しない
        if(gameResult != nil){
            [resultList addObject:gameResult];
        }
    }

    NSArray* returnArray = [resultList sortedArrayUsingSelector:@selector(compareDate:)];
    
    return returnArray;
}

+ (NSArray*)loadGameResultList:(TargetTerm*)targetTerm targetTeam:(NSString*)targetTeam {
    NSArray* allGameResultList = [GameResultManager loadGameResultList];

    NSMutableArray* resultList = [NSMutableArray array];
    for(GameResult* gameResult in allGameResultList){
        if([targetTerm isInTargetTeam:gameResult] &&
            ([targetTeam isEqualToString:@""] || [targetTeam isEqualToString:gameResult.myteam])){
            // 期間が範囲内でチーム名が一致していればリストに加える
            [resultList addObject:gameResult];
        }
    }
    
    return resultList;
}

+ (int)getNewResultCount {
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    
    int count = 1;
    while (YES) {
        NSString* tmpfilename = [NSString stringWithFormat:@"gameresult%d.dat",count];
        NSString* tmpfilepath = [dirpath stringByAppendingPathComponent:tmpfilename];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:tmpfilepath] == NO){
            break;
        }
        count++;
    }
    
    return count;
}

+ (void)makeSampleData {
    
    NSArray* sampleGameResultArray =
    [NSArray arrayWithObjects:
     @"V6,73475E3B-D322-4A93-94E6-50B66E56F80F\n1,2015,3,8,光が丘公園,杉並タイガース,練馬ダイコンズ,6,4,1,0,1\n\n6,2,7,2,8,7,0,13\n6,0,5,0,4,2,1,4,1,1,1\n",
     @"V6,DE426219-5EE5-42B9-BA08-EDC007C47EEA\n10,2015,3,25,光が丘公園,杉並タイガース,蒲田オリオンズ,4,6,0,0,0\n\n4,1,8,7,0,12,8,2\n1,0,1,0,2,1,0,1,0,0,0\n",
     @"V6,4BDB54F7-2D07-4740-8D7E-1102705902DB\n11,2015,3,23,光が丘公園,杉並タイガース,蒲田オリオンズ,3,2,0,0,1\n\n9,2,0,16,6,7\n7,0,5,0,3,2,0,2,1,0,1\n",
     @"V6,EEC6FB66-6986-43FF-B868-050D3FD435F9\n12,2015,3,10,光が丘公園,杉並タイガース,品川ファイターズ,2,7,1,0,0\n\n9,7,2,2,6,1\n2,0,1,0,1,1,0,2,2,0,2\n",
     @"V6,BBD79DE5-C22E-4ECA-B703-2A57E8BFD3F4\n13,2015,3,27,光が丘公園,杉並タイガース,世田谷ジャイアンツ,12,3,3,2,1\n\n11,9,6,1,4,7,0,12,8,7\n4,2,4,0,4,2,0,2,1,0,1\n",
     @"V6,36DCA4E6-D391-4326-9693-1F8A2CDA9B99\n2,2015,3,1,光が丘公園,杉並タイガース,蒲田オリオンズ,4,4,0,1,0\n\n6,1,0,14,6,2,4,1\n0,0,0,0,0,0,0,0,0,0,0\n",
     @"V6,BA118E74-F04F-4977-90C9-C526AAEBF042\n3,2015,3,15,光が丘公園,杉並タイガース,練馬ダイコンズ,3,7,1,0,1\n\n5,6,7,7,9,2,4,1\n0,0,0,0,0,0,0,0,0,0,0\n",
     @"V6,97C55549-85A5-4EA3-92D0-6DB798C7B7D1\n4,2015,3,15,光が丘公園,杉並タイガース,品川ファイターズ,7,0,3,1,0\n\n7,2,10,10,0,14,8,8\n0,0,0,0,0,0,0,0,0,0,0\n",
     @"V6,6B85433D-131B-46F8-9595-854E64E0BFCB\n5,2015,2,3,光が丘公園,杉並タイガース,世田谷ジャイアンツ,5,4,0,0,0\n\n7,7,6,1,5,7,3,1\n1,0,1,0,0,0,0,0,0,0,4\n",
     @"V6,0B1BAB66-15C7-4EF8-8F60-72D879250A02\n6,2015,10,19,光が丘公園,杉並タイガース,練馬ダイコンズ,2,4,1,0,0\n\n6,1,9,7,3,2,0,15,8,2\n0,0,0,0,0,0,0,0,0,0,0\n",
     @"V6,0E3A38CF-93FE-4A16-83D2-D109D6A7BC83\n7,2015,5,5,光が丘公園,杉並タイガース,世田谷ジャイアンツ,5,5,1,1,0\n\n7,8,6,3,4,1,6,7\n1,0,2,0,1,1,0,1,1,0,0\n",
     @"V6,59FEB27F-DCC7-48AA-85F5-3BFD7C0275FC\n8,2015,11,10,光が丘公園,杉並タイガース,品川ファイターズ,5,4,0,0,0\n\n0,14,5,2,8,4,0,12,3,7\n0,0,0,0,0,0,0,0,0,0,0\n",
     @"V6,AF485EE2-A4FE-4040-9D49-9325E1C54BE3\n9,2015,6,21,光が丘公園,杉並タイガース,練馬ダイコンズ,6,3,0,0,0\n\n1,11,9,2,6,5,0,15,11,8\n0,0,0,0,0,0,0,0,0,0,0\n",
     nil];
    
    for (NSString* gameResultStr in sampleGameResultArray){
        NSData* data = [gameResultStr dataUsingEncoding:NSUTF8StringEncoding];
        GameResult* gameResult = [GameResult makeGameResult:data];
        
        // 打席の結果を1000件入れてみる
        // [self addSampleBattingResult:gameResult count:25];
        
        [self saveGameResult:gameResult];
    }
}

+ (void)addSampleBattingResult:(GameResult*)gameResult count:(int)count {
    for(int i=0; i<count; i++){
        int position = (int)arc4random_uniform(14);
        int result = (int)arc4random_uniform(18);
        int rand = (int)arc4random_uniform(4);
        BattingResult *battingResult = [BattingResult makeBattingResult:position result:result];
        if(battingResult != nil){
            if(rand != 2 &&
               (position == 9 || position == 11 || position == 13)){
                // 打撃成績を偏らせるために無視
            } else {
                [gameResult addBattingResult:battingResult];
            }
        }
    }
}

+ (NSString*)getMigrationId {
    int migrationIdInt = 0;
    while(true){
        migrationIdInt = arc4random_uniform(89999999) + 10000000;
        
        // iPhoneで発行するIDは3で割り切れることにする
        if(migrationIdInt % 3 != 0){
            continue;
        }
        
        // すでにそのIDが使われていないか確認
        NSArray* filelist = [S3Manager S3GetFileList:[NSString stringWithFormat:@"%d/", migrationIdInt]];
        if(filelist == nil){
            return nil;
        }
        
        if(filelist != nil && filelist.count == 0){
            break;
        }
    }
    
    return [NSString stringWithFormat:@"%d", migrationIdInt];
}

// MigrationPasswordの生成方法
// １桁目：１桁目〜４桁目を７倍したときの先頭１桁
// ２桁目：１桁目〜４桁目を７倍したときの末尾１桁
// ３桁目：１桁目〜４桁目を７倍したときの末尾２桁
// ４桁目：５桁目〜８桁目を３倍したときの末尾１桁
// ５桁目：５桁目〜８桁目を３倍したときの末尾２桁
// ６桁目：５桁目〜８桁目を３倍したときの末尾３桁
+ (NSString*)getMigrationPassword:(NSString*)migrationId {
    if(migrationId == nil || [migrationId length] < 8){
        return nil;
    }
    
    NSString* id1234 = [migrationId substringWithRange:NSMakeRange(0, 4)];
    NSString* id5678 = [migrationId substringWithRange:NSMakeRange(4, 4)];
    
    NSString* id1234By7 = [NSString stringWithFormat:@"%d", [id1234 intValue] * 7];
    NSString* id5678By3 = [NSString stringWithFormat:@"%d", [id5678 intValue] * 3];
    
    NSString* password1 = [id1234By7 substringWithRange:NSMakeRange(0, 1)];
    NSString* password2 = [id1234By7 substringWithRange:NSMakeRange([id1234By7 length]-1, 1)];
    NSString* password3 = [id1234By7 substringWithRange:NSMakeRange([id1234By7 length]-2, 1)];
    
    NSString* password4 = [id5678By3 substringWithRange:NSMakeRange([id5678By3 length]-1, 1)];
    NSString* password5 = @"0";
    if([id5678By3 length] >= 2){
        password5 = [id5678By3 substringWithRange:NSMakeRange([id5678By3 length]-2, 1)];
    }
    NSString* password6 = @"0";
    if([id5678By3 length] >= 3){
        password6 = [id5678By3 substringWithRange:NSMakeRange([id5678By3 length]-3, 1)];
    }
    
    NSString* passwordString = [NSString stringWithFormat:@"%@%@%@%@%@%@",
                                password1, password2, password3, password4, password5, password6];
    
    // NSLog(@"migrationId : %@", migrationId);
    // NSLog(@"id1234By7 : %@", id1234By7);
    // NSLog(@"id5678By3 : %@", id5678By3);
    // NSLog(@"passwordString : %@", passwordString);
    
    return passwordString;
}

@end
