//
//  LoadServerViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2016/11/06.
//  Copyright © 2016年 Tatsuo Fujiwara. All rights reserved.
//

#import "LoadServerViewController.h"

@interface LoadServerViewController ()

@end

@implementation LoadServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)backButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
