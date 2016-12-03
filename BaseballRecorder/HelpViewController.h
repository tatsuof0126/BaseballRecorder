//
//  HelpViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/06/21.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface HelpViewController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)backButton:(id)sender;

@end
