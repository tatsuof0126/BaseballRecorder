//
//  ConfigViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CheckBoxButton.h"

@interface ConfigViewController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (strong, nonatomic) IBOutlet UITableView *configTableView;

@property (strong, nonatomic) IBOutlet UILabel *apptitle;
@property (weak, nonatomic) IBOutlet UILabel *versionName;
@property (weak, nonatomic) IBOutlet UILabel *appstoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *otherappLabel;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *removeadsButton;

@property (strong, nonatomic) NSArray* configCategoryArray;
@property (strong, nonatomic) NSArray* configMenuArray;

@end
