//
//  YJBConfigManager.m
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/21.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "YJBConfigManager.h"
#import "YJBConfigData.h"
#import "YJBAdapterManager.h"


@interface YJBConfigManager () {
    // 权重二维数组
    unsigned int _bannerWeights[YJBAdPlatform_Count];
    unsigned int _popupWeights[YJBAdPlatform_Count];
}
@end

@implementation YJBConfigManager

// 给Banner分配广告平台
- (YJBAdPlatform)reassignPlatformForBannerAndExclude:(YJBAdPlatform)exclude
{
    // 权重调整
    if (exclude >= YJBAdPlatform_None && exclude < YJBAdPlatform_Count) {
        _bannerWeights[0] -= _bannerWeights[exclude];
        _bannerWeights[exclude] = 0;
    }
    else {
        [[YJBConfigData sharedInstance] fillBannerWeight:_bannerWeights];
    }
    return [self assignPlatformWith:_bannerWeights];
}


#pragma mark - Private

// 分配广告平台
- (YJBAdPlatform)assignPlatformWith:(unsigned int[])weights
{
    YJBAdPlatform returnType = YJBAdPlatform_None;
    // 当前配置
#ifdef DEBUG
    printf("当前配置：");
    for (int i = 1; i<YJBAdPlatform_Count; i++) {
        printf("%02d ", weights[i]);
    }
    printf("\n");
#endif
    // 生成随机数
    unsigned int totalWeights = weights[0];
    if (totalWeights > 0) {
        srandom([[NSDate date] timeIntervalSince1970]);
        unsigned int randomNum = (arc4random()%totalWeights)+1;
        // 查看随机数落点
        unsigned int sumNum = 0;
        for (int i = 1; i<YJBAdPlatform_Count; i++) {
            sumNum += weights[i];
            if (sumNum >= randomNum) {
                returnType = i;
#ifdef DEBUG
                NSLog(@"%@分配到的广告平台：%@", _bannerWeights==weights?@"Banner":@"插屏",
                      [[YJBAdapterManager sharedInstance] platformNameOf:returnType]);
#endif
                return returnType;
            }
        }
#ifdef DEBUG
        NSLog(@"总权重为%d，分配失败", totalWeights);
#endif
        return YJBAdPlatform_None;
    }
#ifdef DEBUG
    NSLog(@"总权重为0，无法分配广告平台");
#endif
    return YJBAdPlatform_None;
}

@end
