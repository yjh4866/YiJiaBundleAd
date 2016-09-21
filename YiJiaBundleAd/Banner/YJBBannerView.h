//
//  YJBBannerView.h
//  YiJiaBundleAd
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import <UIKit/UIKit.h>


#define YJBBannerSize  ((UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)?CGSizeMake(320.0f, 50.0f):CGSizeMake(728.0f, 90.0f))

@protocol YJBBannerViewDelegate;

@interface YJBBannerView : UIView

@property (nonatomic, weak) id <YJBBannerViewDelegate> delegate;

// 开始展现广告
- (void)startAd;

@end


@protocol YJBBannerViewDelegate <NSObject>

@optional

// Banner广告展现成功
- (void)yjbBannerViewShowSuccess;

// Banner广告展现失败
- (void)yjbBannerViewShowFailure:(NSString *)errorMsg;

// Banner广告被移除
- (void)yjbBannerViewRemoved;

@end
