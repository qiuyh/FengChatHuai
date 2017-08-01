//
//  ViewController.h
//  QYHKeyBoardManager
//
//  Created by 邱永槐 on 16/4/3.
//  Copyright © 2016年 YongHuaiQIu. All rights reserved.
//
//1.在要弹起键盘的控制器里面导入头文件,
//2.然后设置[QYHKeyBoardManagerViewController shareInstance].selfView = self.view;就OK

#import <UIKit/UIKit.h>

@interface QYHKeyBoardManagerViewController : UIViewController


@property (nonatomic,strong) UIView *selfView ;


+(instancetype)shareInstance;

@end

