//
//  YJBInterstitialManager.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YJBInterstitialManagerDelegate;

@interface YJBInterstitialManager : NSObject

@property (nonatomic, weak) id <YJBInterstitialManagerDelegate> delegate;

// 加载插屏广告
- (void)loadInterstitial;

// 显示插屏广告
- (void)showInterstitial;

// 取消显示插屏广告
- (void)cancelInterstitial;

@end


@protocol YJBInterstitialManagerDelegate <NSObject>

// 插屏广告加载成功
- (void)yjbInterstitialManagerLoadSuccess:(YJBInterstitialManager *)adManager;

// 插屏广告加载失败
- (void)yjbInterstitialManager:(YJBInterstitialManager *)adManager loadFailure:(NSError *)error;

// 插屏广告展现成功
- (void)yjbInterstitialManagerShowSuccess:(YJBInterstitialManager *)adManager;

// 插屏广告关闭完成
- (void)yjbInterstitialManagerCloseFinished:(YJBInterstitialManager *)adManager;

// 插屏广告被点击
- (void)yjbInterstitialManagerClicked:(YJBInterstitialManager *)adManager;

@end
