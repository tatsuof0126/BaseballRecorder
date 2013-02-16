//
//  PitchingStatisticsController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2013/02/13.
//  Copyright (c) 2013年 Tatsuo Fujiwara. All rights reserved.
//

#import "PitchingStatisticsController.h"
#import "GameResultManager.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "TeamStatistics.h"
#import "PitchingStatistics.h"

@interface PitchingStatisticsController ()

@end

@implementation PitchingStatisticsController

@synthesize gameResultList;
@synthesize gameResultListOfYear;
@synthesize yearList;
@synthesize teamList;
@synthesize targetyear;
@synthesize targetteam;
@synthesize targetPicker;
@synthesize targetToolbar;

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
}
 
- (void)showStatistics:(NSArray*)gameResultListForCalc {
    [self showTarget:_year team:_team];
    
    PitchingStatistics* pitchingStatistics
        = [PitchingStatistics calculatePitchingStatistics:gameResultListForCalc];
    _pitchingresult.text = [NSString stringWithFormat:@"%d試合 %d勝 %d敗 %dセーブ %dホールド",
                       pitchingStatistics.games, pitchingStatistics.win, pitchingStatistics.lose,
                       pitchingStatistics.save, pitchingStatistics.hold];
    
    _inning.text = [pitchingStatistics getInningString];
    _era.text = [PitchingStatisticsController getFloatStr:pitchingStatistics.era];
    _hianda.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hianda];
    _hihomerun.text = [NSString stringWithFormat:@"%d",pitchingStatistics.hihomerun];
    _dassanshin.text = [NSString stringWithFormat:@"%d",pitchingStatistics.dassanshin];
    _yoshikyu.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu];
    _yoshikyu2.text = [NSString stringWithFormat:@"%d",pitchingStatistics.yoshikyu2];
    _shitten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.shitten];
    _jisekiten.text = [NSString stringWithFormat:@"%d",pitchingStatistics.jisekiten];
    _kanto.text = [NSString stringWithFormat:@"%d",pitchingStatistics.kanto];
    _whip.text = [PitchingStatisticsController getFloatStr:pitchingStatistics.whip];
    _k9.text = [PitchingStatisticsController getFloatStr:pitchingStatistics.k9];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeButton:(id)sender {
    [self makeResultPiker];
}

+ (NSString*)getFloatStr:(float)floatvalue {
    if(isnan(floatvalue) == YES || isinf(floatvalue)){
        return @"-.--";
    }
    
    NSString* floatStr = [NSString stringWithFormat:@"%0.02f",floatvalue];
    
//    if(floatvalue < 1.0){
//        floatStr = [[floatStr substringFromIndex:1] stringByAppendingString:@" "];
//    }
    
    return floatStr;
}

- (void)viewDidUnload {
    [self setYear:nil];
    [self setTeam:nil];
    [self setPitchingresult:nil];
    [self setInning:nil];
    [self setEra:nil];
    [self setHianda:nil];
    [self setHihomerun:nil];
    [self setDassanshin:nil];
    [self setYoshikyu:nil];
    [self setYoshikyu2:nil];
    [self setShitten:nil];
    [self setJisekiten:nil];
    [self setKanto:nil];
    [self setWhip:nil];
    [self setK9:nil];
    [super viewDidUnload];
}
@end
