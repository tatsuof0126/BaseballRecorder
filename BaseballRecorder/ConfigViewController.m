//
//  ConfigViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/20.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "ConfigViewController.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "S3Manager.h"

@interface ConfigViewController ()

@end

@implementation ConfigViewController

@synthesize gadView;
@synthesize inputNavi;
@synthesize configTableView;
@synthesize removeadsButton;
@synthesize appstoreLabel;
@synthesize otherappLabel;
@synthesize configCategoryArray;
@synthesize configMenuArray;

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
    
    [self makeMenuArray];
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    _versionName.text = [NSString stringWithFormat:@"version%@",version];
    
    // AppStoreへリンクのタップを受け取るため
    appstoreLabel.userInteractionEnabled = YES;
    [appstoreLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    otherappLabel.userInteractionEnabled = YES;
    [otherappLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)]];
    
    // iPhone5対応
    [AppDelegate adjustOriginForiPhone5:_apptitle];
    [AppDelegate adjustOriginForiPhone5:_versionName];
    [AppDelegate adjustOriginForiPhone5:appstoreLabel];
    [AppDelegate adjustOriginForiPhone5:otherappLabel];
    
    // すでに広告が非表示ならボタンを消す
    // if([ConfigManager isRemoveAdsFlg] == YES){
    //     inputNavi.rightBarButtonItem = nil;
    // }
    
    // ScrollViewの大きさ定義＆iPhone5対応
    configTableView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:configTableView];
    
    // 広告表示（admob）
    if(AD_VIEW == 1 && [ConfigManager isRemoveAdsFlg] == NO){
        gadView = [AppDelegate makeGadView:self];
    }
}

- (void)adViewDidReceiveAd:(GADBannerView*)adView {
    // 読み込みに成功したら広告を表示
    gadView.frame = CGRectMake(0, 381, 320, 50);
    [AppDelegate adjustOriginForiPhone5:gadView];
    [self.view addSubview:gadView];
    
    // TableViewの大きさ定義＆iPhone5対応
    configTableView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:configTableView];
}

- (void)makeMenuArray {
    // メニュー
    if([ConfigManager isRemoveAdsFlg] == YES || [UIScreen mainScreen].bounds.size.height != 568){
        configCategoryArray = [NSArray arrayWithObjects:@"", @"", nil];
        configMenuArray = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"入力・表示の設定", nil],
                           [NSArray arrayWithObjects:@"データバックアップ（機種変更用）", @"バックアップデータ取り出し", nil],
                           nil];
    } else {
        configCategoryArray = [NSArray arrayWithObjects:@"", @"", @"", nil];
        configMenuArray = [NSArray arrayWithObjects:
                           [NSArray arrayWithObjects:@"入力・表示の設定", nil],
                           [NSArray arrayWithObjects:@"データバックアップ（機種変更用）", @"バックアップデータ取り出し", nil],
                           [NSArray arrayWithObjects:@"広告を削除する", nil], nil];
    }
}

- (void)removeAdsBar {
    if(gadView != nil && [ConfigManager isRemoveAdsFlg] == YES){
        // 広告表示していて、広告削除した場合は表示を消す
        [gadView removeFromSuperview];
        gadView.delegate = nil;
        gadView = nil;
        
        // TableViewの大きさ定義＆iPhone5対応
        configTableView.frame = CGRectMake(0, 64, 320, 366);
        [AppDelegate adjustForiPhone5:configTableView];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return configCategoryArray.count;
}

- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
    return [configCategoryArray objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return ((NSArray*)[configMenuArray objectAtIndex:section]).count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
    NSArray* menuArray = [configMenuArray objectAtIndex:indexPath.section];
    
    NSString* cellName = @"ConfigViewCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellName];
    }
    
    cell.textLabel.text = [menuArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //    NSLog(@"Selected %d-%d",indexPath.section, indexPath.row);
    
    if(indexPath.section == 0 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"inputconfig" sender:self];
    } else if(indexPath.section == 1 && indexPath.row == 0){
        [self performSegueWithIdentifier:@"saveserver" sender:self];
    } else if(indexPath.section == 1 && indexPath.row == 1){
        if([ConfigManager isServerUseFlg] == NO){
            [self showMoveAddonView:@"バックアップデータ取り出しにはアドオンの入手が必要です。（一度入手すると何度でもバックアップデータの取り出しが可能です）"];
        } else {
            [self performSegueWithIdentifier:@"loadserver" sender:self];
        }
    } else if(indexPath.section == 2 && indexPath.row == 0){
        if([ConfigManager isRemoveAdsFlg] == NO){
            [self showMoveAddonView:@"広告を削除するにはアドオンの入手が必要です。"];
        }
    }
}

- (void)showMoveAddonView:(NSString*)message {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
        message:message delegate:self cancelButtonTitle:@"キャンセル" otherButtonTitles:@"アドオン入手", nil];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        [self performSegueWithIdentifier:@"getaddon" sender:self];
    }
    [configTableView deselectRowAtIndexPath:[configTableView indexPathForSelectedRow] animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setInputNavi:nil];
    [self setAppstoreLabel:nil];
    [self setOtherappLabel:nil];
    [self setApptitle:nil];
    [self setRemoveadsButton:nil];
    [super viewDidUnload];
}

- (void)tapAction:(UITapGestureRecognizer*)sender{
    if(sender.view == appstoreLabel){
//        NSURL* url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/jp/app/cao-ye-qiu-ri-ji-beboreko/id578136103?mt=8&uo=4"];
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=578136103&mt=8&type=Purple+Software"];

        [[UIApplication sharedApplication] openURL:url];
    } else if(sender.view == otherappLabel){
        NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.com/apps/TatsuoFujiwara"];
        
        [[UIApplication sharedApplication] openURL:url];
    }
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [configTableView deselectRowAtIndexPath:[configTableView indexPathForSelectedRow] animated:NO];
    
    [self makeMenuArray];
    [configTableView reloadData];
    
    // 広告が削除された場合の対応
    [self removeAdsBar];
}

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end
