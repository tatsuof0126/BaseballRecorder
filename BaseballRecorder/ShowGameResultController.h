//
//  ShowGameResultController.h
//  BaseballRecorder
//
//  Created by 藤原 達郎 on 2012/10/31.
//  Copyright (c) 2012年 Tatsuo Fujiwara. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Social/Social.h>
#import <Twitter/Twitter.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <ADG/ADGManagerViewController.h>
#import <ADG/ADGInterstitial.h>
#import <FBSDKShareKit/FBSDKSharing.h>

#define POST_TWITTER  1
#define POST_FACEBOOK 2
#define POST_LINE     3

@interface ShowGameResultController : UIViewController
        <MFMailComposeViewControllerDelegate, ADGManagerViewControllerDelegate, UIActionSheetDelegate, FBSDKSharingDelegate, ADGInterstitialDelegate>  {
    ADGManagerViewController *adg_;
}

@property (nonatomic, retain) ADGManagerViewController *adg;
// @property(nonatomic , retain) ADGInterstitial *interstitial;

@property (weak, nonatomic) IBOutlet UILabel *date;
@property (weak, nonatomic) IBOutlet UILabel *place;
// @property (weak, nonatomic) IBOutlet UILabel *myteam;
// @property (weak, nonatomic) IBOutlet UILabel *otherteam;
@property (strong, nonatomic) IBOutlet UILabel *tagTextLabel;
@property (strong, nonatomic) IBOutlet UILabel *tagText;
// @property (strong, nonatomic) IBOutlet UILabel *resultLabel;
@property (weak, nonatomic) IBOutlet UILabel *result;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollview;

@property (weak, nonatomic) IBOutlet UILabel *battingResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *datenLabel;
@property (weak, nonatomic) IBOutlet UILabel *tokutenLabel;
@property (weak, nonatomic) IBOutlet UILabel *stealLabel;
@property (weak, nonatomic) IBOutlet UILabel *daten;
@property (weak, nonatomic) IBOutlet UILabel *tokuten;
@property (weak, nonatomic) IBOutlet UILabel *steal;

@property (weak, nonatomic) IBOutlet UILabel *pitchingResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *inningLabel;
@property (weak, nonatomic) IBOutlet UILabel *inning;
@property (weak, nonatomic) IBOutlet UILabel *sekinin;
@property (weak, nonatomic) IBOutlet UILabel *hiandaLabel;
@property (weak, nonatomic) IBOutlet UILabel *hianda;
@property (weak, nonatomic) IBOutlet UILabel *hihomerunLabel;
@property (weak, nonatomic) IBOutlet UILabel *hihomerun;
@property (weak, nonatomic) IBOutlet UILabel *dassanshinLabel;
@property (weak, nonatomic) IBOutlet UILabel *dassanshin;
@property (weak, nonatomic) IBOutlet UILabel *yoshikyuLabel;
@property (weak, nonatomic) IBOutlet UILabel *yoshikyu;
@property (weak, nonatomic) IBOutlet UILabel *yoshikyu2Label;
@property (weak, nonatomic) IBOutlet UILabel *yoshikyu2;
@property (weak, nonatomic) IBOutlet UILabel *shittenLabel;
@property (weak, nonatomic) IBOutlet UILabel *shitten;
@property (weak, nonatomic) IBOutlet UILabel *jisekitenLabel;
@property (weak, nonatomic) IBOutlet UILabel *jisekiten;
@property (weak, nonatomic) IBOutlet UILabel *tamakazuLabel;
@property (weak, nonatomic) IBOutlet UILabel *tamakazu;

@property (strong, nonatomic) IBOutlet UILabel *memoLabel;
@property (strong, nonatomic) IBOutlet UITextView *memo;

@property (strong, nonatomic) IBOutlet UIButton *leftBtn;
@property (strong, nonatomic) IBOutlet UIButton *rightBtn;

@property (weak, nonatomic) IBOutlet UIButton *tweetButton;
@property (weak, nonatomic) IBOutlet UIButton *mailButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property BOOL posted;

- (IBAction)arrowButton:(id)sender;

- (IBAction)tweetButton:(id)sender;

- (IBAction)mailButton:(id)sender;

- (IBAction)deleteButton:(id)sender;

- (IBAction)backButton:(id)sender;

- (IBAction)editButton:(id)sender;

@end
