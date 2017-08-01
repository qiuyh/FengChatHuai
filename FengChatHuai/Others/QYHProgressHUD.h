//
//  QYHProgressHUD.h
//  Original
//
//  Created by iMacQIU on 16/3/11.
//  Copyright © 2016年 qiuyognhuai. All rights reserved.
//

#import "MBProgressHUD.h"

@interface QYHProgressHUD : MBProgressHUD


+ (instancetype)showHUDInView:(UIView *)parentView;

+ (instancetype)showHUDInView:(UIView *)parentView onlyMessage:(NSString *)message;

+ (instancetype)showSuccessHUD:(UIView *)parentView message:(NSString *)message;

+ (instancetype)showErrorHUD:(UIView *)parentView message:(NSString *)message;

@end
