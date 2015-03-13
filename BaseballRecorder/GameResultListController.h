//
//  GameResultListController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ADG/ADGManagerViewController.h>

@interface GameResultListController : UIViewController <ADGManagerViewControllerDelegate> {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;

@property (weak, nonatomic) IBOutlet UITableView *gameResultListTableView;

@property (strong, nonatomic) NSMutableArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *gameResultYearList;

@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@end
