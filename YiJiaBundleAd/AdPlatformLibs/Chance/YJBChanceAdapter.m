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

@interface YJBChanceAdapter () <CSBannerViewDelegate, CSInterstitialDelegate>
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
        [self performSelector:@selector(showBannerViewTimeout) withObject:nil afterDelay:10];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.csBannerView.delegate = nil;
    [self.csBannerView removeFromSuperview];
    self.csBannerView = nil;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:csError.localizedDescription];
}
// 将要展示Banner广告
- (void)csBannerViewWillPresentScreen:(CSBannerView *)csBannerView
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapterBannerShowSuccess:self];
}

// 移除Banner广告
- (void)csBannerViewDidDismissScreen:(CSBannerView *)csBannerView
{
}


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.csBannerView.delegate = nil;
    [self.csBannerView removeFromSuperview];
    self.csBannerView = nil;
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:@"超时"];
}

@end
