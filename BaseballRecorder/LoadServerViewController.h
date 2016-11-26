//
//  LoadServerViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGManagerViewController.h>

@interface LoadServerViewController : UIViewController <ADGManagerViewControllerDelegate> {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;

- (IBAction)backButton:(id)sender;

@end
