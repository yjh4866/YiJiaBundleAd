//
//  YJBBannerView.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBBannerView.h"
#import "YJBConfigData.h"
#import "YJBBannerManager.h"


@interface YJBBannerView () <YJBBannerManagerDelegate>

@property (nonatomic, assign) BOOL startLoad;
@property (nonatomic, assign) BOOL bannerRun;

@property (nonatomic, strong) YJBBannerManager *adManager;
@end

@implementation YJBBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.startLoad = NO;
        self.bannerRun = NO;
        self.adManager = [[YJBBannerManager alloc] init];
        self.adManager.delegate = self;
        // 隐藏掉的不再请求新广告
        [self addObserver:self forKeyPath:@"hidden"
                  options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    frame.size = YJBBannerSize;
    super.frame = frame;
}

// 不调用removeFromSuperview也可以释放内存了
- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    // 将当前BannerView添加到某个View上了
    if (self.superview) {
        // 开发者调用过loadAd，则开始加载Banner
        if (self.startLoad) {
            [self loadAd];
        }
    }
    // 当前BannerView的superview不存在，就不再请求新广告了
    else {
        self.bannerRun = NO;
        [self stopRequestBanner];
    }
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"hidden"];
}


#pragma mark - NSKeyValueObserving

- (void)observeValueForKeyPath:(nullable NSString *)keyPath ofObject:(nullable id)object change:(nullable NSDictionary<NSString*, id> *)change context:(nullable void *)context
{
    if ([keyPath isEqualToString:@"hidden"]) {
        if (self.bannerRun) {
            if (self.hidden) {
                [self stopRequestBanner];
            }
            else {
                [self loadAd];
            }
        }
    }
}


#pragma mark - Public

// 加载广告
- (void)loadAd
{
    self.startLoad = YES;
    // 父视图不存在即未展现，则不加载广告
    if (nil == self.superview) {
        return;
    }
    // 停止之前的网络请求
    [self stopRequestBanner];
    // 发起广告请求
    self.bannerRun = YES;
    [self startRequestBanner];
}


#pragma mark - YJBBannerManagerDelegate

// Banner广告展现成功
- (void)yjbBannerManagerShowSuccess:(YJBBannerManager *)adManager
{
    if ([self.delegate respondsToSelector:@selector(yjbBannerViewShowSuccess)]) {
        [self.delegate yjbBannerViewShowSuccess];
    }
    // 启动两个计时器，停止展现和下次请求
    [self startTwoTimer];
}

// Banner广告展现失败
- (void)yjbBannerManager:(YJBBannerManager *)adManager showBannerFailure:(NSString *)errorMsg
{
    if ([self.delegate respondsToSelector:@selector(yjbBannerViewShowFailure:)]) {
        [self.delegate yjbBannerViewShowFailure:errorMsg];
    }
    // 启动两个计时器，停止展现和下次请求
    [self startTwoTimer];
}

// Banner广告被点击
- (void)yjbBannerManagerClicked:(YJBBannerManager *)adManager
{
    
}


#pragma mark - Private

- (void)startRequestBanner
{
    // 非激活状态不请求广告
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        [self startTwoTimer];
        return;
    }
    [self.adManager showBannerOn:self withDisplayTime:[YJBConfigData sharedInstance].displayTime];
}

// 因打开广告停止广告请求
- (void)stopRequestBanner
{
    // 两个计时器作废
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    // 移除Banner
    [self.adManager removeBanner];
}

// 启动两个计时器
- (void)startTwoTimer
{
    // 非激活状态，1秒后重新调用这个方法
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        __weak typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [weakSelf startTwoTimer];
        });
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // 指定时间后隐藏广告
    [self performSelector:@selector(hideBannerViewForTimer) withObject:nil
               afterDelay:[YJBConfigData sharedInstance].displayTime];
    // 指定时间后再次请求广告
    [self performSelector:@selector(startRequestBanner) withObject:nil
               afterDelay:[YJBConfigData sharedInstance].requestInterval];
}

// 隐藏Banner，由计时器调用
- (void)hideBannerViewForTimer
{
    // 非激活状态不隐藏广告
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        return;
    }
    [self.adManager removeBanner];
    if ([self.delegate respondsToSelector:@selector(yjbBannerViewRemoved)]) {
        [self.delegate yjbBannerViewRemoved];
    }
}

@end
