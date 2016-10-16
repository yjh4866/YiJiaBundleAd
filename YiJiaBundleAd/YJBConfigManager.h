//
//  YJBConfigManager.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/21.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJBAdapter.h"

@interface YJBConfigManager : NSObject

// 给Banner分配广告平台
- (YJBAdPlatform)reassignPlatformForBannerAndExclude:(YJBAdPlatform)exclude;

// 给插屏广告分配广告平台
- (YJBAdPlatform)reassignPlatformForInterstitialAndExclude:(YJBAdPlatform)exclude;

@end
