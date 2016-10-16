//
//  YJBInterstitial.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBInterstitial.h"
#import "YJBInterstitialManager.h"


@interface YJBInterstitial () <YJBInterstitialManagerDelegate>
@property (nonatomic, strong) YJBInterstitialManager *adManager;
@end

@implementation YJBInterstitial

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.adManager = [[YJBInterstitialManager alloc] init];
    }
    return self;
}


#pragma mark - Public

+ (instancetype)sharedInstance
{
    static YJBInterstitial *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBInterstitial alloc] init];
    });
    return sharedInstance;
}

// 加载插屏广告
- (void)loadInterstitial
{
    [self.adManager loadInterstitial];
}

// 显示插屏广告
- (void)showInterstitial
{
    [self.adManager showInterstitial];
}

// 取消显示插屏广告
- (void)cancelInterstitial
{
    [self.adManager cancelInterstitial];
}


#pragma mark - YJBInterstitialManagerDelegate

// 插屏广告加载成功
- (void)yjbInterstitialManagerLoadSuccess:(YJBInterstitialManager *)adManager
{
    if ([self.delegate respondsToSelector:@selector(yjbInterstitialLoadSuccess)]) {
        [self.delegate yjbInterstitialLoadSuccess];
    }
}

// 插屏广告加载失败
- (void)yjbInterstitialManager:(YJBInterstitialManager *)adManager
                   loadFailure:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(yjbInterstitialLoadFailure:)]) {
        [self.delegate yjbInterstitialLoadFailure:error];
    }
}

// 插屏广告展现成功
- (void)yjbInterstitialManagerShowSuccess:(YJBInterstitialManager *)adManager
{
    if ([self.delegate respondsToSelector:@selector(yjbInterstitialShowSuccess)]) {
        [self.delegate yjbInterstitialShowSuccess];
    }
}

// 插屏广告关闭完成
- (void)yjbInterstitialManagerCloseFinished:(YJBInterstitialManager *)adManager
{
    if ([self.delegate respondsToSelector:@selector(yjbInterstitialCloseFinished)]) {
        [self.delegate yjbInterstitialCloseFinished];
    }
}

// 插屏广告被点击
- (void)yjbInterstitialManagerClicked:(YJBInterstitialManager *)adManager
{
    if ([self.delegate respondsToSelector:@selector(yjbInterstitialClicked)]) {
        [self.delegate yjbInterstitialClicked];
    }
}

@end
