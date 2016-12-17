//
//  YJBAdapterManager.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdapterManager.h"
#import "YJBAdmobAdapter.h"
#import "YJBChanceAdapter.h"

@interface YJBAdapterManager ()
@property (nonatomic, strong) NSDictionary *dicPlatformTypeName;
@end

@implementation YJBAdapterManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 平台类型与平台名称对应表
        self.dicPlatformTypeName = @{@(YJBAdPlatform_Admob): @"Admob",
                                     @(YJBAdPlatform_Chance): @"畅思"};
    }
    return self;
}


#pragma mark - Public

+ (instancetype)sharedInstance
{
    static YJBAdapterManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBAdapterManager alloc] init];
    });
    return sharedInstance;
}

// 根据广告平台类型获取相应的适配器
+ (YJBAdapter *)getAdapterOfADPlatform:(YJBAdPlatform)platformType
{
    YJBAdapter *adapter = nil;
    switch (platformType) {
        case YJBAdPlatform_Admob:
            adapter = [YJBAdmobAdapter sharedInstance];
            break;
        case YJBAdPlatform_Chance:
            adapter = [YJBChanceAdapter sharedInstance];
            break;
        default:
            break;
    }
    return adapter;
}

// 根据广告平台类型查询广告平台名称
- (NSString *)platformNameOf:(YJBAdPlatform)platformType
{
    return self.dicPlatformTypeName[@(platformType)];
}

@end
