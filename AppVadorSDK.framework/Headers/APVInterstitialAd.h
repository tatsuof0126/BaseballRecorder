//
//  APVInterstitialAd.h
//  AppVadorSDK
//
//  Created by Hirohide Sano on 2015/07/23.
//
//

#import <UIKit/UIKit.h>
#import "APVAdManager.h"

@protocol APVInterstitialAdDelegate;

@interface APVInterstitialAd : UIViewController

@property (nonatomic, copy) NSString *pubId;
@property (nonatomic) APVEnv env;
@property (nonatomic, readonly) BOOL isReady;
@property (nonatomic, weak) id<APVInterstitialAdDelegate> delegate;

- (id)initWithPubId:(NSString *)pubId withDelegate:(id<APVInterstitialAdDelegate>)delegate;
- (id)initWithPubId:(NSString *)pubId withDelegate:(id<APVInterstitialAdDelegate>)delegate withEnv:(APVEnv)env;
- (void)load;
- (void)presentFromRootViewController:(UIViewController *)rootViewController;
- (void)dismiss;

@end

@protocol APVInterstitialAdDelegate <NSObject>

@optional
- (void) interstitialDidReadyToPlay;
- (void) interstitialDidPlaying;
- (void) interstitialDidCompletion;
- (void) interstitialDidClick;
- (void) interstitialDidUnmute;
- (void) interstitialDidMute;
- (void) interstitialDidClose;
- (void) interstitialDidFailedToPlay:(NSObject *)error;
- (void) interstitialDidReplay;
- (void) interstitialDidDismiss;

@end