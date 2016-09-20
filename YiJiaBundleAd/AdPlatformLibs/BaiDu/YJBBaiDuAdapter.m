//
//  YJBBaiDuAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBBaiDuAdapter.h"

@implementation YJBBaiDuAdapter

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
