//
//  YJBAdmobAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdmobAdapter.h"

@import GoogleMobileAds;

@interface YJBAdmobAdapter () <GADBannerViewDelegate, GADInterstitialDelegate>
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
        [self performSelector:@selector(showBannerViewTimeout) withObject:nil afterDelay:10];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.gadBannerView.delegate = nil;
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView = nil;
}


#pragma mark - GADBannerViewDelegate

/// Tells the delegate that an ad request successfully received an ad. The delegate may want to add
/// the banner view to the view hierarchy if it hasn't been added yet.
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}

/// Tells the delegate that an ad request failed. The failure is normally due to network
/// connectivity or ad availablility (i.e., no fill).
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"加载Banner失败：%@", error.localizedDescription);
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error.localizedDescription];
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


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.gadBannerView.delegate = nil;
    [self.gadBannerView removeFromSuperview];
    self.gadBannerView = nil;
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:@"超时"];
}

@end
