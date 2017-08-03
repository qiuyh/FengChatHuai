//
//  QYHKeyBoardManager.h
//  qyhKeyBoardManager
//
//  Created by Qiu on 16/4/3.
//  Copyright © 2016年 YongHuaiQIu. All rights reserved.

//1.把QYHKeyBoardManager文件夹（QYHKeyBoardManager.h和QYHKeyBoardManager.m）拉进项目中，
//2.在要弹起键盘的控制器里面导入头文件,
//3.然后
//3.1在viewDidAppear 设置[QYHKeyBoardManager shareInstance].selfView = self.view;
//3.2在viewWillDisappear 设置[QYHKeyBoardManager shareInstance].selfView = nil;就OK

#warning  - 注意.......
/***
 *经过本人测试，适合所有的界面，若遇到什么bug可以向我提出来，共同学习。
 *
 *要在viewDidAppear设置，否则在xib或者storyboard里面的不起作用。
 *要在viewWillDisappear设置为nil，移除当前添加的通知，否则会导致其他问题。
 */


#import <UIKit/UIKit.h>

@interface QYHKeyBoardManager : NSObject

@property (nonatomic,weak) UIView *selfView;

+(instancetype)shareInstance;


@end
