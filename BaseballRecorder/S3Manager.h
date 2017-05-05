//
//  S3Manager.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/12/21.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface S3Manager : NSObject

+ (NSArray*)S3GetFileList:(NSString*)prefix;

+ (NSArray*)S3DownloadFiles:(NSArray*)targetArray;

+ (NSString*)S3Download:(NSString*)key;

+ (BOOL)S3Upload:(NSString*)prefix fileName:(NSString*)fileName filePath:(NSString*)filePath;

+ (NSString*)S3GetInfo;

+ (NSString*)S3GetMode;

@end
