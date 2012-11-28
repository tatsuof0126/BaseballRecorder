//
//  ShowGameResultController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShowGameResultController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *place;
@property (weak, nonatomic) IBOutlet UILabel *myteam;
@property (weak, nonatomic) IBOutlet UILabel *otherteam;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

- (IBAction)backButton:(id)sender;

- (IBAction)editButton:(id)sender;

@end
