//
//  InAppPurchaseProtocol.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/24.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol InAppPurchaseProtocol <NSObject>

- (void)endConnecting;

- (void)endPurchase;

@end
