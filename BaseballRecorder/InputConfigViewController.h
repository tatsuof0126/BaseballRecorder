//
//  InputConfigViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/04.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
// #import <AddressBookUI/AddressBookUI.h>
#import <GoogleMobileAds/GoogleMobileAds.h>
#import "CheckBoxButton.h"

@interface InputConfigViewController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UINavigationItem *inputNavi;

@property (weak, nonatomic) IBOutlet UITextField *place;
@property (weak, nonatomic) IBOutlet UITextField *myteam;
@property (weak, nonatomic) IBOutlet UITextField *sendto;
@property (strong, nonatomic) IBOutlet CheckBoxButton *calcInning7;
@property (strong, nonatomic) IBOutlet CheckBoxButton *showMyteam;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)onTap:(id)sender;
- (IBAction)placeEdited:(id)sender;
- (IBAction)myteamEdited:(id)sender;
- (IBAction)sendtoEdited:(id)sender;
- (IBAction)backButton:(id)sender;

@end
