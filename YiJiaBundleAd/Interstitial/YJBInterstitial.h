//
//  YJBInterstitial.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YJBInterstitialDelegate;

@interface YJBInterstitial : NSObject

// 关闭时是否加载下一个广告，默认为YES
@property (nonatomic, assign) BOOL loadNextWhenClose;

@property (nonatomic, weak) id<YJBInterstitialDelegate> delegate;

+ (instancetype)sharedInstance;

// 加载插屏广告
- (void)loadInterstitial;

// 显示插屏广告
- (void)showInterstitial;

// 取消显示插屏广告
- (void)cancelInterstitial;

@end


@protocol YJBInterstitialDelegate <NSObject>

@optional

// 插屏广告加载成功
- (void)yjbInterstitialLoadSuccess;

// 插屏广告加载失败
- (void)yjbInterstitialLoadFailure:(NSError *)error;

// 插屏广告展现成功
- (void)yjbInterstitialShowSuccess;

// 插屏广告关闭完成
- (void)yjbInterstitialCloseFinished;

// 插屏广告被点击
- (void)yjbInterstitialClicked;

@end
