//
//  YJBBaiDuAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBBaiDuAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdCommonConfig.h>

@implementation YJBBaiDuAdapter

+ (void)load
{
    NSLog(@"当前百度广告SDK版本：%@", SDK_VERSION_IN_MSSP);
}

+ (instancetype)sharedInstance
{
    static YJBBaiDuAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBBaiDuAdapter alloc] init];
    });
    return sharedInstance;
}

@end
