//
//  CheckBoxButton.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/07.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckBoxButton : UIButton

@property (nonatomic, assign) BOOL checkBoxSelected;

- (void)setState;

- (void)checkboxPush:(CheckBoxButton*)button;

@end
