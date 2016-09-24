//
//  YJBAdapter.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(unsigned int, YJBAdPlatform) {
    YJBAdPlatform_Total,
    YJBAdPlatform_None,
    YJBAdPlatform_Admob,
    YJBAdPlatform_BaiDu,
    YJBAdPlatform_Chance,
    YJBAdPlatform_GDT,
    YJBAdPlatform_Count,
};


@protocol YJBAdapterBannerProtocol;
@protocol YJBAdapterInterstitialProtocol;

@interface YJBAdapter : NSObject

// 当前广告平台类型
@property (nonatomic, readonly) YJBAdPlatform platformType;

// 用于回调广告请求与展现
@property (nonatomic, weak) id <YJBAdapterBannerProtocol> bannerDelegate;
@property (nonatomic, weak) id <YJBAdapterInterstitialProtocol> interstitialDelegate;

+ (instancetype)sharedInstance;

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam;

// 显示Banner
- (BOOL)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime;

// 移除Banner
- (void)removeBanner;

// 获取顶层VC
- (UIViewController *)topVC;

@end


@protocol YJBAdapterBannerProtocol <NSObject>

// 展现Banner成功
- (void)yjbAdapterBannerShowSuccess:(YJBAdapter *)yjbAdapter;

// 展现Banner失败
- (void)yjbAdapter:(YJBAdapter *)yjbAdapter bannerShowFailure:(NSString *)errorMsg;

// Banner被点击
- (void)yjbAdapterBannerClicked:(YJBAdapter *)yjbAdapter;

@end

@protocol CSBAdapterInterstitialProtocol <NSObject>

// 插屏广告加载成功
- (void)yjbAdapterInterstitialLoadSuccess:(YJBAdapter *)yjbAdapter;

// 插屏广告加载失败
- (void)yjbAdapter:(YJBAdapter *)yjbAdapter interstitialLoadFailure:(NSString *)errorMsg;

// 插屏广告展现成功
- (void)yjbAdapterInterstitialShowSuccess:(YJBAdapter *)yjbAdapter;

// 插屏广告被点击
- (void)yjbAdapterInterstitialClicked:(YJBAdapter *)yjbAdapter;

// 插屏广告关闭完成
- (void)yjbAdapterInterstitialDidDismiss:(YJBAdapter *)yjbAdapter;

@end
