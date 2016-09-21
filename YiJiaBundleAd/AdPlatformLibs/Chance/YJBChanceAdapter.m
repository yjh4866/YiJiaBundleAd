//
//  YJBChanceAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBChanceAdapter.h"
#import "ChanceAd.h"

@implementation YJBChanceAdapter

+ (void)load
{
    NSLog(@"当前畅思广告SDK版本：%@", [ChanceAd sdkVersion]);
}

+ (instancetype)sharedInstance
{
    static YJBChanceAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBChanceAdapter alloc] init];
    });
    return sharedInstance;
}

@end
