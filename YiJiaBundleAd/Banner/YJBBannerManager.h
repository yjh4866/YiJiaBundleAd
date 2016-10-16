//
//  YJBBannerManager.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@protocol YJBBannerManagerDelegate;

@interface YJBBannerManager : NSObject

@property (nonatomic, weak) id <YJBBannerManagerDelegate> delegate;

// 显示Banner
- (void)showBannerOn:(UIView *)bannerSuperView withDisplayTime:(NSTimeInterval)displayTime;

// 移除Banner
- (void)removeBanner;

@end


@protocol YJBBannerManagerDelegate <NSObject>

// Banner广告展现成功
- (void)yjbBannerManagerShowSuccess:(YJBBannerManager *)adManager;

// Banner广告展现失败
- (void)yjbBannerManager:(YJBBannerManager *)adManager showBannerFailure:(NSError *)error;

// Banner广告被点击
- (void)yjbBannerManagerClicked:(YJBBannerManager *)adManager;

@end
