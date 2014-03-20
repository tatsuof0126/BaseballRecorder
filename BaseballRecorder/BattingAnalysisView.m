//
//  BattingAnalysisView.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2014/02/24.
//  Copyright (c) 2014年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingAnalysisView.h"
#import "GameResult.h"

@implementation BattingAnalysisView

@synthesize gameResultListForAnalysis;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGPoint basePoint = CGPointMake(140.0, 258.0);
    CGPoint targetBasePoints[] = {
        CGPointMake(140.0, 258.0),
        CGPointMake(140.0, 204.0),
        CGPointMake(140.0, 248.0),
        CGPointMake(187.0, 204.0),
        CGPointMake(162.0, 160.0),
        CGPointMake(93.0,  204.0),
        CGPointMake(118.0, 160.0),
        CGPointMake(55.0,  103.0),
        CGPointMake(140.0, 73.0),
        CGPointMake(225.0, 103.0),
        CGPointMake(85.0,  83.0),
        CGPointMake(195.0, 83.0),
        CGPointMake(25.0,  48.0), // レフトホームラン
        CGPointMake(140.0, 0.0), // センターホームラン
        CGPointMake(255.0, 48.0), // ライトホームラン
        CGPointMake(65.0,  18.0), // 左中間ホームラン
        CGPointMake(215.0, 18.0), // 右中間ホームラン
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGContextMoveToPoint(context, 0.0, 248.0);
    CGContextAddLineToPoint(context, 30.0, 248.0);
    CGContextStrokePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, 0.0, 268.0);
    CGContextAddLineToPoint(context, 30.0, 268.0);
    CGContextStrokePath(context);
    CGContextSetStrokeColorWithColor(context, [UIColor darkGrayColor].CGColor);
    CGContextMoveToPoint(context, 0.0, 288.0);
    CGContextAddLineToPoint(context, 30.0, 288.0);
    CGContextStrokePath(context);
    
    CGContextSetLineWidth(context, 3.5);
    CGContextSetLineCap(context, kCGLineCapRound);
    
    // 打撃成績を元に直線を描画
    for(int i=0;i<[gameResultListForAnalysis count];i++){
        GameResult* result = [gameResultListForAnalysis objectAtIndex:[gameResultListForAnalysis count]-1-i];
        
        for(BattingResult* battingResult in result.battingResultArray){
            if(battingResult.position != 0){
                CGContextSetStrokeColorWithColor(context,
                                                 [battingResult getResultColorForAnalysisView].CGColor);
                
                CGPoint targetBasePoint = targetBasePoints[battingResult.position];
                if (battingResult.result == R_HOMERUN && battingResult.position >=7 && battingResult.position <= 11) {
                    // ホームランの場合は場所を変える（レフト・センター・ライト・左中間・右中間の場合のみ）
                    targetBasePoint = targetBasePoints[battingResult.position+5];
                }
                
                float x = arc4random()/(float)UINT_MAX*10.0;
                float y = arc4random()/(float)UINT_MAX*10.0;
                if(targetBasePoint.y+y <= 2.0f){
                    y = 2.0f-targetBasePoint.y; // 上すぎる場合は調節
                }
                
                CGPoint targetPoint = CGPointMake(targetBasePoint.x+x, targetBasePoint.y+y);

                CGPoint points[] = {basePoint, targetPoint};
                CGContextAddLines(context, points, 2);
                CGContextStrokePath(context);
            }
        }
    }
}

@end
