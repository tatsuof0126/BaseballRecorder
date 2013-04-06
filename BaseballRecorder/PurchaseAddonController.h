//
//  PurchaseAddonController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/22.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InAppPurchaseProtocol.h"

@interface PurchaseAddonController : UIViewController <InAppPurchaseProtocol>

- (IBAction)backButton:(id)sender;

@property BOOL doingPurchase;
@property (strong, nonatomic) UIActivityIndicatorView* actIndView;

@property (strong, nonatomic) IBOutlet UITableView *addonTableView;

@end
