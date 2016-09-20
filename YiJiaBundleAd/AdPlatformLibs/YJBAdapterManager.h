//
//  YJBAdapterManager.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YJBAdapter.h"

@interface YJBAdapterManager : NSObject

+ (instancetype)sharedInstance;

// 根据广告平台类型获取相应的适配器
+ (YJBAdapter *)getAdapterOfADPlatform:(YJBAdPlatform)platformType;

// 根据广告平台关键字查询广告平台类型
- (YJBAdPlatform)platformTypeOf:(NSString *)platformKey;

// 根据广告平台类型查询广告平台关键字
- (NSString *)platformKeyOf:(YJBAdPlatform)platformType;

// 根据广告平台类型查询广告平台名称
- (NSString *)platformNameOf:(YJBAdPlatform)platformType;

@end
