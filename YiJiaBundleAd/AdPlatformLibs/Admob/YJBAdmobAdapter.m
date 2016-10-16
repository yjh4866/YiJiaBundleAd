//
//  YJBAdmobAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdmobAdapter.h"

@import GoogleMobileAds;

@interface YJBAdmobAdapter () <GADBannerViewDelegate, GADInterstitialDelegate> {
    BOOL _interstitialIsLoading;
}
@property (nonatomic, copy) NSString *adUnitIDB;
@property (nonatomic, copy) NSString *adUnitIDI;
@property (nonatomic, strong) GADBannerView *gadBannerView;
@property (nonatomic, strong) GADInterstitial *gadInterstitial;
@end

@implementation YJBAdmobAdapter

+ (void)load
{
    NSLog(@"当前Admob SDK版本：%@", [GADRequest sdkVersion]);
}

+ (instancetype)sharedInstance
{
    static YJBAdmobAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBAdmobAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// 获取广告平台类型
- (YJBAdPlatform)platformType
{
    return YJBAdPlatform_Admob;
}

// 插屏是否加载中
- (BOOL)interstitialIsLoading
{
    return _interstitialIsLoading;
}
// 插屏广告是否准备好了
- (BOOL)interstitialIsReady
{
    return self.gadInterstitial && self.gadInterstitial.isReady && !self.gadInterstitial.hasBeenUsed;
}

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam
{
    self.adUnitIDB = dicParam[@"buid"];
    self.adUnitIDI = dicParam[@"iuid"];
}


#pragma mark - Public

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    if (self.adUnitIDB.length > 0) {
        self.gadBannerView.delegate = nil;
        [self.gadBannerView removeFromSuperview];
        self.gadBannerView = [[GADBannerView alloc] initWithAdSize:UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone?kGADAdSizeBanner:kGADAdSizeLeaderboard];
        self.gadBannerView.adUnitID = self.adUnitIDB;
        self.gadBannerView.rootViewController = [self topVC];
        self.gadBannerView.delegate = self;
        [bannerSuperView addSubview:self.gadBannerView];
        self.gadBannerView.center = CGPointMake(bannerSuperView.bounds.size.width/2,
                                                bannerSuperView.bounds.size.height/2);
        // 加载广告
        GADRequest *gadRequest = [GADRequest request];
        if (self.testDevices.count > 0) {
            gadRequest.testDevices = [@[kGADSimulatorID] arrayByAddingObjectsFromArray:self.testDevices];
        }
        else {
            gadRequest.testDevices = @[kGADSimulatorID];
        }
        [self.gadBannerView loadRequest:gadRequest];
        // 超时处理
        [self performSelector:@selector(showBannerViewTimeout) withObject:nil afterDelay:5];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    self.gadBannerView.delegate = nil;
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView = nil;
}

// 加载插屏广告
- (BOOL)loadInterstitial;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    if (self.adUnitIDI.length > 0) {
        self.gadInterstitial.delegate = nil;
        if (nil == self.gadInterstitial || self.gadInterstitial.hasBeenUsed) {
            self.gadInterstitial = [[GADInterstitial alloc] initWithAdUnitID:self.adUnitIDI];
        }
        self.gadInterstitial.delegate = self;
        // 加载
        GADRequest *gadRequest = [GADRequest request];
        if (self.testDevices.count > 0) {
            gadRequest.testDevices = [@[kGADSimulatorID] arrayByAddingObjectsFromArray:self.testDevices];
        }
        else {
            gadRequest.testDevices = @[kGADSimulatorID];
        }
        [self.gadInterstitial loadRequest:gadRequest];
        _interstitialIsLoading = YES;
        // 超时处理
        [self performSelector:@selector(loadInterstitialTimeout) withObject:nil afterDelay:5];
        return YES;
    }
    else {
        _interstitialIsLoading = NO;
    }
    return NO;
}

// 显示插屏广告
- (void)showInterstitial
{
    [self.gadInterstitial presentFromRootViewController:[self topVC]];
}


#pragma mark - GADBannerViewDelegate

/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"加载Banner失败：%@", error.localizedDescription);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error];
}

/// Tells the delegate that a full screen view will be presented in response to the user clicking on
/// an ad. The delegate may want to pause animations and time sensitive interactions.
- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.bannerDelegate yjbAdapterBannerClicked:self];
}

/// Tells the delegate that the full screen view will be dismissed.
- (void)adViewWillDismissScreen:(GADBannerView *)bannerView
{
    
}

/// Tells the delegate that the full screen view has been dismissed. The delegate should restart
/// anything paused while handling adViewWillPresentScreen:.
- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    
}

/// Tells the delegate that the user click will open another app, backgrounding the current
/// application. The standard UIApplicationDelegate methods, like applicationDidEnterBackground:,
/// are called immediately before this method is called.
- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    [self.bannerDelegate yjbAdapterBannerClicked:self];
}


#pragma mark - GADInterstitialDelegate

/// Called when an interstitial ad request succeeded. Show it at the next transition point in your
/// application such as when transitioning between view controllers.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapterInterstitialLoadSuccess:self];
}

/// Called when an interstitial ad request completed without an interstitial to
/// show. This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapter:self interstitialLoadFailure:error];
}

/// Called just before presenting an interstitial. After this method finishes the interstitial will
/// animate onto the screen. Use this opportunity to stop animations and save the state of your
/// application in case the user leaves while the interstitial is on screen (e.g. to visit the App
/// Store from a link on the interstitial).
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    [self.interstitialDelegate yjbAdapterInterstitialShowSuccess:self];
}

/// Called when |ad| fails to present.
- (void)interstitialDidFailToPresentScreen:(GADInterstitial *)ad
{
    
}

/// Called before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    
}

/// Called just after dismissing an interstitial and it has animated off the screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self.interstitialDelegate yjbAdapterInterstitialCloseFinished:self];
}

/// Called just before the application will background or terminate because the user clicked on an
/// ad that will launch another application (such as the App Store). The normal
/// UIApplicationDelegate methods, like applicationDidEnterBackground:, will be called immediately
/// before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    
}


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.gadBannerView.delegate = nil;
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView = nil;
    //
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"超时"}];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error];
    self.bannerDelegate = nil;
}

- (void)loadInterstitialTimeout
{
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"超时"}];
    [self.interstitialDelegate yjbAdapter:self interstitialLoadFailure:error];
    self.interstitialDelegate = nil;
}

@end
