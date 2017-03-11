//
//  InAppPurchaseManager.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/24.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "InAppPurchaseManager.h"
#import "ConfigManager.h"
#import "Utility.h"

@implementation InAppPurchaseManager 

@synthesize source;

- (InAppPurchaseManager*)init {
    InAppPurchaseManager* manager = [super init];
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return manager;
}

- (BOOL)canMakePurchases {
    if([SKPaymentQueue canMakePayments]){
        return YES;
    } else {
        return NO;
    }
}

- (void)requestProductData:(NSString*)productId {
//    NSLog(@"−−− requestProductData −−−");

//    NSLog(@" productId : %@",productId);
    
    myProductRequest = [[SKProductsRequest alloc]
                       initWithProductIdentifiers: [NSSet setWithObject:productId]];
    myProductRequest.delegate = self;
    [myProductRequest start];    
}

- (void)productsRequest:(SKProductsRequest*)request
     didReceiveResponse:(SKProductsResponse*)response {
//    NSLog(@"−−− productsRequest −−−");
    
    // ぐるぐる終了
    [source endConnecting];
    
    if (response == nil) {
//        NSLog(@" response is nil");
        return;
    }
    
    // 確認できなかったidentifierをログに記録
//    for (NSString *identifier in response.invalidProductIdentifiers) {
//        NSLog(@"invalid product identifier: %@", identifier);
//    }
    
    for (SKProduct *product in response.products ) {
//        NSLog(@" %@",[product localizedTitle]);
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restoreProduct {
//    NSLog(@"−−− restoreProduct −−−");
    
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)paymentQueue:(SKPaymentQueue*)queue updatedTransactions:(NSArray*)transactions {
//    NSLog(@"--- paymentQueue ---");
    
    for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
//                NSLog(@"購入処理中・・・");
                break;
            case SKPaymentTransactionStatePurchased:
//                NSLog(@"購入処理成功");
//                NSLog(@"productID : %@",transaction.payment.productIdentifier);
                
                // 購入したアドオンを登録
                [self purchaseAddon:transaction.payment.productIdentifier restore:NO];
                
                [queue finishTransaction: transaction];
                [source endPurchase];
                source = nil;
                break;
            case SKPaymentTransactionStateFailed:
                if (transaction.error.code != SKErrorPaymentCancelled){
                    [Utility showAlert:@"購入に失敗しました" message:[transaction.error localizedDescription]];
//                    NSLog(@"購入処理失敗");
                } else {
//                    NSLog(@"購入キャンセル");
                }
                
                [queue finishTransaction:transaction];
                [source endPurchase];
                source = nil;
                break;
            case SKPaymentTransactionStateRestored:
//                NSLog(@"リストア処理");
//                NSLog(@"productID : %@",transaction.originalTransaction.payment.productIdentifier);
                
                // 購入したアドオンを登録
                [self purchaseAddon:transaction.originalTransaction.payment.productIdentifier restore:YES];
                
                [queue finishTransaction:transaction];
                [source endPurchase];
                source = nil;
                break;
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
//    NSLog(@"--- paymentQueueRestoreCompletedTransactionsFinished ---");
    
    [Utility showAlert:@"リストアしました"];
    [source endPurchase];
    source = nil;
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
//    NSLog(@"--- restoreCompletedTransactionsFailedWithError ---");
    
    [source endPurchase];
    source = nil;
}

- (void)purchaseAddon:(NSString*)productId restore:(BOOL)restore {
    // 購入したアドオンを判定
    if([productId isEqualToString:@"com.tatsuo.baseballrecorder.removeads"]){
        // 広告削除アドオン
        if(restore == NO){
            [ConfigManager setRemoveAdsFlg:YES];
            [Utility showAlert:@"購入しました" message:@"広告が表示されなくなりました。"];
        } else {
            if([ConfigManager isRemoveAdsFlg] == NO){
                [ConfigManager setRemoveAdsFlg:YES];
                [Utility showAlert:@"リストアしました" message:@"広告が表示されなくなりました。"];
            }
        }
    } else if ([productId isEqualToString:@"com.tatsuo.baseballrecorder.useserverflg"]){
        // 機種変更コードアドオン
        if(restore == NO){
            [ConfigManager setServerUseFlg:YES];
            [Utility showAlert:@"購入しました" message:@"機種変更コードの利用が可能になりました。"];
        } else {
            if([ConfigManager isServerUseFlg] == NO){
                [ConfigManager setServerUseFlg:YES];
                [Utility showAlert:@"リストアしました" message:@"機種変更コードの利用が可能になりました。"];
            }
        }
    }
}

@end
