//
//  CALayer+Additions.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "CALayer+Additions.h"
#import <objc/runtime.h>


@implementation CALayer (Additions)


- (UIColor *)borderColorFromUIColor {
    
    return objc_getAssociatedObject(self, @selector(borderColorFromUIColor));
}

- (void)setBorderColorFromUIColor:(UIColor *)color
{
    objc_setAssociatedObject(self, @selector(borderColorFromUIColor), color, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self setBorderColorFromUI: self.borderColorFromUIColor];
    
}

- (void)setBorderColorFromUI:(UIColor *)color
{
    self.borderColor = color.CGColor;
    
}


@end
