//
//  BattingStatisticsViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "StatisticsCommonController.h"
#import "TeamStatistics.h"
#import "BattingStatistics.h"

#define ALL_TARGET 0

@interface BattingStatisticsViewController : StatisticsCommonController
    <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UILabel *teamresult;
@property (weak, nonatomic) IBOutlet UILabel *battingresult;
@property (weak, nonatomic) IBOutlet UILabel *battingstat;
@property (weak, nonatomic) IBOutlet UILabel *battingstat2;

@property (weak, nonatomic) IBOutlet UILabel *doubles;
@property (weak, nonatomic) IBOutlet UILabel *triples;
@property (weak, nonatomic) IBOutlet UILabel *homeruns;
@property (weak, nonatomic) IBOutlet UILabel *strikeouts;
@property (weak, nonatomic) IBOutlet UILabel *walks;
@property (weak, nonatomic) IBOutlet UILabel *sacrifices;
@property (weak, nonatomic) IBOutlet UILabel *daten;
@property (weak, nonatomic) IBOutlet UILabel *tokuten;
@property (weak, nonatomic) IBOutlet UILabel *steal;

@property (weak, nonatomic) IBOutlet UILabel *team;
@property (weak, nonatomic) IBOutlet UILabel *year;

@property (strong, nonatomic) TeamStatistics* teamStatistics;
@property (strong, nonatomic) BattingStatistics* battingStatistics;

@property BOOL tweeted;

- (IBAction)changeButton:(id)sender;
- (IBAction)tweetButton:(id)sender;
- (IBAction)mailButton:(id)sender;

@end
