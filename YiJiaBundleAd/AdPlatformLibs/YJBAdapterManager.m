//
//  YJBAdapterManager.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBAdapterManager.h"
#import "YJBChanceAdapter.h"
#import "YJBAdmobAdapter.h"
#import "YJBBaiDuAdapter.h"

@interface YJBAdapterManager ()
@property (nonatomic, strong) NSDictionary *dicPlatformTypeKey;
@property (nonatomic, strong) NSDictionary *dicPlatformKeyType;
@property (nonatomic, strong) NSDictionary *dicPlatformTypeName;
@end

@implementation YJBAdapterManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        // 平台类型与平台关键字对应表
        self.dicPlatformTypeKey = @{@(YJBAdPlatform_None): @"none",
                                    @(YJBAdPlatform_Chance): @"chance",
                                    @(YJBAdPlatform_Admob): @"admob",
                                    @(YJBAdPlatform_BaiDu): @"baidu"};
        // 平台关键字与平台类型对应表
        NSMutableDictionary *mdicPlatformNameType = [NSMutableDictionary dictionary];
        NSArray *arrPlatformType = [self.dicPlatformTypeKey allKeys];
        for (NSNumber *NSPlatformType in arrPlatformType) {
            NSString *platformName = self.dicPlatformTypeKey[NSPlatformType];
            [mdicPlatformNameType setObject:NSPlatformType forKey:platformName];
        }
        self.dicPlatformKeyType = mdicPlatformNameType;
        // 平台类型与平台名称对应表
        self.dicPlatformTypeName = @{@(YJBAdPlatform_None): @"无广告",
                                     @(YJBAdPlatform_Chance): @"畅思",
                                     @(YJBAdPlatform_BaiDu): @"百度",
                                     @(YJBAdPlatform_Admob): @"Admob"};
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
        case YJBAdPlatform_Chance:
            adapter = [YJBChanceAdapter sharedInstance];
            break;
        case YJBAdPlatform_BaiDu:
            adapter = [YJBBaiDuAdapter sharedInstance];
            break;
        case YJBAdPlatform_Admob:
            adapter = [YJBAdmobAdapter sharedInstance];
            break;
        default:
            break;
    }
    return adapter;
}

// 根据广告平台关键字查询广告平台类型
- (YJBAdPlatform)platformTypeOf:(NSString *)platformKey
{
    if (![platformKey isKindOfClass:NSString.class]) {
        return YJBAdPlatform_None;
    }
    return (YJBAdPlatform)[self.dicPlatformKeyType[platformKey] unsignedIntValue];
}

// 根据广告平台类型查询广告平台关键字
- (NSString *)platformKeyOf:(YJBAdPlatform)platformType
{
    return self.dicPlatformTypeKey[@(platformType)];
}

// 根据广告平台类型查询广告平台名称
- (NSString *)platformNameOf:(YJBAdPlatform)platformType
{
    return self.dicPlatformTypeName[@(platformType)];
}

@end
