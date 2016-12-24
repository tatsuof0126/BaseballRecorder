//
//  S3Manager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/12/21.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "S3Manager.h"
#import <AWSS3/AWSS3.h>
#import "S3Config.h"

@implementation S3Manager

NSString* const AWS_KEY = @"AKIAJ75XQ52YMTDG7V7A";
NSString* const AWS_SECRET = @"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";
NSString* const S3_BUCKET = @"baseballrecorder";

+ (NSArray*)S3GetFileList:(NSString*)prefix {
    NSMutableArray* __block resultArray = [NSMutableArray array];
    BOOL __block connecting = YES;
    
    [S3Config init];
    
    //リクエストの生成
    AWSS3ListObjectsRequest *listRequest = [[AWSS3ListObjectsRequest alloc] init];
    listRequest.bucket = S3_BUCKET;
    listRequest.prefix = prefix;
    
    //リクエストをコール
    AWSS3* s3 = [AWSS3 defaultS3];
    [[s3 listObjects:listRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.result) {
            AWSS3ListObjectsOutput* result = task.result;
            for(AWSS3Object* object in result.contents){
                [resultArray addObject:object.key];
            }
        }
        
        connecting = NO;
        
        return nil;
    }];
    
    while(connecting == YES){
        sleep(0.5f);
    }
    
    return resultArray;
}

+ (NSArray*)S3DownloadFiles:(NSArray*)targetArray {
    NSMutableArray* retArray = [NSMutableArray array];
    
    if(targetArray == nil){
        return retArray;
    }
    
    for(NSString* targetKey in targetArray){
        NSString* filepath = [self S3Download:targetKey];
        if(filepath != nil){
            [retArray addObject:filepath];
        }
    }
    
    return retArray;
}

+ (NSString*)S3Download:(NSString*)key {
    NSLog(@"S3Download start key = %@", key);
    
    NSString* __block resultFilePath = nil;
    BOOL __block connecting = YES;
    
    [S3Config init];
    
    // ダウンロード先を指定
    NSString* keyPath = [key stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    NSString* downloadingFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:keyPath];
    NSLog(@"DL path = %@", downloadingFilePath);
    
    NSURL* downloadingFileURL = [NSURL fileURLWithPath:downloadingFilePath];
    
    // ダウンロードリクエストを作成
    AWSS3TransferManagerDownloadRequest* downloadRequest = [AWSS3TransferManagerDownloadRequest new];
    downloadRequest.bucket = S3_BUCKET;
    downloadRequest.key = key;
    downloadRequest.downloadingFileURL = downloadingFileURL;
    
    // Download the file.
    AWSS3TransferManager* transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager download:downloadRequest]
        continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask* task) {
        if(task.error){
            if([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch(task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                        break;
                    default:
                        NSLog(@"Error: %@", task.error);
                        break;
                }
            } else {
                // Unknown error.
                NSLog(@"Error: %@", task.error);
            }
        }
        
        if(task.result){
            AWSS3TransferManagerDownloadOutput* downloadOutput = task.result;
            //File downloaded successfully.
            NSLog(@"downloadOutput: %@", [downloadOutput description]);
            
            /*
            NSData* readdata = [NSData dataWithContentsOfFile:downloadingFilePath];
            NSLog(@"Path : %@", downloadingFilePath);
            GameResult* gameResult = [GameResult makeGameResult:readdata];
            if(gameResult == nil){
                NSLog(@"GameResult is nil");
            } else {
                NSLog(@"GameResult is not nil");
                NSLog(@"MYTEAM : %@", gameResult.myteam);
            }
             */
             
            resultFilePath = downloadingFilePath;
        }
        
        connecting = NO;
            
        return nil;
    }];
    
    while(connecting == YES){
        sleep(0.5f);
    }
    
    return resultFilePath;
}

+ (BOOL)S3Upload:(NSString*)prefix fileName:(NSString*)fileName filePath:(NSString*)filePath {
    BOOL __block connecting = YES;
    BOOL __block succeed = NO;
    
    [S3Config init];

    AWSS3TransferManagerUploadRequest* request = [AWSS3TransferManagerUploadRequest new];
    request.bucket = S3_BUCKET;
    request.key = [NSString stringWithFormat:@"%@%@",prefix, fileName];
    request.body = [NSURL fileURLWithPath:filePath];
    
    AWSS3TransferManager* transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:request]
        continueWithExecutor:[AWSExecutor mainThreadExecutor] withBlock:^id(AWSTask* task){
            if (task.result) {
                // The file uploaded successfully.
                // AWSS3TransferManagerUploadOutput* uploadOutput = task.result;
                succeed = YES;
            }
            
            connecting = NO;

            return nil;
        }];
    
    while(connecting == YES){
        sleep(0.5f);
    }
    
    return succeed;
}


@end
