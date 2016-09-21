//
//  YJBConfigData.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJBAdapter.h"

@interface YJBConfigData : NSObject

@property (nonatomic, readonly) NSUInteger requestInterval;
@property (nonatomic, readonly) NSUInteger displayTime;

@property (nonatomic, readonly) BOOL configIsRequesting;

+ (instancetype)sharedInstance;

// 请求各平台配置
- (void)requestPlatformConfig;

// 填充广告参数
- (void)fillAdParam:(YJBAdapter *)yjbAdapter;

// 设置Banner的权重参数
- (void)fillBannerWeight:(unsigned int[])bannerWeights;

// 设置插屏的权重参数
- (void)fillInterstitialWeight:(unsigned int[])interstitialWeights;

@end
