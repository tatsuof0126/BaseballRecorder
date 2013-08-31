//
//  PitchingStatisticsController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/13.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "StatisticsCommonController.h"
#import "PitchingStatistics.h"

@interface PitchingStatisticsController : StatisticsCommonController
    <MFMailComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) IBOutlet UILabel *pitchingresult;
@property (strong, nonatomic) IBOutlet UILabel *inning;
@property (strong, nonatomic) IBOutlet UILabel *era;
@property (strong, nonatomic) IBOutlet UILabel *shoritsu;
@property (strong, nonatomic) IBOutlet UILabel *hianda;
@property (strong, nonatomic) IBOutlet UILabel *hihomerun;
@property (strong, nonatomic) IBOutlet UILabel *dassanshin;
@property (strong, nonatomic) IBOutlet UILabel *yoshikyu;
@property (strong, nonatomic) IBOutlet UILabel *yoshikyu2;
@property (strong, nonatomic) IBOutlet UILabel *shitten;
@property (strong, nonatomic) IBOutlet UILabel *jisekiten;
@property (strong, nonatomic) IBOutlet UILabel *kanto;
@property (strong, nonatomic) IBOutlet UILabel *whip;
@property (strong, nonatomic) IBOutlet UILabel *k9;

@property (strong, nonatomic) IBOutlet UILabel *year;
@property (strong, nonatomic) IBOutlet UILabel *team;

@property (strong, nonatomic) PitchingStatistics* pitchingStatistics;

@property BOOL tweeted;

- (IBAction)changeButton:(id)sender;
- (IBAction)tweetButton:(id)sender;
- (IBAction)mailButton:(id)sender;

@end