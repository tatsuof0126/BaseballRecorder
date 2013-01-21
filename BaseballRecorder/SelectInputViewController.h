//
//  SelectInputViewController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/02.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PLACE     1
#define MYTEAM    2
#define OTHERTEAM 3

@interface SelectInputViewController : UIViewController

@property int selecttype;

@property (strong, nonatomic) UITextField *targetField;

@property (strong, nonatomic) NSMutableArray *selectlist;

@property (weak, nonatomic) IBOutlet UINavigationItem *titleItem;

@property (weak, nonatomic) IBOutlet UITableView *selecttableview;

- (IBAction)backButton:(id)sender;

@end
