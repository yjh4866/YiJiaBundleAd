//
//  YJBAdmobAdapter.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdmobAdapter.h"

@implementation YJBAdmobAdapter

+ (instancetype)sharedInstance
{
    static YJBAdmobAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBAdmobAdapter alloc] init];
    });
    return sharedInstance;
}

@end
