//
//  UIPlaceHolderTextView.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/05/27.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIPlaceHolderTextView : UITextView

@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;

-(void)textChanged:(NSNotification*)notification;

@end
