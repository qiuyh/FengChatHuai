//
//  UIBarButtonItem+Additions.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "UIBarButtonItem+Additions.h"

static CGFloat const kTextFontOfSzie = 15.0f;

@implementation UIBarButtonItem (Additions)


+ (UIBarButtonItem *)navigationSpacer{
    UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:nil action:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        navigationSpacer.width = - 15;  // ios 7
    }else{
        navigationSpacer.width = - 6;  // ios 6
    }
    return navigationSpacer;
}

+ (UIBarButtonItem *)setBackItemTitle:(NSString *)title
                               target:(id)target
                               action:(SEL)action
{
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:kTextFontOfSzie],
                                NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    
    CGRect aRect = [title boundingRectWithSize:CGSizeMake(100, 0)
                                       options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                    attributes:attribute context:nil];
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    backBtn.frame = CGRectMake(0, 0, 20 + aRect.size.width, 30);
    
    [backBtn setImage:[UIImage imageNamed:@"leftNavBarItem_back"] forState:UIControlStateNormal];
    
    [backBtn setTitle:[NSString stringWithFormat:@" %@",title]
             forState:UIControlStateNormal];
    
    [backBtn setTitleColor:[UIColor whiteColor]
                  forState:UIControlStateNormal];
    
    [backBtn setTitleColor:[UIColor grayColor]
                  forState:UIControlStateHighlighted];
    
    backBtn.titleLabel.font = [UIFont systemFontOfSize:kTextFontOfSzie];
    
    backBtn.backgroundColor = [UIColor clearColor];
    
    [backBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backBarItem = [[UIBarButtonItem alloc]initWithCustomView:backBtn];
    
    return backBarItem;
}



@end
