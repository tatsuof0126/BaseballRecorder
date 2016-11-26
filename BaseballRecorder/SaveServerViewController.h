//
//  SaveServerViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGManagerViewController.h>

@interface SaveServerViewController : UIViewController <ADGManagerViewControllerDelegate> {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;

@property (strong, nonatomic) IBOutlet UILabel *datacode;
@property (strong, nonatomic) IBOutlet UILabel *limitdate;

- (IBAction)saveServer:(id)sender;

- (IBAction)backButton:(id)sender;

@end
