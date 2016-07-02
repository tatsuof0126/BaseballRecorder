//
//  APVAdManager.h
//  AppVadorSDK
//
//  Created by Hirohide Sano on 2015/06/04.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    APV_ENV_PRODUCTION,
    APV_ENV_TEST,
    APV_ENV_DEVELOPMENT
} APVEnv;

typedef enum : NSInteger {
    APV_PRELOAD_META,
    APV_PRELOAD_ALL
} APVPreloadType;

@class APVAdView, APVAdConfiguration;
@protocol APVAdManagerDelegate;
@interface APVAdManager : NSObject

@property (nonatomic, weak) id<APVAdManagerDelegate> delegate;
@property (nonatomic) APVPreloadType preloadType;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) BOOL isReady;
@property (nonatomic) APVAdView *currentPlayer;
@property (nonatomic) APVAdConfiguration *configuration;
@property (nonatomic, readonly) NSString *pubId;

/** APVAdView settings */
@property (nonatomic) BOOL soundButtonEnabled;
@property (nonatomic) BOOL replayButtonEnabled;
@property (nonatomic) BOOL completionReplayButtonEnabled;
@property (nonatomic) BOOL closeButtonEnabled;
@property (nonatomic) BOOL linkTextButtonEnabled;
@property (nonatomic) BOOL clickActionDisabled;
@property (nonatomic) BOOL equalizerHidden;
@property (nonatomic) BOOL playbackFromBeginningOnFullscreen;
@property (nonatomic) BOOL autoPlayEnabled;

- (id) initWithPubId:(NSString *) pubId withDelegate:(id<APVAdManagerDelegate>) delegate;
- (id) initWithPubId:(NSString *) pubId withDelegate:(id<APVAdManagerDelegate>) delegate withEnv: (APVEnv) env;
- (void) load;
- (void) load:(NSString *)exId;
- (void) reset;
- (UIView *) showAdForView:(UIView *)view;
- (UIView *) showAdForView:(UIView *)view withRect:(CGRect)rect;
- (void) removeAd;
- (UIView *)getCurrentAdView;
- (BOOL)isFullScreen;

#pragma mark player callbacks
- (void) didPlaying;
- (void) didPlayingStart;
- (void) didPlayingFirstQuartile;
- (void) didPlayingMidpoint;
- (void) didPlayingThirdQuartile;
- (void) didThroughSkipOffset;
- (void) didCompletion;
- (void) didClick;
- (void) didTapAction;
- (void) didClickThrough;
- (void) didClickToFullscreen;
- (void) didUnmute;
- (void) didMute;
- (void) didClose;
- (void) didReplay;
- (void) didReadyToPlayAd;
- (void) didFailedToPlayAd:(NSObject *)error;

@end


#pragma mark -

@interface APVNativeAd : NSObject

@property (nonatomic, copy) NSString* adTitle;
@property (nonatomic, copy) NSString* adDescription;

@end

#pragma mark -

@protocol APVAdManagerDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingModalView;

@optional
- (void) onReadyToPlayAd:(APVAdManager *)ad;
- (void) onReadyToPlayAd:(APVAdManager *)ad forNativeAd:(APVNativeAd *)nativeAd;
- (void) onReadyToPlayAd;
- (void) onFailedToPlayAd:(NSObject *)error;
- (BOOL) onRedirectToDefaultBrowser;
- (void) onPlayingAd;
- (void) onPlayingAdStart;
- (void) onPlayingAdFirstQuartile;
- (void) onPlayingAdMidpoint;
- (void) onPlayingAdThirdQuartile;
- (void) onCompletionAd;
- (void) onClickAd;
- (void) onTapActionAd;
- (void) onUnmuteAd;
- (void) onMuteAd;
- (void) onCloseAd;
- (void) onReplayAd;

@end