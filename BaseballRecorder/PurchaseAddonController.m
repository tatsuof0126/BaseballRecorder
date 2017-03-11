//
//  PurchaseAddonController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/03/22.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PurchaseAddonController.h"
#import "InAppPurchaseManager.h"
#import "AppDelegate.h"
#import "Utility.h"
#import "TrackingManager.h"
#import "ConfigManager.h"

#define APPSTORELABEL 1

@interface PurchaseAddonController ()

@end

@implementation PurchaseAddonController

@synthesize doingPurchase;
@synthesize actIndView;
@synthesize addonTableView;

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
    
    // 画面が開かれたときのトラッキング情報を送る
    [TrackingManager sendScreenTracking:@"アドオン購入画面"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
 	return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return @"アドオンを購入";
    } else if(section == 1){
        return @"以前にアドオンを購入済みの方";
    } else {
        return @"";
    }
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0){
        return 2;
    } else if(section == 1){
        return 1;
    }
    return 1;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    int section = [Utility convert2int:indexPath.section];
    int row = [Utility convert2int:indexPath.row];
    
    /*
    UITableViewCell* cell;
    NSString* cellName = [NSString stringWithFormat:@"%@%d",@"PurchaseCell",section];
    cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:cellName];
    }
    */
    
    NSString* cellName = @"PurchaseCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:cellName];
    }
    
    NSString* text = @"";
    NSString* detailText = @"";
    
    if(section == 0 && row == 0){
        text = @"広告を削除";
        if([ConfigManager isRemoveAdsFlg] == YES){
            detailText = @"購入済み";
        }
    } else if(section == 0 && row == 1){
        text = @"機種変更コードを利用";
        if([ConfigManager isServerUseFlg] == YES){
            detailText = @"購入済み";
        }
    } else if(section == 1){
        text = @"購入済みアドオンをリストア";
    }
    
    cell.textLabel.text = text;
    cell.detailTextLabel.text = detailText;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    NSLog(@"Selected %d-%d",indexPath.section, indexPath.row);
    
    if(indexPath.section == 0 && indexPath.row == 0){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"アドオン購入画面―広告削除" value:nil screen:@"アドオン購入画面"];
        if([ConfigManager isRemoveAdsFlg] == NO){
            [self requestAddon:@"com.tatsuo.baseballrecorder.removeads"];
        } else {
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
            [Utility showAlert:@"このアドオンはすでに購入済みです。"];
        }
    } else if(indexPath.section == 0 && indexPath.row == 1){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"アドオン購入画面―機種変更コード利用" value:nil screen:@"アドオン購入画面"];
        if([ConfigManager isServerUseFlg] == NO){
            [self requestAddon:@"com.tatsuo.baseballrecorder.useserverflg"];
        } else {
            [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
            [Utility showAlert:@"このアドオンはすでに購入済みです。"];
        }
    } else if(indexPath.section == 1){
        [TrackingManager sendEventTracking:@"Button" action:@"Push" label:@"アドオン購入画面―リストア" value:nil screen:@"アドオン購入画面"];
        [self restoreAddon];
    }
}

- (void)requestAddon:(NSString*)productId {
    [addonTableView deselectRowAtIndexPath:[addonTableView indexPathForSelectedRow] animated:NO];
    
    // 購入処理中なら処理しない
    if(doingPurchase == YES){
        return;
    }
    
    AppDelegate* delegate = [AppDelegate getAppDelegate];
    InAppPurchaseManager* purchaseManager = [delegate getInAppPurchaseManager];
    
    // アプリ内課金が許可されていない場合はダイアログを出す
    if(purchaseManager.canMakePurchases == NO){
        [Utility showAlert:@"アプリ内での購入が許可されていません。設定を確認してください。"];
        return;
    }
    
    // 購入処理開始
    doingPurchase = YES;
    
    // InAppPurchaseManagerに自分自身の参照をセット
    purchaseManager.source = self;
    
    //ぐるぐるを出す
    actIndView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 60.0f, 60.0f)];
    [actIndView setCenter:self.view.center];
    [actIndView setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:actIndView];
    [actIndView startAnimating];
    
    // アプリ内課金を呼び出し
    [purchaseManager requestProductData:productId];
}

- (void)restoreAddon {
    [addonTableView deselectRowAtIndexPath:[addonTableView indexPathForSelectedRow] animated:NO];
    
    // 購入処理中なら処理しない
    if(doingPurchase == YES){
        return;
    }
    
    AppDelegate* delegate = [AppDelegate getAppDelegate];
    InAppPurchaseManager* purchaseManager = [delegate getInAppPurchaseManager];
    
    // アプリ内課金が許可されていない場合はダイアログを出す
    if(purchaseManager.canMakePurchases == NO){
        [Utility showAlert:@"アプリ内での購入が許可されていません。設定を確認してください。"];
        return;
    }
    
    // 購入処理開始
    doingPurchase = YES;
    
    // InAppPurchaseManagerに自分自身の参照をセット
    purchaseManager.source = self;
    
    // アプリ内課金（リストア）を呼び出し
    [purchaseManager restoreProduct];
}

- (void)endConnecting {
    [actIndView stopAnimating];
}

- (void)endPurchase {
    doingPurchase = NO;
    [addonTableView reloadData];
}

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [self setAddonTableView:nil];
    [super viewDidUnload];
}

@end
