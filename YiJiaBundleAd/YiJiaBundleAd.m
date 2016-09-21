//
//  YiJiaBundleAd.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YiJiaBundleAd.h"

#import "YJBAdmobAdapter.h"

@implementation YiJiaBundleAd

/**
 *  为Admob广告设置测试设备
 *
 *  @param testDevices 测试设备id列表
 */
+ (void)setTestDevicesForAdmob:(NSArray<NSString *> *)testDevices
{
    [YJBAdmobAdapter sharedInstance].testDevices = testDevices;
}

@end
