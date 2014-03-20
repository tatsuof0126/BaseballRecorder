//
//  BattingAnalysisController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/02/24.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import <Social/Social.h>
#import "StatisticsCommonController.h"
#import "BattingAnalysisView.h"

@interface BattingAnalysisController : StatisticsCommonController

@property (strong, nonatomic) IBOutlet BattingAnalysisView *analysysView;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UILabel *year;
@property (strong, nonatomic) IBOutlet UILabel *team;

@property (strong, nonatomic) IBOutlet UIButton *changeBtn;
@property (strong, nonatomic) IBOutlet UIButton *saveBtn;
@property (strong, nonatomic) IBOutlet UIButton *shareBtn;

@property BOOL posted;

- (IBAction)changeButton:(id)sender;

- (IBAction)saveAnalysis:(id)sender;

- (IBAction)shareAnalysis:(id)sender;

@end
