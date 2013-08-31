//
//  ConfigViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "CheckBoxButton.h"

@interface ConfigViewController : UIViewController <ABPeoplePickerNavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (weak, nonatomic) IBOutlet UITextField *place;
@property (weak, nonatomic) IBOutlet UITextField *myteam;
@property (weak, nonatomic) IBOutlet UITextField *sendto;
@property (strong, nonatomic) IBOutlet CheckBoxButton *calcInning7;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *apptitle;
@property (strong, nonatomic) IBOutlet UILabel *appsubtitle;
@property (weak, nonatomic) IBOutlet UILabel *versionName;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *removeadsButton;
@property (weak, nonatomic) IBOutlet UILabel *appstoreLabel;

- (IBAction)placeEdited:(id)sender;
- (IBAction)myteamEdited:(id)sender;
- (IBAction)sendtoEdited:(id)sender;
- (IBAction)addSendtoButton:(id)sender;
- (IBAction)removeadsButton:(id)sender;

@end
