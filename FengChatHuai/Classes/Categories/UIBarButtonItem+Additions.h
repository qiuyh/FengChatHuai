//
//  UIBarButtonItem+Additions.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Additions)

+ (UIBarButtonItem *)navigationSpacer;

+ (UIBarButtonItem *)setBackItemTitle:(NSString*)title target:(id)target action:(SEL)action;



@end
