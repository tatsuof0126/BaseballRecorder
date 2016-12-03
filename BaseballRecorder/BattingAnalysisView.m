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
        CGPointMake(27.0,  145.0),
        CGPointMake(253.0, 145.0)
    };
    
    CGPoint targetBasePointsHomerun[] = {
        CGPointMake(25.0,  48.0),  // レフトホームラン
        CGPointMake(140.0, 0.0),   // センターホームラン
        CGPointMake(255.0, 48.0),  // ライトホームラン
        CGPointMake(65.0,  18.0),  // 左中間ホームラン
        CGPointMake(215.0, 18.0),  // 右中間ホームラン
        CGPointMake(0.0,   122.0), // レフト線ホームラン
        CGPointMake(280.0, 122.0)  // ライト線ホームラン
    };
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // 凡例の線を描画
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
    
    // 打撃成績を集約
    NSMutableArray* battingResultArrayForView = [NSMutableArray array];
    for(GameResult* gameResult in gameResultListForAnalysis){
        [battingResultArrayForView addObjectsFromArray:gameResult.battingResultArray];
    }
    // 描画順をランダムに入れ替える
    for (int i = (int)battingResultArrayForView.count-1; i>0; i--) {
        int randomNum = arc4random() % i;
        [battingResultArrayForView exchangeObjectAtIndex:i withObjectAtIndex:randomNum];
    }
    
    // 300打席以上になったら線を細くする
    if(battingResultArrayForView.count >= 400){
        CGContextSetLineWidth(context, 2.5);
    } else if(battingResultArrayForView.count >= 200){
        CGContextSetLineWidth(context, 3.0);
    } else {
        CGContextSetLineWidth(context, 3.5);
    }
    CGContextSetLineCap(context, kCGLineCapRound);

    // 直線を描画
    for(BattingResult* battingResult in battingResultArrayForView){
        if(battingResult.position != 0){
            CGContextSetStrokeColorWithColor(context, [battingResult getResultColorForAnalysisView].CGColor);
            
            CGPoint targetBasePoint = targetBasePoints[battingResult.position];
            if (battingResult.result == R_HOMERUN &&
                battingResult.position >=7 && battingResult.position <= 13) {
                // ホームランの場合は場所を変える（レフト・センター・ライト・左中間・右中間・レフト線・ライト線のみ）
                targetBasePoint = targetBasePointsHomerun[battingResult.position-7];
            }
            
            // float x = arc4random()/(float)UINT_MAX*10.0-5;
            // float y = arc4random()/(float)UINT_MAX*10.0-5;
            float x = arc4random()/(float)UINT_MAX*30.0f-15.0f;
            float y = arc4random()/(float)UINT_MAX*30.0f-15.0f;
            
            float targetX = targetBasePoint.x + x;
            float targetY = targetBasePoint.y + y;
            
            // 上すぎる場合は調節
            if(targetY <= 2.0f){
                targetY = 2.0f;
            }
            
            // ファールゾーンに出ている場合はフェアゾーンに戻す
            float yoko = fabs(targetX - 140.0);
            float maxtate = 258.0 - yoko;
            if(targetY > maxtate){
                targetY = maxtate;
            }
            
            CGPoint targetPoint = CGPointMake(targetX, targetY);
            
            CGPoint points[] = {basePoint, targetPoint};
            CGContextAddLines(context, points, 2);
            CGContextStrokePath(context);
        }
    }
}

@end
