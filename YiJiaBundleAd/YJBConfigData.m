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
#import "YiJiaBundleAd.h"
#import "YJBAdapterManager.h"


@interface YJBConfigData () {
    // 权重二维数组
    unsigned int _bannerWeights[YJBAdPlatform_Count];
    unsigned int _popupWeights[YJBAdPlatform_Count];
}
@property (nonatomic, strong) NSDictionary *dicAdmobConfig;
@property (nonatomic, strong) NSDictionary *dicBaiDuConfig;
@property (nonatomic, strong) NSDictionary *dicChanceConfig;

@property (nonatomic, assign) NSTimeInterval timeConfig;
@end

@implementation YJBConfigData

+ (void)load
{
    [[YJBConfigData sharedInstance] notifAppDidBecomeActive:nil];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _configIsRequesting = NO;
        _requestInterval = 15;
        _displayTime = 15;
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
    NSString *urlConfig = [NSString stringWithFormat:@"http://www.1jiagame.com/app/%@/BundleAdConfig.php", [NSBundle mainBundle].bundleIdentifier];
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

// 填充广告参数
- (void)fillAdParam:(YJBAdapter *)yjbAdapter
{
    switch (yjbAdapter.platformType) {
        case YJBAdPlatform_Admob:
            [yjbAdapter setAdParams:self.dicAdmobConfig];
            break;
        case YJBAdPlatform_BaiDu:
            [yjbAdapter setAdParams:self.dicBaiDuConfig];
            break;
        case YJBAdPlatform_Chance:
            [yjbAdapter setAdParams:self.dicChanceConfig];
            break;
        default:
            break;
    }
}

// 设置Banner的权重参数
- (void)fillBannerWeight:(unsigned int[])bannerWeights
{
    memcpy(bannerWeights, _bannerWeights, sizeof(_bannerWeights));
}

// 设置插屏的权重参数
- (void)fillInterstitialWeight:(unsigned int[])interstitialWeights
{
    memcpy(interstitialWeights, _popupWeights, sizeof(_popupWeights));
}


#pragma mark - Private

- (BOOL)parseFromAllConfig:(NSDictionary *)dicAllConfig
{
    // 获取当前版本的配置
    NSDictionary *dicConfig = [self getCurrentConfigFromAllConfig:dicAllConfig];
    // 开始解析配置
    if (dicConfig && [dicConfig isKindOfClass:NSDictionary.self]) {
        // 根据当前设备类型提取相应的配置
        UIUserInterfaceIdiom deviceType = UI_USER_INTERFACE_IDIOM();
        if (UIUserInterfaceIdiomPhone == deviceType) {
            dicConfig = dicConfig[@"iPhone"];
        }
        else if (UIUserInterfaceIdiomPhone == deviceType) {
            dicConfig = dicConfig[@"iPad"];
        }
        else {
            return NO;
        }
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
            
            // 清空权重表
            memset(_bannerWeights, 0, YJBAdPlatform_Count*sizeof(unsigned int));
            memset(_popupWeights, 0, YJBAdPlatform_Count*sizeof(unsigned int));
            // 解析Admob平台参数
            NSDictionary *dic = dicConfig[@"Admob"];
            if ([dic isKindOfClass:NSDictionary.class]) {
                self.dicAdmobConfig = dic;
                // 权重处理
                _bannerWeights[YJBAdPlatform_Admob] = [NSString stringWithFormat:@"%@", dic[@"bw"]].intValue;
                _popupWeights[YJBAdPlatform_Admob] = [NSString stringWithFormat:@"%@", dic[@"iw"]].intValue;
            }
            // 解析百度平台参数
            dic = dicConfig[@"BaiDu"];
            if ([dic isKindOfClass:NSDictionary.class]) {
                self.dicBaiDuConfig = dic;
                // 权重处理
                _bannerWeights[YJBAdPlatform_BaiDu] = [NSString stringWithFormat:@"%@", dic[@"bw"]].intValue;
                _popupWeights[YJBAdPlatform_BaiDu] = [NSString stringWithFormat:@"%@", dic[@"iw"]].intValue;
            }
            // 解析畅思平台参数
            dic = dicConfig[@"Chance"];
            if ([dic isKindOfClass:NSDictionary.class]) {
                self.dicChanceConfig = dic;
                // 权重处理
                _bannerWeights[YJBAdPlatform_Chance] = [NSString stringWithFormat:@"%@", dic[@"bw"]].intValue;
                _popupWeights[YJBAdPlatform_Chance] = [NSString stringWithFormat:@"%@", dic[@"iw"]].intValue;
            }
            // 权重求和
            _bannerWeights[YJBAdPlatform_Total] = 0;
            for (int i = 1; i < YJBAdPlatform_Count; i++) {
                _bannerWeights[YJBAdPlatform_Total] += _bannerWeights[i];
            }
            _popupWeights[YJBAdPlatform_Total] = 0;
            for (int i = 1; i < YJBAdPlatform_Count; i++) {
                _popupWeights[YJBAdPlatform_Total] += _popupWeights[i];
            }
            return YES;
        }
    }
    return NO;
}

// 获取当前版本的配置
- (NSDictionary *)getCurrentConfigFromAllConfig:(NSDictionary *)dicAllConfig
{
    NSString *appVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    if (dicAllConfig.count == 0 || appVersion.length == 0) {
        return nil;
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
    return dicConfig;
}

@end
