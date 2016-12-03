//
//  GameResultListController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface GameResultListController : UIViewController <GADBannerViewDelegate>

@property (strong, nonatomic) GADBannerView *gadView;

@property (weak, nonatomic) IBOutlet UITableView *gameResultListTableView;

@property (strong, nonatomic) NSMutableArray *gameResultList;

@property (strong, nonatomic) NSMutableArray *gameResultYearList;

@property (strong, nonatomic) NSMutableArray *gameResultListOfYear;

@end
