//
//  GameResultManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/27.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "GameResultManager.h"
#import "GameResult.h"

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
    
    for (int i=0; i<filenameArray.count; i++) {
        NSString* filename = [filenameArray objectAtIndex:i];
        NSString* filepath = [dirpath stringByAppendingPathComponent:filename];
        
//        NSLog(@"filepath : %@",filepath);
        
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

+ (int)getNewResultCount {
    NSArray* dirpaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString* dirpath = [dirpaths objectAtIndex:0];
    
    int count = 1;
    while (true) {
        NSString* tmpfilename = [NSString stringWithFormat:@"gameresult%d.dat",count];
        NSString* tmpfilepath = [dirpath stringByAppendingPathComponent:tmpfilename];
        
        if([[NSFileManager defaultManager] fileExistsAtPath:tmpfilepath] == false){
            break;
        }
        count++;
    }
    
    return count;
}

@end
