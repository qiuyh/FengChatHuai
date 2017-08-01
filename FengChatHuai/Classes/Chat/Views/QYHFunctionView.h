//
//  QYHFunctionView.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

//定义对应的block类型，用于数据的交互
typedef void (^FunctionBlock) (UIImage *image, NSString *imageText);

@interface QYHFunctionView : UIView

//资源文件名
@property (nonatomic, strong) NSString *plistFileName;
//接受block块
-(void)setFunctionBlock:(FunctionBlock) block;

-(void)tapButton1: (id) sender;

@end
