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

@interface YJBGDTAdapter () <GDTMobBannerViewDelegate, GDTMobInterstitialDelegate>
@property (nonatomic, copy) NSString *appKey;
@property (nonatomic, copy) NSString *placeIdB;
@property (nonatomic, copy) NSString *placeIdI;
@property (nonatomic, strong) GDTMobBannerView *gdtBannerView;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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
        [self performSelector:@selector(showBannerViewTimeout) withObject:nil afterDelay:10];
        return YES;
    }
    return NO;
}

// 移除Banner
- (void)removeBanner
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    self.gdtBannerView.delegate = nil;
    [self.gdtBannerView removeFromSuperview];
    self.gdtBannerView = nil;
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:error.localizedDescription];
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
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
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


#pragma mark - Private

- (void)showBannerViewTimeout
{
    self.gdtBannerView.delegate = nil;
    [self.gdtBannerView removeFromSuperview];
    self.gdtBannerView = nil;
    [self.bannerDelegate yjbAdapter:self bannerShowFailure:@"超时"];
}

@end
