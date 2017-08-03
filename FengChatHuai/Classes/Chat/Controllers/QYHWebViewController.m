//
//  QYHWebViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/11.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHWebViewController.h"

@interface QYHWebViewController ()<UIWebViewDelegate>
{
    UIWebView *_webView;//可以加载网页数据的View
}
@end

@implementation QYHWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //调用加载web
    [self loadWeb];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];

}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:self action:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        navigationSpacer.width = - 10.5;  // ios 7
        
    }else{
        navigationSpacer.width = - 6;  // ios 6
    }
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popAction)];
    
    
    self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
}


- (void)popAction{
    
    if ([_webView canGoBack]) {
        [_webView goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    
}

//加载web
- (void)loadWeb
{
    //初始化_webView
    _webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:_webView];
    [self.view sendSubviewToBack:_webView];
    
    
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    _webView.delegate=self;
    [_webView setScalesPageToFit:YES];
    _webView.scrollView.bounces=NO;
    _webView.scrollView.showsVerticalScrollIndicator=NO;
    
    //加载一个网页地址
    [_webView loadRequest:request];
}

#pragma mark - webViewDelegate

//加载完成后设置偏移量
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    _webView.scrollView.contentOffset=CGPointMake(0, 50);
//    _webView.scrollView.contentInset=UIEdgeInsetsMake(-50, 0, 0, 0);
//    [_webView setScalesPageToFit:YES];
//    _webView.scrollView.bounces=NO;
//    _webView.scrollView.showsVerticalScrollIndicator=NO;
//    
    
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
    });
    
    
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];//自己添加的，原文没有提到。
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    NSLog(@"request.url==%@",request);
    
    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(nonnull NSError *)error
{
    [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [_webView loadRequest:nil];
    [_webView removeFromSuperview];
    _webView = nil;
    _webView.delegate = nil;
    [_webView stopLoading];
}



@end
