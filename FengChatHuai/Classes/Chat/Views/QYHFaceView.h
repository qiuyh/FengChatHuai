//
//  QYHFaceView.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

//声明表情对应的block,用于把点击的表情的图片和图片信息传到上层视图
typedef void (^FaceBlock) (UIImage *image, NSString *imageText);

@interface QYHFaceView : UIView


//图片对应的文字
@property (nonatomic, strong) NSString *imageText;
//表情图片
@property (nonatomic, strong) UIImage *headerImage;

@property (strong, nonatomic) UIImageView *imageView;

//设置block回调
-(void)setFaceBlock:(FaceBlock)block;

//设置图片，文字
-(void)setImage:(UIImage *) image ImageText:(NSString *) text;

@end
