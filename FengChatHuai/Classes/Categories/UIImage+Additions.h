//
//  UIImage+Additions.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/19.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UIImage (Additions)

+ (UIImage*)maskImage:(UIImage *)image
             withMask:(UIImage *)maskImage;

//按照UIImageOrientation的定义，利用矩阵自定义实现对应的变换；
+ (UIImage *)transformImage:(UIImage *)aImage
                   rotation:(UIImageOrientation)orientation;

+ (void)fullResolutionImageFromALAsset:(NSURL *)assetUrl result:(void(^)(UIImage *image))result;

//图片压缩到指定 大小尺寸
+ (UIImage*)imageByScalingAndCroppingForSize:(CGSize)targetSize withImage:(UIImage *)image;

+ (UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;


+ (UIImage *)createRoundedRectImage:(UIImage *)image withSize:(CGSize)size withRadius:(NSInteger)radius;

@end
