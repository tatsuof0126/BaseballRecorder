//
//  SaveServerViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface SaveServerViewController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (strong, nonatomic) UIActivityIndicatorView* indicator;

@property (strong, nonatomic) IBOutlet UILabel *migrationCdLabel;
@property (strong, nonatomic) IBOutlet UILabel *createDateLabel;

@property (strong, nonatomic) IBOutlet UITextView *infoText;

@property (strong, nonatomic) IBOutlet UILabel *message3;
@property (strong, nonatomic) IBOutlet UILabel *userIdLabel;
@property (strong, nonatomic) IBOutlet UITextField *userIdText;

- (IBAction)saveServer:(id)sender;

- (IBAction)updateInfo:(id)sender;

- (IBAction)backButton:(id)sender;

@end
