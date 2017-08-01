//
//  UIColor+Additions.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (UIColor*)colorWithHexString:(NSString*)hex;
+ (UIColor *)colorWithHexNumber:(NSInteger)rgbValue;
+ (UIColor *)HFPinkColor;
+ (UIColor *)colorWithHex:(int)color;

@end
