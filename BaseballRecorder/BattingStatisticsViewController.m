//
//  BattingStatisticsViewController.m
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/11/01.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import "BattingStatisticsViewController.h"
#import "GameResult.h"
#import "ConfigManager.h"
#import "AppDelegate.h"
#import "Utility.h"

@interface BattingStatisticsViewController ()

@end

@implementation BattingStatisticsViewController

@synthesize gadView;
@synthesize scrollView;
@synthesize teamStatistics;
@synthesize battingStatistics;

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
    
    // ScrollViewの高さを定義＆iPhone5対応
    scrollView.contentSize = CGSizeMake(320, 520);
    scrollView.frame = CGRectMake(0, 64, 320, 366);
    [AppDelegate adjustForiPhone5:scrollView];
    
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
    scrollView.frame = CGRectMake(0, 64, 320, 316);
    [AppDelegate adjustForiPhone5:scrollView];
}

- (void)removeAdsBar {
    if(gadView != nil && [ConfigManager isRemoveAdsFlg] == YES){
        // 広告表示していて、広告削除した場合は表示を消す
        [gadView removeFromSuperview];
        gadView.delegate = nil;
        gadView = nil;
        
        // ScrollViewの大きさ定義＆iPhone5対応
        scrollView.frame = CGRectMake(0, 64, 320, 366);
        [AppDelegate adjustForiPhone5:scrollView];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showStatistics:(NSArray*)gameResultListForCalc {
//    [self showTarget:_year team:_team];
    [self showTarget:_year team:_team leftBtn:_leftBtn rightBtn:_rightBtn];
    
    // 試合成績
    teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
    
    // 「99勝 99敗 99分  勝率 9.999」という文字列を作る
    NSMutableString* teamresultStr = [NSMutableString string];
    [teamresultStr appendFormat:@"%d勝 %d敗 %d分  ",
        teamStatistics.win, teamStatistics.lose,teamStatistics.draw];
    
    if( [teamresultStr length] <= 12 ){
        [teamresultStr appendString:@"勝率 "];
    }
    
    [teamresultStr appendString:[Utility getFloatStr:
        (float)(teamStatistics.win) / (float)(teamStatistics.win+teamStatistics.lose)
                                 appendBlank:NO]];
    
    if( [teamresultStr length] <= 19 ){
        [teamresultStr insertString:@" " atIndex:0];
    }
    
    _teamresult.text = teamresultStr;
    
    // 打撃成績
    battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
    _battingresult.text = [NSString stringWithFormat:@"%d打席  %d打数  %d安打",
                           battingStatistics.boxs, battingStatistics.atbats, battingStatistics.hits];
    
    _doubles.text = [NSString stringWithFormat:@"%d",battingStatistics.doubles];
    _triples.text = [NSString stringWithFormat:@"%d",battingStatistics.triples];
    _homeruns.text = [NSString stringWithFormat:@"%d",battingStatistics.homeruns];
    _strikeouts.text = [NSString stringWithFormat:@"%d",battingStatistics.strikeouts];
    _walks.text = [NSString stringWithFormat:@"%d",battingStatistics.walks];
    _sacrifices.text = [NSString stringWithFormat:@"%d",battingStatistics.sacrifices - battingStatistics.sacrificeflies];
    _sacrificesflies.text = [NSString stringWithFormat:@"%d",battingStatistics.sacrificeflies];
    _daten.text = [NSString stringWithFormat:@"%d",battingStatistics.daten];
    _tokuten.text = [NSString stringWithFormat:@"%d",battingStatistics.tokuten];
    _error.text = [NSString stringWithFormat:@"%d",battingStatistics.error];
    _steal.text = [NSString stringWithFormat:@"%d",battingStatistics.steal];
    _stealout.text = [NSString stringWithFormat:@"%d",battingStatistics.stealOut];
    
    _battingstat.text = [NSString stringWithFormat:@"打率 %@ 出塁率 %@ 長打率 %@",
                         [Utility getFloatStr:battingStatistics.average appendBlank:YES],
                         [Utility getFloatStr:battingStatistics.obp appendBlank:YES],
                         [Utility getFloatStr:battingStatistics.slg appendBlank:YES]];

    _battingstat2.text = [NSString stringWithFormat:@"OPS %@  IsoD %@  IsoP %@",
                          [Utility getFloatStr:battingStatistics.ops appendBlank:YES],
                          [Utility getFloatStr:battingStatistics.isod appendBlank:YES],
                          [Utility getFloatStr:battingStatistics.isop appendBlank:YES]];

    _battingstat3.text = [NSString stringWithFormat:@"盗塁成功率 %@  RC27 %@",
                          [Utility getFloatStr:battingStatistics.stealrate appendBlank:YES],
                          [Utility getFloatStr2:battingStatistics.rc27]];
}

- (void)viewDidUnload {
    [self setTeamresult:nil];
    [self setBattingresult:nil];
    [self setBattingstat:nil];
    [self setTeam:nil];
    [self setYear:nil];
    [self setDoubles:nil];
    [self setTriples:nil];
    [self setHomeruns:nil];
    [self setStrikeouts:nil];
    [self setWalks:nil];
    [self setSacrifices:nil];
    [self setDaten:nil];
    [self setTokuten:nil];
    [self setSteal:nil];
    [self setScrollView:nil];
    [self setBattingstat2:nil];
    [super viewDidUnload];
}

- (IBAction)leftButton:(id)sender {
    [self moveLeftTargetTerm];
}

- (IBAction)rightButton:(id)sender {
    [self moveRightTargetTerm];
}

- (IBAction)termChangeButton:(id)sender {
    [self makeTermPicker];
}

- (IBAction)teamChangeButton:(id)sender {
    [self makeTeamPicker];
}

- (IBAction)tweetButton:(id)sender {
    // 親クラスのメソッドを呼び出してシェア
    [super shareStatistics:SHARE_TYPE_TEXT];
}

- (IBAction)imageShareButton:(id)sender {
    // 親クラスのメソッドを呼び出してシェア
    [super shareStatistics:SHARE_TYPE_IMAGE];
}

- (NSString*)makeShareString:(int)type shareType:(int)shareType {
    // 試合結果の文言を作る
    NSMutableString* shareString = [NSMutableString string];
    
    TargetTerm* targetTerm = [ConfigManager getCalcTargetTerm];
    NSString* targetTeamStr = [ConfigManager getCalcTargetTeam];
    
    NSString* tsusanStr = @"";
    if(targetTerm.type == TERM_TYPE_ALL){
        tsusanStr = @"通算";
    } else {
        [shareString appendString:[targetTerm getTermStringForShare]];
        [shareString appendString:@"の"];
    }
    
    if([targetTeamStr isEqualToString:@"すべて"] != YES){
        [shareString appendString:targetTeamStr];
        [shareString appendString:@"での"];
    }
    [shareString appendFormat:@"%@打撃成績は、",tsusanStr];
    
    if(shareType == SHARE_TYPE_TEXT){
        
        [shareString appendFormat:@"%d打席%d打数%d安打 打率%@ 出塁率%@ 長打率%@ OPS%@ "
         ,battingStatistics.boxs, battingStatistics.atbats, battingStatistics.hits
         ,[Utility getFloatStr:battingStatistics.average appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.obp appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.slg appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.ops appendBlank:NO]];
    
        if(battingStatistics.doubles != 0){
            [shareString appendFormat:@"二塁打%d ", battingStatistics.doubles];
        }
        if(battingStatistics.triples != 0){
            [shareString appendFormat:@"三塁打%d ", battingStatistics.triples];
        }
        if(battingStatistics.homeruns != 0){
            [shareString appendFormat:@"本塁打%d ", battingStatistics.homeruns];
        }
        if(battingStatistics.strikeouts != 0){
            [shareString appendFormat:@"三振%d ", battingStatistics.strikeouts];
        }
        if(battingStatistics.walks != 0){
            [shareString appendFormat:@"四死球%d ", battingStatistics.walks];
        }
        if(battingStatistics.sacrifices != 0){
            [shareString appendFormat:@"犠打%d ", battingStatistics.sacrifices];
        }
        if(battingStatistics.daten != 0){
            [shareString appendFormat:@"打点%d ", battingStatistics.daten];
        }
        if(battingStatistics.tokuten != 0){
            [shareString appendFormat:@"得点%d ", battingStatistics.tokuten];
        }
        if(battingStatistics.error != 0){
            [shareString appendFormat:@"失策%d ", battingStatistics.error];
        }
        if(battingStatistics.steal != 0){
            [shareString appendFormat:@"盗塁%d ", battingStatistics.steal];
        }
        if(battingStatistics.stealOut != 0){
            [shareString appendFormat:@"盗塁死%d ", battingStatistics.stealOut];
        }
        [shareString appendString:@"です。 #ベボレコ"];
    } else if(shareType == SHARE_TYPE_IMAGE){
        [shareString appendFormat:@"%d打席%d打数%d安打 打率%@ 出塁率%@ 長打率%@ OPS%@ です。 #ベボレコ"
         ,battingStatistics.boxs, battingStatistics.atbats, battingStatistics.hits
         ,[Utility getFloatStr:battingStatistics.average appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.obp appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.slg appendBlank:NO]
         ,[Utility getFloatStr:battingStatistics.ops appendBlank:NO]];
    }
    
    return shareString;
}

- (NSString*)getShareURLString:(int)type shareType:(int)shareType {
    if (type == POST_FACEBOOK || type == POST_LINE){
        return @"https://itunes.apple.com/jp/app/id578136103";
    }
    return nil;
}

- (UIImage*)getShareImage:(int)type shareType:(int)shareType {
    if (shareType == SHARE_TYPE_IMAGE){
        return [self getScreenImage];
    }
    return nil;
}

- (UIImage*)getScreenImage {
    // 投稿用にScrollViewの大きさを調整・スクロールを戻す、項目を少し下に下げる、ボタンを消す
    CGRect scrollOldRect = scrollView.frame;
    // scrollView.frame = CGRectMake(0, 64, 320, 480);
    scrollView.frame = CGRectMake(0, 64, 320, 510);
    [scrollView setContentOffset:CGPointMake(0.0f, 0.0f) animated:NO];
    
    for (UIView* view in scrollView.subviews){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y+45,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    
    // _changeBtn.hidden = YES;
    _shareBtn.hidden = YES;
    _imageShareBtn.hidden = YES;
    _mailBtn.hidden = YES;
    
    // 一時的にScrollViewにタイトルバーを配置
    UILabel* tmpbar = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,40)];
    tmpbar.backgroundColor = [UIColor darkGrayColor];
    tmpbar.textColor = [UIColor whiteColor];
    tmpbar.textAlignment = NSTextAlignmentCenter;
    tmpbar.font = [UIFont boldSystemFontOfSize:17];
    tmpbar.text = @"打撃成績";
    [scrollView addSubview:tmpbar];
    
    // 一時的にラベルを貼る
    UILabel* tmplabel = [[UILabel alloc] initWithFrame:CGRectMake(160,470,150,30)];
    tmplabel.font = [UIFont systemFontOfSize:17];
    tmplabel.adjustsFontSizeToFitWidth = YES;
    tmplabel.minimumScaleFactor = 0.5f;
    tmplabel.text = @"草野球日記 ベボレコ";
    [scrollView addSubview:tmplabel];
    
    // ScrollViewの内容をContextに書き出し
    CGRect rect = scrollView.bounds;
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] set];
    CGContextFillRect(context, rect);
    [scrollView.layer renderInContext:context];
    
    // Contextに書き出した内容をUIImageとして受け取る
    UIImage* capturedUIImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // 一時的なタイトルバー・ラベルを削除
    [tmpbar removeFromSuperview];
    [tmplabel removeFromSuperview];
    
    // ScrollViewの大きさを元に戻す、ボタンを出す、項目の場所を戻す
    scrollView.frame = scrollOldRect;
    // _changeBtn.hidden = NO;
    _shareBtn.hidden = NO;
    _imageShareBtn.hidden = NO;
    _mailBtn.hidden = NO;
    
    for (UIView* view in scrollView.subviews){
        CGRect oldRect = view.frame;
        CGRect newRect = CGRectMake(oldRect.origin.x, oldRect.origin.y-45,
                                    oldRect.size.width, oldRect.size.height);
        view.frame = newRect;
    }
    
    return capturedUIImage;
}

- (IBAction)mailButton:(id)sender {
    MFMailComposeViewController *mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    // TOを作る
    NSString* sendto = [ConfigManager getDefaultSendTo];
    NSArray* sendtoArray = [sendto componentsSeparatedByString:@","];
    
    // Subjectを作る
    NSString* mailTitle = [super getMailTitle:BATTING_RESULT];
    
    // 本文を作る
    NSMutableString* bodyString = [NSMutableString string];

//    NSArray* gameResultListForCalc = [super getGameResultListForCalc];
//    TeamStatistics* teamStatistics = [TeamStatistics calculateTeamStatistics:gameResultListForCalc];
//    BattingStatistics* battingStatistics = [BattingStatistics calculateBattingStatistics:gameResultListForCalc];
    
    [bodyString appendString:mailTitle];
    [bodyString appendString:@"\n\n"];
    
    [bodyString appendString:[NSString stringWithFormat:@"試合成績：%@\n\n",[teamStatistics getMailBody]]];
    
    [bodyString appendString:@"打撃成績\n"];
    [bodyString appendString:[battingStatistics getMailBody]];
    
    
    [mailPicker setToRecipients:sendtoArray];
    [mailPicker setSubject:[NSString stringWithFormat:@"【ベボレコ】%@ @ベボレコ",mailTitle]];
    [mailPicker setMessageBody:bodyString isHTML:NO];
    
    // メール送信用のモーダルビューを表示
    [self presentViewController:mailPicker animated:YES completion:nil];
}
 
// メール送信処理完了時のイベント
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result){
        // キャンセル
        case MFMailComposeResultCancelled:
            break;
        // 保存
        case MFMailComposeResultSaved:
            break;
        // 送信成功
        case MFMailComposeResultSent: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                message:@"送信しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        // 送信失敗
        case MFMailComposeResultFailed: {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                message:@"送信に失敗しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            break;
        }
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)adjustGameResultListForRecent5:(NSMutableArray*)gameResultListForCalc {
    // 「最近５試合」の場合は直近の５件に絞る
    if(gameResultListForCalc.count > 5){
        [gameResultListForCalc removeObjectsInRange:
         NSMakeRange(5, gameResultListForCalc.count-5)];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // 広告が削除された場合の対応
    [self removeAdsBar];
}

- (void)dealloc {
    gadView.delegate = nil;
    gadView = nil;
}

@end
