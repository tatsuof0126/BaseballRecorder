//
//  RectView.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/06/01.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import "RectView.h"

@implementation RectView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = UIColor.clearColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();  // コンテキストを取得
    
    CGContextSetStrokeColorWithColor(context,UIColor.redColor.CGColor); // 線を赤色にする
    CGContextSetLineWidth(context, 3.0);  // 太さ
    
    CGContextStrokeRect(context, CGRectMake(0, 0, self.frame.size.width, self.frame.size.height));
    
    
//    CGContextMoveToPoint(context, 0, 0);  // 始点
//    CGContextAddLineToPoint(context, 100, 100); // 終点
//    CGContextStrokePath(context);  // 描画
}

@end
