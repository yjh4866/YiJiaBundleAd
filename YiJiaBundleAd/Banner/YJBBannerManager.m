//
//  YJBBannerManager.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBBannerManager.h"
#import "YJBConfigData.h"
#import "YJBConfigManager.h"
#import "YJBAdapterManager.h"


@interface YJBBannerManager () <YJBAdapterBannerProtocol>
@property (nonatomic, strong) YJBConfigManager *configManager;
@property (nonatomic, strong) YJBAdapter *currentAdapter;

@property (nonatomic, weak) UIView *bannerSuperView;
@property (nonatomic, assign) NSTimeInterval displayTime;
@end

@implementation YJBBannerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.configManager = [[YJBConfigManager alloc] init];
    }
    return self;
}


#pragma mark - Public

// 显示Banner
- (void)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime
{
    self.bannerSuperView = bannerSuperView;
    self.displayTime = displayTime;
    // 分配广告平台
    [self.currentAdapter removeBanner];
    self.currentAdapter = nil;
    if (![self reassignAdPlatform]) {
        [self.delegate yjbBannerManager:self showBannerFailure:@"分配失败"];
    }
}

// 移除Banner
- (void)removeBanner
{
    [self.currentAdapter removeBanner];
    self.currentAdapter = nil;
}


#pragma mark - YJBAdapterBannerProtocol

// 展现Banner成功
- (void)yjbAdapterBannerShowSuccess:(YJBAdapter *)yjbAdapter
{
    [self.delegate yjbBannerManagerShowSuccess:self];
}

// 展现Banner失败
- (void)yjbAdapter:(YJBAdapter *)yjbAdapter bannerShowFailure:(NSString *)errorMsg
{
    if (![self reassignAdPlatform]) {
        [self.delegate yjbBannerManager:self showBannerFailure:@"分配失败"];
    }
}

// Banner被点击
- (void)yjbAdapterBannerClicked:(YJBAdapter *)yjbAdapter
{
    [self.delegate yjbBannerManagerClicked:self];
}


#pragma mark - Private

- (BOOL)reassignAdPlatform
{
    // 重新分配Banner广告平台
    YJBAdPlatform platformType = [self.configManager reassignPlatformForBannerAndExclude:self.currentAdapter.platformType];
    [self.currentAdapter removeBanner];
    self.currentAdapter = nil;
    if (platformType > YJBAdPlatform_None && platformType < YJBAdPlatform_Count) {
        // 获取相应的Adapter
        self.currentAdapter = [YJBAdapterManager getAdapterOfADPlatform:platformType];
        self.currentAdapter.bannerDelegate = self;
        // 设置广告参数
        [[YJBConfigData sharedInstance] fillAdParam:self.currentAdapter];
        // 显示Banner失败则重新分配广告平台
        if (![self.currentAdapter showBannerOn:self.bannerSuperView withDisplayTime:self.displayTime]) {
            return [self reassignAdPlatform];
        }
    }
    // 分配到不显示广告，按展现成功算，以便继续后续广告请求
    else if (YJBAdPlatform_None == platformType) {
        [self.delegate yjbBannerManagerShowSuccess:self];
    }
    else {
        return NO;
    }
    return YES;
}

@end
