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

@interface YJBBaiDuAdapter () <BaiduMobAdViewDelegate, BaiduMobAdInterstitialDelegate>
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *placeIdB;
@property (nonatomic, copy) NSString *placeIdI;
@property (nonatomic, strong) BaiduMobAdView *bdBannerView;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
        [self performSelector:@selector(showBannerViewTimeout) withObject:nil afterDelay:10];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.bdBannerView.delegate = nil;
    [self.bdBannerView removeFromSuperview];
    self.bdBannerView = nil;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:errMsg];
}

/**
 *  本次广告展示成功时的回调
 */
- (void)didAdImpressed
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.bdBannerView.delegate = nil;
    [self.bdBannerView removeFromSuperview];
    self.bdBannerView = nil;
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:@"超时"];
}

@end
