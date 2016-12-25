//
//  APIManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/10.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "APIManager.h"

@implementation APIManager

/*
+ (void)APISaveGameResults {
    NSString* url = @"http://192.168.51.5:3000/gameresults";
    NSString* param = @"{\"device_id\": \"1234567890\", \"gameresults\": [{\"id\": \"1\", \"uuid\": \"abcde\"}, {\"id\": \"2\", \"uuid\": \"fghij\"}]}";
    
    NSLog(@"URL:%@",url);
    NSLog(@"PARAM:%@",param);
    
    //リクエストを生成
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    //同期通信で送信
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    int httpStatusCode = (int)((NSHTTPURLResponse *)response).statusCode;
    
    NSLog(@"STATUS CODE:%d", httpStatusCode);
    NSLog(@"RESPONSE:%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"ERROR:%@", error.description);
    
    
    
}
*/

/*
+ (APIResult*)doPost:(NSString*)url param:(NSString*)param {
    NSLog(@"URL:%@",url);
    NSLog(@"PARAM:%@",param);
    
    //リクエストを生成
    NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"POST"];
    [request setURL:[NSURL URLWithString:url]];
    [request setHTTPBody:[param dataUsingEncoding:NSUTF8StringEncoding]];
    
    //同期通信で送信
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    APIResult* apiResult = nil;
    
    int httpStatusCode = (int)((NSHTTPURLResponse *)response).statusCode;
    if(httpStatusCode == 200){
        apiResult = [APIResult makeAPIResult:API_SUCCESS data:data error:error];
    } else {
        apiResult = [APIResult makeAPIResult:API_FAIL_OTHER data:data error:error];
    }
    
    NSLog(@"STATUS CODE:%d",(int)((NSHTTPURLResponse *)response).statusCode);
    NSLog(@"RESPONSE:%@",[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    NSLog(@"ERROR:%@",error.description);
    
    return apiResult;
}
 */

@end
