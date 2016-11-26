//
//  ConfigViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <ADG/ADGManagerViewController.h>
#import "CheckBoxButton.h"

@interface ConfigViewController : UIViewController <ADGManagerViewControllerDelegate> {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;

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
