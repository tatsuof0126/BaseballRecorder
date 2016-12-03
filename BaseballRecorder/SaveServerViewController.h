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

@property (strong, nonatomic) IBOutlet UILabel *datacode;
@property (strong, nonatomic) IBOutlet UILabel *limitdate;

- (IBAction)saveServer:(id)sender;

- (IBAction)backButton:(id)sender;

@end
