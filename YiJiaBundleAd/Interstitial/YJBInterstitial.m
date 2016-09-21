//
//  YJBInterstitial.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBInterstitial.h"

@implementation YJBInterstitial


#pragma mark - Public

+ (instancetype)sharedInstance
{
    static YJBInterstitial *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBInterstitial alloc] init];
    });
    return sharedInstance;
}

@end
