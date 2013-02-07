//
//  CheckBoxButton.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/07.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "CheckBoxButton.h"

@implementation CheckBoxButton

@synthesize checkBoxSelected;

- (void)awakeFromNib {
    [super awakeFromNib];
    UIImage* nocheck = [UIImage imageNamed:@"nocheck.png"];
    UIImage* checked = [UIImage imageNamed:@"check.png"];
    UIImage* disable = [UIImage imageNamed:@"disable_check.png"];
    [self setBackgroundImage:nocheck forState:UIControlStateNormal];
    [self setBackgroundImage:checked forState:UIControlStateSelected];
    [self setBackgroundImage:checked forState:UIControlStateHighlighted];
    [self setBackgroundImage:disable forState:UIControlStateDisabled];
    [self addTarget:self action:@selector(checkboxPush:) forControlEvents:UIControlEventTouchUpInside];
    [self setState:self];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIImage* nocheck = [UIImage imageNamed:@"nocheck.png"];
        UIImage* checked = [UIImage imageNamed:@"check.png"];
        UIImage* disable = [UIImage imageNamed:@"disable_check.png"];
        [self setBackgroundImage:nocheck forState:UIControlStateNormal];
        [self setBackgroundImage:checked forState:UIControlStateSelected];
        [self setBackgroundImage:checked forState:UIControlStateHighlighted];
        [self setBackgroundImage:disable forState:UIControlStateDisabled];
        [self addTarget:self action:@selector(checkboxPush:) forControlEvents:UIControlEventTouchUpInside];
        [self setState:self];
    }
    return self;
}

- (void)checkboxPush:(CheckBoxButton*) button {
    button.checkBoxSelected = !button.checkBoxSelected;
    [button setState:button];
}

- (void)setState:(CheckBoxButton*)button {
    if (button.checkBoxSelected) {
        [button setSelected:YES];
    } else {
        [button setSelected:NO];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
