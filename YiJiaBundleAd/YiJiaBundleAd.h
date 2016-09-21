//
//  YiJiaBundleAd.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJBBannerView.h"
#import "YJBInterstitial.h"


#define FilePath_AllConfig  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"YiJiaBundleAd_allconfig.plist"]


@interface YiJiaBundleAd : NSObject

/**
 *  为Admob广告设置测试设备
 *
 *  @param testDevices 测试设备id列表
 */
+ (void)setTestDevicesForAdmob:(NSArray<NSString *> *)testDevices;

@end
