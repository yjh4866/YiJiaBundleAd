//
//  YJBConfigData.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBConfigData.h"
#import <UIKit/UIKit.h>
#import "NBLHTTPManager.h"
#import "YJBAdapterManager.h"


#define FilePath_AllConfig  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"YiJiaBundleAd_allconfig.plist"]

@interface YJBConfigData () {
    // 权重二维数组
    unsigned int _bannerWeights[YJBAdPlatform_Count];
    unsigned int _popupWeights[YJBAdPlatform_Count];
}
@property (nonatomic, strong) NSDictionary *dicBannerConfig;
@property (nonatomic, strong) NSDictionary *dicPopupConfig;

@property (nonatomic, assign) NSTimeInterval timeConfig;
@end

@implementation YJBConfigData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _configIsRequesting = NO;
        // app激活通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notifAppDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Notification

- (void)notifAppDidBecomeActive:(NSNotification *)notif
{
    // 1小时内不更新
    if (!self.configIsRequesting &&
        [NSDate date].timeIntervalSince1970 - self.timeConfig > 60*60) {
        [self requestPlatformConfig];
    }
}


#pragma mark - Public

+ (instancetype)sharedInstance
{
    static YJBConfigData *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[YJBConfigData alloc] init];
    });
    return sharedInstance;
}

// 请求各平台配置
- (void)requestPlatformConfig
{
    // 读缓存配置
    NSDictionary *dicAllConfig = [NSDictionary dictionaryWithContentsOfFile:FilePath_AllConfig];
    // 缓存格式正确则解析
    if (dicAllConfig && [dicAllConfig isKindOfClass:NSDictionary.class] &&
        [self parseFromAllConfig:dicAllConfig]) {
    }

    _configIsRequesting = YES;
    // 从服务器读权重配置数据
    NSString *urlConfig = [NSString stringWithFormat:@"http://www.1jiagame.com/app/%@/BundleAdConfig.json", [NSBundle mainBundle].bundleIdentifier];
    [[NBLHTTPManager sharedManager] requestObject:NBLResponseObjectType_JSON fromURL:urlConfig withParam:nil andResult:^(NSHTTPURLResponse *httpResponse, id responseObject, NSError *error, NSDictionary *dicParam) {
        _configIsRequesting = NO;
        NSDictionary *dicAllConfig = responseObject;
        // 配置文件是字典
        if ([dicAllConfig isKindOfClass:NSDictionary.self]) {
            // 从所有配置中解析
            if ([self parseFromAllConfig:dicAllConfig]) {
                self.timeConfig = [NSDate date].timeIntervalSince1970;
                // 解析成功，保存配置
                [dicAllConfig writeToFile:FilePath_AllConfig atomically:YES];
            }
        }
        else {
            NSLog(@"请求url：%@", urlConfig);
            NSLog(@"错误数据：%@", error);
        }
    }];
}

// 查看指定平台的Banner参数是否有配置
- (BOOL)bannerParamIsExistWithPlatformType:(YJBAdPlatform)platformType
{
    NSString *platformKey = [[YJBAdapterManager sharedInstance] platformKeyOf:platformType];
    return [self bannerParamIsExistWithPlatformKey:platformKey];
}
// 查看指定平台的Banner参数是否有配置
- (BOOL)bannerParamIsExistWithPlatformKey:(NSString *)platformKey
{
    NSDictionary *dicPlatformConfig = self.dicBannerConfig[platformKey];
    if ([dicPlatformConfig respondsToSelector:@selector(count)]
        && dicPlatformConfig.count > 0) {
        return YES;
    }
    return NO;
}

// 查看指定平台的插屏参数是否有配置
- (BOOL)interstitialParamIsExistWithPlatformType:(YJBAdPlatform)platformType
{
    NSString *platformKey = [[YJBAdapterManager sharedInstance] platformKeyOf:platformType];
    return [self interstitialParamIsExistWithPlatformKey:platformKey];
}
// 查看指定平台的插屏参数是否有配置
- (BOOL)interstitialParamIsExistWithPlatformKey:(NSString *)platformKey
{
    NSDictionary *dicPlatformConfig = self.dicPopupConfig[platformKey];
    if ([dicPlatformConfig respondsToSelector:@selector(count)] &&
        dicPlatformConfig.count > 0) {
        return YES;
    }
    return NO;
}


#pragma mark - Private

- (BOOL)parseFromAllConfig:(NSDictionary *)dicAllConfig
{
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    if (dicAllConfig.count == 0 || appVersion.length == 0) {
        return NO;
    }
    // 根据当前app版本号取对应的配置
    NSDictionary *dicConfig = dicAllConfig[appVersion];
    // 没有给当前版本号配置，找到比当前版本号小的最大版本号的配置
    if (![dicConfig isKindOfClass:NSDictionary.class]) {
        // 两个版本号的比较
        NSComparator cmptr = ^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString *strVerKey1 = [NSString stringWithFormat:@"%@", obj1];
            NSString *strVerKey2 = [NSString stringWithFormat:@"%@", obj2];
            NSArray<NSString *> *arrVerKey1 = [strVerKey1 componentsSeparatedByString:@"."];
            NSArray<NSString *> *arrVerKey2 = [strVerKey2 componentsSeparatedByString:@"."];
            // 先比较主版本号
            if (arrVerKey1.count > 0 && arrVerKey2.count > 0) {
                int num1 = [arrVerKey1[0] intValue];
                int num2 = [arrVerKey2[0] intValue];
                if (num1 > num2) {
                    return NSOrderedDescending;
                }
                else if (num1 < num2) {
                    return NSOrderedAscending;
                }
            }
            // 再比较子版本号
            if (arrVerKey1.count > 1 && arrVerKey2.count > 1) {
                int num1 = [arrVerKey1[1] intValue];
                int num2 = [arrVerKey2[1] intValue];
                if (num1 > num2) {
                    return NSOrderedDescending;
                }
                else if (num1 < num2) {
                    return NSOrderedAscending;
                }
            }
            else if (arrVerKey1.count != arrVerKey2.count) {
                return arrVerKey1.count>arrVerKey2.count?NSOrderedDescending:NSOrderedAscending;
            }
            // 接着比较修正版本号
            if (arrVerKey1.count > 2 && arrVerKey2.count > 2) {
                int num1 = [arrVerKey1[2] intValue];
                int num2 = [arrVerKey2[2] intValue];
                if (num1 > num2) {
                    return NSOrderedDescending;
                }
                else if (num1 < num2) {
                    return NSOrderedAscending;
                }
            }
            else if (arrVerKey1.count != arrVerKey2.count) {
                return arrVerKey1.count>arrVerKey2.count?NSOrderedDescending:NSOrderedAscending;
            }
            // 最后比较编译版本号
            if (arrVerKey1.count > 3 && arrVerKey2.count > 3) {
                int num1 = [arrVerKey1[3] intValue];
                int num2 = [arrVerKey2[3] intValue];
                if (num1 > num2) {
                    return NSOrderedDescending;
                }
                else if (num1 < num2) {
                    return NSOrderedAscending;
                }
            }
            else if (arrVerKey1.count != arrVerKey2.count) {
                return arrVerKey1.count>arrVerKey2.count?NSOrderedDescending:NSOrderedAscending;
            }
            return NSOrderedSame;
        };
        // 遍历找到比当前版本号小的最大版本号的配置
        NSString *strKeyConfig = nil;
        for (NSObject *objKey in dicAllConfig.allKeys) {
            NSString *strKey = [NSString stringWithFormat:@"%@", objKey];
            // 比当前版本号小
            if (cmptr(strKey, appVersion) != NSOrderedDescending) {
                // 比已经找到的版本号大
                if (nil == strKeyConfig || cmptr(strKey, strKeyConfig) == NSOrderedDescending) {
                    strKeyConfig = strKey;
                }
            }
        }
        // 提取找到的版本号对应的配置
        if (strKeyConfig.length > 0) {
            dicConfig = dicAllConfig[strKeyConfig];
        }
    }
    // 开始解析配置
    if (dicConfig && [dicConfig isKindOfClass:NSDictionary.self]) {
        // Banner广告请求间隔
        _requestInterval = [NSString stringWithFormat:@"%@", dicConfig[@"ri"]].intValue;
        if (_requestInterval < 5) {
            _requestInterval = 5;
        }
        // Banner广告展现时长
        _displayTime = [NSString stringWithFormat:@"%@", dicConfig[@"st"]].intValue;
        if (_displayTime < 5) {
            _displayTime = 5;
        }
        // 必须先解析平台参数，后解析权重，因为有配置才需要计算权重
        return [self parsePlatformParam:dicConfig[@"param"]] &&
        [self parseWeightConfig:dicConfig[@"weight"]];
    }
    return NO;
}

// 解析平台广告参数配置
- (BOOL)parsePlatformParam:(NSDictionary *)dicPlatformParam
{
    if (dicPlatformParam && ![dicPlatformParam isKindOfClass:NSDictionary.class])
        return NO;
    // 配置参数检查
    NSDictionary *dicBannerConfig = dicPlatformParam[@"banner"];
    NSDictionary *dicPopupConfig = dicPlatformParam[@"popup"];
    if ((dicBannerConfig && ![dicBannerConfig isKindOfClass:NSDictionary.class]) ||
        (dicPopupConfig && ![dicPopupConfig isKindOfClass:NSDictionary.class])) {
        return NO;
    }
    // 未配置
    if (dicBannerConfig.count < 1 || dicPopupConfig.count < 1) {
        return NO;
    }
    self.dicBannerConfig = dicBannerConfig;
    self.dicPopupConfig = dicPopupConfig;
    return YES;
}

// 解析权重配置
- (BOOL)parseWeightConfig:(NSDictionary *)dicWeightConfig
{
    if (![dicWeightConfig isKindOfClass:NSDictionary.class])
        return NO;
    NSDictionary *dicBannerConfig = dicWeightConfig[@"banner"];
    if (dicBannerConfig && ![dicBannerConfig isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    NSDictionary *dicPopupConfig = dicWeightConfig[@"popup"];
    if (dicPopupConfig && ![dicPopupConfig isKindOfClass:NSDictionary.class]) {
        return NO;
    }
    // 获取Banner广告配置比例，计算权重二维表
    [self parseBannerWeightConfig:dicBannerConfig];
    // 获取插屏广告配置比例，计算权重二维表
    [self parseInterstitialWeightConfig:dicPopupConfig];
    return YES;
}
// 获取Banner配置比例，计算权重二维表
- (void)parseBannerWeightConfig:(NSDictionary *)dicBannerConfig
{
    memset(_bannerWeights, 0, YJBAdPlatform_Count*sizeof(unsigned int));
    for (NSString *platformKey in dicBannerConfig.allKeys) {
        if (![platformKey isKindOfClass:NSString.class]) {
            continue;
        }
        // 该平台未配置
        if (![self bannerParamIsExistWithPlatformKey:platformKey]) {
            continue;
        }
        // 根据广告平台名称获取广告平台标识
        YJBAdPlatform platformType = [[YJBAdapterManager sharedInstance] platformTypeOf:platformKey];
        // 不认识该广告平台，或该广告平台不存在则不计算权重分配
        YJBAdapter *csbAdapter = [YJBAdapterManager getAdapterOfADPlatform:platformType];
        if (nil == csbAdapter || ![csbAdapter bannerEnabled]) {
            continue;
        }
        // 获取广告平台的小时数配置
        _bannerWeights[platformType] = [NSString stringWithFormat:@"%@", dicBannerConfig[platformKey]].intValue;
    }
    // 求权重之和
    _bannerWeights[0] = 0;
    for (int i = 1; i < YJBAdPlatform_Count; i++) {
        _bannerWeights[0] += _bannerWeights[i];
    }
}
// 获取插屏广告配置比例，计算权重二维表
- (void)parseInterstitialWeightConfig:(NSDictionary *)dicPopupConfig
{
    memset(_popupWeights, 0, YJBAdPlatform_Count*sizeof(unsigned int));
    for (NSString *platformKey in dicPopupConfig.allKeys) {
        if (![platformKey isKindOfClass:NSString.class]) {
            continue;
        }
        // 该平台未配置
        if (![self interstitialParamIsExistWithPlatformKey:platformKey]) {
            continue;
        }
        // 根据广告平台名称获取广告平台标识
        YJBAdPlatform platformType = [[YJBAdapterManager sharedInstance] platformTypeOf:platformKey];
        // 不认识该广告平台，或该广告平台不存在则不计算权重分配
        YJBAdapter *csbAdapter = [YJBAdapterManager getAdapterOfADPlatform:platformType];
        if (nil == csbAdapter || ![csbAdapter bannerEnabled]) {
            continue;
        }
        // 获取广告平台的小时数配置
        _popupWeights[platformType] = [NSString stringWithFormat:@"%@", dicPopupConfig[platformKey]].intValue;
    }
    // 求权重之和
    _popupWeights[0] = 0;
    for (int i = 1; i < YJBAdPlatform_Count; i++) {
        _popupWeights[0] += _popupWeights[i];
    }
}

@end
