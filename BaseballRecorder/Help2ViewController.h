//
//  HelpViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2015/06/21.
//  Copyright (c) 2015年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGManagerViewController.h>

@interface Help2ViewController : UIViewController {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)backButton:(id)sender;

@end
