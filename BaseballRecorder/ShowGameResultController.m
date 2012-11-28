//
//  ShowGameResultController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ShowGameResultController.h"
#import "GameResult.h"
#import "BattingResult.h"
#import "GameResultManager.h"
#import "AppDelegate.h"

@interface ShowGameResultController ()

@end

@implementation ShowGameResultController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self showGameResult];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showGameResult {
    
    AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
//    int resultid = appDelegate.targatResultid;
    
    GameResult* gameResult = appDelegate.targetGameResult;

//    NSLog(@"targetResultid : %d",gameResult.resultid);
    
    _date.text = [gameResult getDateString];
    _place.text = gameResult.place;
    _myteam.text = gameResult.myteam;
    _otherteam.text = gameResult.otherteam;
    _result.text = [gameResult getGameResultString];
    
    NSArray* viewArray = [_scrollview subviews];
    for(int i=0;i<viewArray.count;i++){
        UIView* view = [viewArray objectAtIndex:i];
        if(view.tag == 1){
            [view removeFromSuperview];
        }
    }
    
    for(int i=0;i<gameResult.battingResultArray.count;i++){
        UILabel* titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(30,255+i*35,90,30)];
        titlelabel.text = [NSString stringWithFormat:@"第%d打席",i+1];
        titlelabel.tag = 1;
        
        UILabel* resultlabel = [[UILabel alloc] initWithFrame:CGRectMake(125,255+i*35,200,30)];
        resultlabel.text = [[gameResult.battingResultArray objectAtIndex:i] getResultString];
        resultlabel.tag = 1;
        
        [_scrollview addSubview:titlelabel];
        [_scrollview addSubview:resultlabel];
    }
    
    CGSize size = CGSizeMake(320, 380+gameResult.battingResultArray.count*35);
    _scrollview.contentSize = size;
}
     
- (IBAction)backButton:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)editButton:(id)sender {
    NSLog(@"Called EditButton.");
}

- (void)viewDidUnload {
    [self setDate:nil];
    [self setPlace:nil];
    [self setMyteam:nil];
    [self setOtherteam:nil];
    [self setResult:nil];
    [self setScrollview:nil];
    [super viewDidUnload];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self showGameResult];
}

@end
