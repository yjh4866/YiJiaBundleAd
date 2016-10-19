//
//  YJBInterstitialManager.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBInterstitialManager.h"
#import "YJBConfigData.h"
#import "YJBConfigManager.h"
#import "YJBAdapterManager.h"


@interface YJBInterstitialManager () <YJBAdapterInterstitialProtocol>
@property (nonatomic, assign) BOOL loading;
@property (nonatomic, assign) BOOL loadSuccess;
@property (nonatomic, assign) BOOL needShow;

@property (nonatomic, strong) YJBConfigManager *configManager;
@property (nonatomic, strong) YJBAdapter *currentAdapter;
@end

@implementation YJBInterstitialManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.loading = NO;
        self.loadSuccess = NO;
        self.configManager = [[YJBConfigManager alloc] init];
    }
    return self;
}


#pragma mark - Public

// 加载插屏广告
- (void)loadInterstitial
{
    if (self.loading) {
        return;
    }
    
    // 置空以便重新分配
    self.currentAdapter.interstitialDelegate = nil;
    self.currentAdapter = nil;
    // 分配广告平台
    if (![self assignAdPlatformAndLoadInterstitial]) {
        NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"分配广告平台失败"}];
        [self.delegate yjbInterstitialManager:self loadFailure:error];
    }
}

// 显示插屏广告
- (void)showInterstitial
{
    self.needShow = YES;
    if (self.loading) {
        return;
    }
    
    // 未分配广告平台，或已经分配的广告平台广告未准备好，则重新加载插屏广告
    if (nil == self.currentAdapter || !self.currentAdapter.interstitialIsReady) {
        [self loadInterstitial];
    }
    else {
        self.currentAdapter.interstitialDelegate = self;
        [self.currentAdapter showInterstitial];
    }
}

// 取消显示插屏广告
- (void)cancelInterstitial
{
    self.needShow = NO;
}


#pragma mark - YJBAdapterInterstitialProtocol

// 插屏广告加载成功
- (void)yjbAdapterInterstitialLoadSuccess:(YJBAdapter *)yjbAdapter
{
    if (self.needShow) {
        self.currentAdapter.interstitialDelegate = self;
        [self.currentAdapter showInterstitial];
    }
}

// 插屏广告加载失败
- (void)yjbAdapter:(YJBAdapter *)yjbAdapter interstitialLoadFailure:(NSError *)error
{
    // 分配广告平台
    if (![self assignAdPlatformAndLoadInterstitial]) {
        NSError *error = [NSError errorWithDomain:@"YiJiaBundle" code:0 userInfo:@{NSLocalizedDescriptionKey: @"分配广告平台失败"}];
        [self.delegate yjbInterstitialManager:self loadFailure:error];
    }
}

// 插屏广告展现成功
- (void)yjbAdapterInterstitialShowSuccess:(YJBAdapter *)yjbAdapter
{
    [self.delegate yjbInterstitialManagerShowSuccess:self];
}

// 插屏广告关闭完成
- (void)yjbAdapterInterstitialCloseFinished:(YJBAdapter *)yjbAdapter
{
    [self.delegate yjbInterstitialManagerCloseFinished:self];
    self.currentAdapter.interstitialDelegate = nil;
    self.currentAdapter = nil;
}

// 插屏广告被点击
- (void)yjbAdapterInterstitialClicked:(YJBAdapter *)yjbAdapter
{
    [self.delegate yjbInterstitialManagerClicked:self];
}


#pragma mark - Private

- (BOOL)assignAdPlatformAndLoadInterstitial
{
    // 重新分配Banner广告平台
    YJBAdPlatform platformType = [self.configManager reassignPlatformForInterstitialAndExclude:self.currentAdapter.platformType];
    self.currentAdapter = nil;
    if (platformType > YJBAdPlatform_None && platformType < YJBAdPlatform_Count) {
        // 获取相应的Adapter
        self.currentAdapter = [YJBAdapterManager getAdapterOfADPlatform:platformType];
        self.currentAdapter.interstitialDelegate = self;
        // 设置广告参数
        [[YJBConfigData sharedInstance] fillAdParam:self.currentAdapter];
        // 加载插屏广告失败则重新分配广告平台
        self.currentAdapter.interstitialDelegate = self;
        if (![self.currentAdapter loadInterstitial]) {
            return [self assignAdPlatformAndLoadInterstitial];
        }
    }
    // 分配到不显示广告，按展现成功算，以便继续后续广告请求
    else if (YJBAdPlatform_None == platformType) {
        [self.delegate yjbInterstitialManagerShowSuccess:self];
    }
    else {
        return NO;
    }
    return YES;
}

@end
