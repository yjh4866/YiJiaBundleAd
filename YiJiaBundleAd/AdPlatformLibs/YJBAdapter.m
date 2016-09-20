//
//  YJBAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdapter.h"

@implementation YJBAdapter

+ (instancetype)sharedInstance
{
    static YJBAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBAdapter alloc] init];
    });
    return sharedInstance;
}

// Banner是否可用
- (BOOL)bannerEnabled
{
    return NO;
}
// Interstitial是否可用
- (BOOL)interstitialEnabled
{
    return NO;
}

@end
