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
@synthesize selecttableview;
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
    } else if (selecttype == TAGTEXT) {
        str = @"タグを追加";
    }
    
    titleItem.title = str;
}


- (void)makeSelectList {
    selectlist = [NSMutableArray array];
    
    NSArray* gameResultList = [GameResultManager loadGameResultList];
    
    if (selecttype == TAGTEXT){
        // タグの場合は１試合で複数ある場合がある
        for (GameResult *result in gameResultList){
            for (NSString* str in [result getTagList]){
                if([str isEqualToString:@""] == NO && [selectlist containsObject:str] == NO){
                    [selectlist addObject:str];
                }
            }
        }
        
        // タグの場合は複数選択を可能にする
        selecttableview.allowsMultipleSelection = YES;
        titleItem.rightBarButtonItem = _registBtn;
    } else {
        // それ以外の場合は１試合で１つ
        for (GameResult *result in gameResultList){
            NSString* str = @"";
            if (selecttype == PLACE){
                str = result.place;
            } else if (selecttype == MYTEAM) {
                str = result.myteam;
            } else if (selecttype == OTHERTEAM) {
                str = result.otherteam;
            }
            
            if([str isEqualToString:@""] == NO && [selectlist containsObject:str] == NO){
                [selectlist addObject:str];
            }
        }
        
        // 複数選択は不可とし右上の決定ボタンを隠す
        selecttableview.allowsMultipleSelection = NO;
        titleItem.rightBarButtonItem = nil;
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
    
    if (selecttype == TAGTEXT){
        // 選択されたセルにチェックをつける
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
/*
        if(cell.accessoryType == UITableViewCellAccessoryNone){
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
 */
    } else {
        targetField.text = [selectlist objectAtIndex:indexPath.row];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (selecttype == TAGTEXT){
        // 選択がはずれたセルのチェックをはずす
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)registButton:(id)sender {
    NSMutableString* newTagText = [NSMutableString stringWithString:targetField.text];
    
    // 選択されたタグを入力欄に追加
    NSArray* selectedList = [selecttableview indexPathsForSelectedRows];
    for(NSIndexPath* indexPath in selectedList){
        NSString* str = [selectlist objectAtIndex:indexPath.row];
        [newTagText appendFormat:@",%@",str];
    }
    
    targetField.text = [GameResult adjustTagText:newTagText];
    
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
