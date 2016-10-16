//
//  YJBGDTAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/24.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBGDTAdapter.h"
#import "GDTMobBannerView.h"
#import "GDTMobInterstitial.h"

@interface YJBGDTAdapter () <GDTMobBannerViewDelegate, GDTMobInterstitialDelegate> {
    BOOL _interstitialIsLoading;
}
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *placeIdB;
@property (nonatomic, copy) NSString *placeIdI;
@property (nonatomic, strong) GDTMobBannerView *gdtBannerView;
@property (nonatomic, strong) GDTMobInterstitial *gdtInterstitial;
@end

@implementation YJBGDTAdapter

+ (void)load
{
//    NSLog(@"当前广点通广告SDK版本：%@", @"4.4.8");
}

+ (instancetype)sharedInstance
{
    static YJBGDTAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBGDTAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// 获取广告平台类型
- (YJBAdPlatform)platformType
{
    return YJBAdPlatform_GDT;
}

// 插屏是否加载中
- (BOOL)interstitialIsLoading
{
    return _interstitialIsLoading;
}
// 插屏广告是否准备好了
- (BOOL)interstitialIsReady
{
    return self.gdtInterstitial && self.gdtInterstitial.isReady;
}

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam
{
    self.appKey = dicParam[@"app"];
    self.placeIdB = dicParam[@"bp"];
    self.placeIdI = dicParam[@"ip"];
}


#pragma mark - Public

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    if (self.appKey.length > 0 && self.placeIdB.length > 0) {
        self.gdtBannerView.delegate = nil;
        [self.gdtBannerView removeFromSuperview];
        self.gdtBannerView = [[GDTMobBannerView alloc] initWithFrame:CGRectMake(0, 0, 320, 50) appkey:self.appKey placementId:self.placeIdB];
        self.gdtBannerView.interval = 2*displayTime;
        self.gdtBannerView.currentViewController = [self topVC];
        self.gdtBannerView.showCloseBtn = NO;
        self.gdtBannerView.delegate = self;
        [bannerSuperView addSubview:self.gdtBannerView];
        // 加载广告
        [self.gdtBannerView loadAdAndShow];
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
    self.gdtBannerView.delegate = nil;
    [self.gdtBannerView removeFromSuperview];
    self.gdtBannerView = nil;
}

// 加载插屏广告
- (BOOL)loadInterstitial;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    if (self.appKey.length > 0 && self.placeIdI.length > 0) {
        self.gdtInterstitial.delegate = nil;
        if (nil == self.gdtInterstitial || !self.gdtInterstitial.isReady) {
            self.gdtInterstitial = [[GDTMobInterstitial alloc] initWithAppkey:self.appKey placementId:self.placeIdI];
        }
        self.gdtInterstitial.delegate = self;
        // 加载
        [self.gdtInterstitial loadAd];
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
    [self.gdtInterstitial presentFromRootViewController:[self topVC]];
}


#pragma mark - GDTMobBannerViewDelegate

- (void)bannerViewMemoryWarning
{
    
}

/**
 *  请求广告条数据成功后调用
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)bannerViewDidReceived
{
    
}

/**
 *  请求广告条数据失败后调用
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)bannerViewFailToReceived:(NSError *)error
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error];
}

/**
 *  应用进入后台时调用
 *  详解:当点击应用下载或者广告调用系统程序打开，应用将被自动切换到后台
 */
- (void)bannerViewWillLeaveApplication
{
    
}

/**
 *  banner条被用户关闭时调用
 *  详解:当打开showCloseBtn开关时，用户有可能点击关闭按钮从而把广告条关闭
 */
- (void)bannerViewWillClose
{
    
}
/**
 *  banner条曝光回调
 */
- (void)bannerViewWillExposure
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}
/**
 *  banner条点击回调
 */
- (void)bannerViewClicked
{
    [self.bannerDelegate yjbAdapterBannerClicked:self];
}

/**
 *  banner广告点击以后即将弹出全屏广告页
 */
- (void)bannerViewWillPresentFullScreenModal
{
    
}
/**
 *  banner广告点击以后弹出全屏广告页完毕
 */
- (void)bannerViewDidPresentFullScreenModal
{
    
}
/**
 *  全屏广告页即将被关闭
 */
- (void)bannerViewWillDismissFullScreenModal
{
    
}
/**
 *  全屏广告页已经被关闭
 */
- (void)bannerViewDidDismissFullScreenModal
{
    
}


#pragma mark - GDTMobInterstitialDelegate

/**
 *  广告预加载成功回调
 *  详解:当接收服务器返回的广告数据成功后调用该函数
 */
- (void)interstitialSuccessToLoadAd:(GDTMobInterstitial *)interstitial
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapterInterstitialLoadSuccess:self];
}

/**
 *  广告预加载失败回调
 *  详解:当接收服务器返回的广告数据失败后调用该函数
 */
- (void)interstitialFailToLoadAd:(GDTMobInterstitial *)interstitial error:(NSError *)error
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapter:self interstitialLoadFailure:error];
}

/**
 *  插屏广告将要展示回调
 *  详解: 插屏广告即将展示回调该函数
 */
- (void)interstitialWillPresentScreen:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  插屏广告视图展示成功回调
 *  详解: 插屏广告展示成功回调该函数
 */
- (void)interstitialDidPresentScreen:(GDTMobInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialShowSuccess:self];
}

/**
 *  插屏广告展示结束回调
 *  详解: 插屏广告展示结束回调该函数
 */
- (void)interstitialDidDismissScreen:(GDTMobInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialCloseFinished:self];
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)interstitialApplicationWillEnterBackground:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  插屏广告曝光回调
 */
- (void)interstitialWillExposure:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  插屏广告点击回调
 */
- (void)interstitialClicked:(GDTMobInterstitial *)interstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialClicked:self];
}

/**
 *  点击插屏广告以后即将弹出全屏广告页
 */
- (void)interstitialAdWillPresentFullScreenModal:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  点击插屏广告以后弹出全屏广告页
 */
- (void)interstitialAdDidPresentFullScreenModal:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  全屏广告页将要关闭
 */
- (void)interstitialAdWillDismissFullScreenModal:(GDTMobInterstitial *)interstitial
{
    
}

/**
 *  全屏广告页被关闭
 */
- (void)interstitialAdDidDismissFullScreenModal:(GDTMobInterstitial *)interstitial
{
    
}


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.gdtBannerView.delegate = nil;
    [self.gdtBannerView removeFromSuperview];
    self.gdtBannerView = nil;
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
