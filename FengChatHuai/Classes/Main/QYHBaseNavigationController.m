//
//  QYHBaseNavigationController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/20.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHBaseNavigationController.h"

@interface QYHBaseNavigationController ()<UINavigationControllerDelegate>
@property (nonatomic,weak) id popDelage;


@end

@implementation QYHBaseNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
   

    self.popDelage = self.interactivePopGestureRecognizer.delegate;
    
    self.delegate = self;
}

-(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count)
    {
        
        UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                             target:nil action:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            navigationSpacer.width = - 10.5;  // ios 7
            
        }else{
            navigationSpacer.width = - 6;  // ios 6
        }
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:nil action:@selector(popAction)];
        
        
        viewController.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
    }
    

    
     viewController.hidesBottomBarWhenPushed = YES;
    
    [super pushViewController:viewController animated:animated];
}


- (void)popAction
{
    [self popViewControllerAnimated:YES];
}


- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    
    if (viewController != self.viewControllers[0]) {
        
      
        
//        [QYHKeyBoardManagerViewController shareInstance].selfView = viewController.view;

        
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (viewController == self.viewControllers[0]) { // 是根控制器
        
        self.interactivePopGestureRecognizer.delegate = _popDelage;
        
    }else{ // 非根控制器
        self.interactivePopGestureRecognizer.delegate = nil;
        
    }
    
}

@end
