//
//  YJBAdapter.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(unsigned int, YJBAdPlatform) {
    YJBAdPlatform_Total,
    YJBAdPlatform_None,
    YJBAdPlatform_Admob,
    YJBAdPlatform_Chance,
    YJBAdPlatform_BaiDu,
    YJBAdPlatform_Count,
};

@interface YJBAdapter : NSObject

+ (instancetype)sharedInstance;

// Banner是否可用
- (BOOL)bannerEnabled;
// Interstitial是否可用
- (BOOL)interstitialEnabled;

@end
