//
//  YJBAdmobAdapter.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdapter.h"

@interface YJBAdmobAdapter : YJBAdapter

/// Test ads will be returned for devices with device IDs specified in this array.
@property(nonatomic, copy) NSArray *testDevices;

@end
