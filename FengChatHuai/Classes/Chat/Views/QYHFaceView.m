//
//  QYHFaceView.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHFaceView.h"

@interface QYHFaceView ()

@property(strong, nonatomic) FaceBlock block;


@end


@implementation QYHFaceView

//初始化图片
- (id)initWithFrame:(CGRect)frame
{
    //face的大小
//    frame.size.height = 30;
//    frame.size.width = 30;
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [self addSubview:self.imageView];
    }
    return self;
}

-(void) setFaceBlock:(FaceBlock)block
{
    self.block = block;
}


-(void) setImage:(UIImage *)image ImageText:(NSString *)text
{
    //显示图片
    [self.imageView setImage:image];
    
    //把图片存储起来
    self.headerImage = image;
    
    self.imageText = text;
}

//点击时回调
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
       
    
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    NSLog(@"point==%@",self.imageText);
    
    CGFloat space = (SCREEN_WIDTH/7.0-30)/2.0;
    
    CGRect rect = CGRectMake(-space, -space, 30 + 2*space, 30 + 2*space);
    
    //判断触摸的结束点是否在图片中
    if (CGRectContainsPoint(rect, point))
    {
        UIView *grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        grayView.layer.cornerRadius = 12;
        grayView.clipsToBounds   = YES;
        grayView.backgroundColor = [UIColor grayColor];
        grayView.alpha = 0.3;
        [self insertSubview:grayView belowSubview:self.imageView];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [grayView removeFromSuperview];
        });
        //回调,把该头像的信息传到相应的controller中
        self.block(self.headerImage, self.imageText);
    }
}


@end
