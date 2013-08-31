//
//  GameResultListController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "NADView.h"

@interface GameResultListController : UIViewController <NADViewDelegate>

@property (nonatomic, retain) NADView* nadView;

@property (weak, nonatomic) IBOutlet UITableView *gameResultListTableView;

@property (strong, nonatomic) NSMutableArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *gameResultYearList;

@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@end
