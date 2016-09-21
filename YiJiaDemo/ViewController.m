//
//  ViewController.m
//  YiJiaDemo
//
//  Created by 1JiaGame_yangjh on 16/9/20.
//  Copyright © 2016年 1JiaGame. All rights reserved.
//

#import "ViewController.h"
#import "YiJiaBundleAd.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [YiJiaBundleAd setTestDevicesForAdmob:@[@"232438c1ecfe57ce4f5fa05015ced793"]];
    
    YJBBannerView *bannerView = [[YJBBannerView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:bannerView];
    [bannerView startAd];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
