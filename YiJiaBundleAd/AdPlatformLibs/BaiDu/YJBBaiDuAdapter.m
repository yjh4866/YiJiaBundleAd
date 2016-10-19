//
//  YJBBaiDuAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBBaiDuAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdCommonConfig.h>
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#import <BaiduMobAdSDK/BaiduMobAdInterstitial.h>

@interface YJBBaiDuAdapter () <BaiduMobAdViewDelegate, BaiduMobAdInterstitialDelegate> {
    BOOL _interstitialIsLoading;
}
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *placeIdB;
@property (nonatomic, copy) NSString *placeIdI;
@property (nonatomic, strong) BaiduMobAdView *bdBannerView;
@property (nonatomic, strong) BaiduMobAdInterstitial *bdInterstitial;
@end

@implementation YJBBaiDuAdapter

+ (void)load
{
    NSLog(@"当前百度广告SDK版本：%@", SDK_VERSION_IN_MSSP);
}

+ (instancetype)sharedInstance
{
    static YJBBaiDuAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBBaiDuAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// 获取广告平台类型
- (YJBAdPlatform)platformType
{
    return YJBAdPlatform_BaiDu;
}

// 插屏是否加载中
- (BOOL)interstitialIsLoading
{
    return _interstitialIsLoading;
}
// 插屏广告是否准备好了
- (BOOL)interstitialIsReady
{
    return self.bdInterstitial && self.bdInterstitial.isReady;
}

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam
{
    self.appId = dicParam[@"app"];
    self.placeIdB = dicParam[@"bp"];
    self.placeIdI = dicParam[@"ip"];
}


#pragma mark - Public

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    if (self.appId.length > 0 && self.placeIdB.length > 0) {
        self.bdBannerView.delegate = nil;
        [self.bdBannerView removeFromSuperview];
        self.bdBannerView = [[BaiduMobAdView alloc] initWithFrame:CGRectMake(0, 1, kBaiduAdViewSizeDefaultWidth, kBaiduAdViewSizeDefaultHeight)];
        self.bdBannerView.AdType = BaiduMobAdViewTypeBanner;
        self.bdBannerView.AdUnitTag = self.placeIdB;
        self.bdBannerView.delegate = self;
        [bannerSuperView addSubview:self.bdBannerView];
        // 加载广告
        [self.bdBannerView start];
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
    self.bdBannerView.delegate = nil;
    [self.bdBannerView removeFromSuperview];
    self.bdBannerView = nil;
}

// 加载插屏广告
- (BOOL)loadInterstitial;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    if (self.appId.length > 0 && self.placeIdI.length > 0) {
        self.bdInterstitial.delegate = nil;
        if (nil == self.bdInterstitial || !self.bdInterstitial.isReady) {
            self.bdInterstitial = [[BaiduMobAdInterstitial alloc] init];
            self.bdInterstitial.AdUnitTag = self.placeIdI;
            self.bdInterstitial.interstitialType = BaiduMobAdViewTypeInterstitialOther;
        }
        self.bdInterstitial.delegate = self;
        // 加载
        [self.bdInterstitial load];
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
    [self.bdInterstitial presentFromRootViewController:[self topVC]];
}


#pragma mark - BaiduMobAdViewDelegate

/**
 *  应用的APPID
 */
- (NSString *)publisherId
{
    return self.appId;
}

/**
 *  启动位置信息
 */
- (BOOL)enableLocation
{
    return NO;
}

/**
 *  广告将要被载入
 */
- (void)willDisplayAd:(BaiduMobAdView *)adview
{
    
}

/**
 *  广告载入失败
 */
- (void)failedDisplayAd:(BaiduMobFailReason)reason
{
    NSString *errMsg = @"";
    switch (reason) {
        case BaiduMobFailReason_NOAD:
            errMsg = @"没广告";
            break;
        case BaiduMobFailReason_EXCEPTION:
            errMsg = @"网络或其它异常";
            break;
        case BaiduMobFailReason_FRAME:
            errMsg = @"广告尺寸异常";
            break;
        default:
            errMsg = [NSString stringWithFormat:@"%@", @(reason)];
            break;
    }
    NSLog(@"加载Banner失败：%@", errMsg);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: errMsg}];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error];
}

/**
 *  本次广告展示成功时的回调
 */
- (void)didAdImpressed
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}

/**
 *  本次广告展示被用户点击时的回调
 */
- (void)didAdClicked
{
    [self.bannerDelegate yjbAdapterBannerClicked:self];
}

/**
 *  在用户点击完广告条出现全屏广告页面以后，用户关闭广告时的回调
 */
- (void)didDismissLandingPage
{
    
}

/**
 *  用户点击关闭按钮关闭广告后的回调
 */
- (void)didAdClose
{
    
}


#pragma mark - BaiduMobAdInterstitialDelegate

/**
 *  广告预加载成功
 */
- (void)interstitialSuccessToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapterInterstitialLoadSuccess:self];
}

/**
 *  广告预加载失败
 */
- (void)interstitialFailToLoadAd:(BaiduMobAdInterstitial *)interstitial
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"百度预加载插屏失败"}];
    [self.interstitialDelegate yjbAdapter:self interstitialLoadFailure:error];
}

/**
 *  广告即将展示
 */
- (void)interstitialWillPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    
}

/**
 *  广告展示成功
 */
- (void)interstitialSuccessPresentScreen:(BaiduMobAdInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialShowSuccess:self];
}

/**
 *  广告展示失败
 */
- (void)interstitialFailPresentScreen:(BaiduMobAdInterstitial *)interstitial withError:(BaiduMobFailReason) reason
{
    
}

/**
 *  广告展示被用户点击时的回调
 */
- (void)interstitialDidAdClicked:(BaiduMobAdInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialClicked:self];
}

/**
 *  广告展示结束
 */
- (void)interstitialDidDismissScreen:(BaiduMobAdInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialCloseFinished:self];
}

/**
 *  广告详情页被关闭
 */
- (void)interstitialDidDismissLandingPage:(BaiduMobAdInterstitial *)interstitial
{
    
}


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.bdBannerView.delegate = nil;
    [self.bdBannerView removeFromSuperview];
    self.bdBannerView = nil;
    //
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"超时"}];
    __weak id delegate = self.bannerDelegate;
    self.bannerDelegate = nil;
    [delegate yjbAdapter:self bannerShowFailure:error];
}

- (void)loadInterstitialTimeout
{
    NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"超时"}];
    __weak id delegate = self.interstitialDelegate;
    self.interstitialDelegate = nil;
    [delegate yjbAdapter:self interstitialLoadFailure:error];
}

@end
