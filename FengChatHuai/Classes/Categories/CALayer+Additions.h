//
//  CALayer+Additions.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>


@interface CALayer (Additions)


@property(nonatomic, strong) UIColor *borderColorFromUIColor;

- (void)setBorderColorFromUIColor:(UIColor *)color;


@end
