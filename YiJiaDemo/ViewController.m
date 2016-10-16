//
//  ViewController.m
//  YiJiaDemo
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "ViewController.h"
#import "YiJiaBundleAd.h"

@interface ViewController () <YJBBannerViewDelegate, YJBInterstitialDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [YiJiaBundleAd setTestDevicesForAdmob:@[@"232438c1ecfe57ce4f5fa05015ced793"]];
    [YJBInterstitial sharedInstance].delegate = self;
    
    YJBBannerView *bannerView = [[YJBBannerView alloc] initWithFrame:CGRectZero];
    bannerView.delegate = self;
    [self.view addSubview:bannerView];
    [bannerView startAd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)clickLoadInterstitial:(id)sender
{
    [[YJBInterstitial sharedInstance] loadInterstitial];
}

- (IBAction)clickShowInterstitial:(id)sender
{
    [[YJBInterstitial sharedInstance] showInterstitial];
}


#pragma mark - YJBBannerViewDelegate

// Banner广告展现成功
- (void)yjbBannerViewShowSuccess
{
    
}

// Banner广告展现失败
- (void)yjbBannerViewShowFailure:(NSError *)error
{
    
}

// Banner广告被移除
- (void)yjbBannerViewRemoved
{
    
}


#pragma mark - YJBInterstitialDelegate

// 插屏广告加载成功
- (void)yjbInterstitialLoadSuccess
{
    
}

// 插屏广告加载失败
- (void)yjbInterstitialLoadFailure:(NSError *)error
{
    
}

// 插屏广告展现成功
- (void)yjbInterstitialShowSuccess
{
    
}

// 插屏广告关闭完成
- (void)yjbInterstitialCloseFinished
{
    
}

// 插屏广告被点击
- (void)yjbInterstitialClicked
{
    
}

@end
