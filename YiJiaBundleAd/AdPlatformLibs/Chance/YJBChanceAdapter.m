//
//  YJBChanceAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBChanceAdapter.h"
#import "ChanceAd.h"
#import "CSBannerView.h"
#import "CSInterstitial.h"

@interface YJBChanceAdapter () <CSBannerViewDelegate, CSInterstitialDelegate> {
    BOOL _interstitialIsLoading;
}
@property (nonatomic, copy) NSString *publisherId;
@property (nonatomic, strong) CSBannerView *csBannerView;
@end

@implementation YJBChanceAdapter

+ (void)load
{
    NSLog(@"当前畅思广告SDK版本：%@", [ChanceAd sdkVersion]);
}

+ (instancetype)sharedInstance
{
    static YJBChanceAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBChanceAdapter alloc] init];
    });
    return sharedInstance;
}


#pragma mark - Override

// 获取广告平台类型
- (YJBAdPlatform)platformType
{
    return YJBAdPlatform_Chance;
}

// 插屏是否加载中
- (BOOL)interstitialIsLoading
{
    return _interstitialIsLoading;
}
// 插屏广告是否准备好了
- (BOOL)interstitialIsReady
{
    return [CSInterstitial sharedInterstitial].isReady;
}

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam
{
    self.publisherId = dicParam[@"pid"];
    [ChanceAd startSession:self.publisherId];
    [ChanceAd openInAppWhenNoJailBroken:YES];
}


#pragma mark - Public

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    if (self.publisherId.length > 0) {
        self.csBannerView.delegate = nil;
        [self.csBannerView removeFromSuperview];
        self.csBannerView = [[CSBannerView alloc] init];
        self.csBannerView.delegate = self;
        [bannerSuperView addSubview:self.csBannerView];
        // 加载广告
        CSADRequest *csRequest = [CSADRequest requestWithRequestInterval:2*displayTime andDisplayTime:2*displayTime];
        [self.csBannerView loadRequest:csRequest];
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
    self.csBannerView.delegate = nil;
    [self.csBannerView removeFromSuperview];
    self.csBannerView = nil;
}

// 加载插屏广告
- (BOOL)loadInterstitial;
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    if (self.publisherId.length > 0) {
        [CSInterstitial sharedInterstitial].loadNextWhenClose = NO;
        // 加载
        [[CSInterstitial sharedInterstitial] loadInterstitial];
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
    [[CSInterstitial sharedInterstitial] showInterstitial];
}


#pragma mark - CSBannerViewDelegate

// Banner广告发出请求
- (void)csBannerViewRequestAD:(CSBannerView *)csBannerView
{
    
}
// Banner广告展现失败
- (void)csBannerView:(CSBannerView *)csBannerView
       showAdFailure:(CSError *)csError
{
    NSLog(@"加载Banner失败：%@", csError.localizedDescription);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:csError];
}
// 将要展示Banner广告
- (void)csBannerViewWillPresentScreen:(CSBannerView *)csBannerView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showBannerViewTimeout) object:nil];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}

// 移除Banner广告
- (void)csBannerViewDidDismissScreen:(CSBannerView *)csBannerView
{
}


#pragma mark - CSInterstitialDelegate

// 插屏广告发出请求
- (void)csInterstitialRequestAD:(CSInterstitial *)csInterstitial
{
    
}

// 插屏广告加载完成
- (void)csInterstitialDidLoadAd:(CSInterstitial *)csInterstitial
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapterInterstitialLoadSuccess:self];
}

// 插屏广告加载错误
- (void)csInterstitial:(CSInterstitial *)csInterstitial
loadAdFailureWithError:(CSError *)csError
{
    _interstitialIsLoading = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadInterstitialTimeout) object:nil];
    [self.interstitialDelegate yjbAdapter:self interstitialLoadFailure:csError];
}

// 插屏广告打开完成
- (void)csInterstitialDidPresentScreen:(CSInterstitial *)csInterstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialShowSuccess:self];
}

// 倒计时结束
- (void)csInterstitialCountDownFinished:(CSInterstitial *)csInterstitial
{
    
}

// 插屏广告将要关闭
- (void)csInterstitialWillDismissScreen:(CSInterstitial *)csInterstitial
{
    
}

// 插屏广告关闭完成
- (void)csInterstitialDidDismissScreen:(CSInterstitial *)csInterstitial
{
    [self.interstitialDelegate yjbAdapterInterstitialCloseFinished:self];
}


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.csBannerView.delegate = nil;
    [self.csBannerView removeFromSuperview];
    self.csBannerView = nil;
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
