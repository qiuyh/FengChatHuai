//
//  QYHMoreView.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHMoreView.h"

@interface QYHMoreView()

@property (nonatomic, strong) MoreBlock block;

@end


@implementation QYHMoreView

- (id)initWithFrame:(CGRect)frame
{
    frame = CGRectMake(0, 0, SCREEN_WIDTH, 230);
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/4.0-10, 100-40, 60, 60)];
        [button1 setBackgroundImage:[UIImage imageNamed:@"dd_album"] forState:UIControlStateNormal];
        button1.tag = 1;
        button1.layer.cornerRadius = 30;
        button1.clipsToBounds = YES;
        [button1 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(button1.frame.origin.x, CGRectGetMaxY(button1.frame)+10, 60, 21)];
        label1.centerX = button1.centerX;
        label1.text = @"相册";
        label1.font = [UIFont systemFontOfSize:15];
        label1.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:button1];
        [self addSubview:label1];
        
        UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*3/4.0-50, 100-40, 60, 60)];
        [button2 setBackgroundImage:[UIImage imageNamed:@"dd_take-photo"] forState:UIControlStateNormal];
        [button2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        button2.tag = 2;
        button2.layer.cornerRadius = 30;
        button2.clipsToBounds = YES;
        [button2 addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(button2.frame.origin.x, CGRectGetMaxY(button2.frame)+10, 60, 21)];
        label2.centerX = button2.centerX;
        label2.text = @"拍照";
        label2.font = [UIFont systemFontOfSize:15];
        label2.textAlignment = NSTextAlignmentCenter;
        
        [self addSubview:button2];
        [self addSubview:label2];

        
    }
    return self;
}

-(void) setMoreBlock:(MoreBlock)block
{
    self.block = block;
}

-(void) tapButton:(UIButton *)sender
{
    self.block(sender.tag);
}

@end
