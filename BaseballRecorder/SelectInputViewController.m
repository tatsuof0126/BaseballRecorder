//
//  SelectInputViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/02.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "SelectInputViewController.h"
#import "GameResult.h"
#import "GameResultManager.h"

@interface SelectInputViewController ()

@end

@implementation SelectInputViewController

@synthesize titleItem;
@synthesize selectlist;
@synthesize selecttype;
@synthesize targetField;

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
    
    [self setTitleString];
    [self makeSelectList];
}

- (void)setTitleString {
    NSString* str = @"";
    if (selecttype == PLACE){
        str = @"場所の選択";
    } else if (selecttype == MYTEAM) {
        str = @"チームの選択";
    } else if (selecttype == OTHERTEAM) {
        str = @"相手チームの選択";
    }
    
    titleItem.title = str;
}


- (void)makeSelectList {
    selectlist = [NSMutableArray array];
    
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    
    for (int i=0; i<gameResultList.count; i++) {
        GameResult* result = [gameResultList objectAtIndex:i];
        
        NSString* str = @"";
        if (selecttype == PLACE){
            str = result.place;
        } else if (selecttype == MYTEAM) {
            str = result.myteam;
        } else if (selecttype == OTHERTEAM) {
            str = result.otherteam;
        }
        
        if([selectlist containsObject:str] == NO){
            [selectlist addObject:str];
        }
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return selectlist.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"SelectInputCell"];
    cell.textLabel.text = [selectlist objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"Selected %d-%d",indexPath.section, indexPath.row);
    
    targetField.text = [selectlist objectAtIndex:indexPath.row];
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)backButton:(id)sender {
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setSelecttableview:nil];
    [self setTitleItem:nil];
    [super viewDidUnload];
}

@end
