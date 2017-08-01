//
//  QYHProgressHUD.m
//  Original
//
//  Created by iMacQIU on 16/3/11.
//  Copyright © 2016年 qiuyognhuai. All rights reserved.
//

#import "QYHProgressHUD.h"

static NSTimeInterval const kAfterDelay = 2.0f;

@implementation QYHProgressHUD

+ (instancetype)showHUDInView:(UIView *)parentView
{
    if (parentView == nil) {
        parentView = [UIApplication sharedApplication].keyWindow;
    }
    
    QYHProgressHUD *hudView = [QYHProgressHUD showHUDAddedTo:parentView animated:YES];
    
    hudView.alpha = 0.8f;
    
    return hudView;
}

+ (instancetype)showHUDInView:(UIView *)parentView onlyMessage:(NSString *)message
{
    QYHProgressHUD *hudView = [QYHProgressHUD showHUDInView:parentView];
    
    hudView.mode = MBProgressHUDModeText;
    
//    hudView.labelText = message;
    
    hudView.detailsLabelText = message;
    
    hudView.detailsLabelFont = [UIFont systemFontOfSize:15.0f];

    
    [hudView hide:YES afterDelay:kAfterDelay];
    
    return hudView;
}

+ (instancetype)showSuccessHUD:(UIView *)parentView message:(NSString *)message
{
    QYHProgressHUD *successView = [QYHProgressHUD showHUDInView:parentView];
    
//    successView.labelText = message;
    successView.detailsLabelText = message;
    
    successView.detailsLabelFont = [UIFont systemFontOfSize:15.0f];
    
    successView.alpha = 0.9f;
    
    successView.animationType = MBProgressHUDAnimationZoomOut;
    
    successView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_success.png"]];
    
    successView.mode = MBProgressHUDModeCustomView;
    
    [successView hide:YES afterDelay:kAfterDelay];
    
    return successView;
}


+ (instancetype)showErrorHUD:(UIView *)parentView message:(NSString *)message
{
    QYHProgressHUD *errorView = [QYHProgressHUD showHUDInView:parentView];
    
    //    errorView.labelText = message;
    
    errorView.detailsLabelText = message;
    
    errorView.detailsLabelFont = [UIFont systemFontOfSize:15.0f];
    
    
    errorView.alpha = 0.9f;
    
    errorView.animationType = MBProgressHUDAnimationZoomOut;
    
    errorView.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hud_error.png"]];
    
    errorView.mode = MBProgressHUDModeCustomView;
    
    [errorView hide:YES afterDelay:kAfterDelay];
    
    return errorView;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
