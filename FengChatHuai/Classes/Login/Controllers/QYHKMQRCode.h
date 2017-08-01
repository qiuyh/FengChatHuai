//
//  QYHKMQRCode.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/5.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYHKMQRCode : NSObject

+ (CIImage *)createQRCodeImage:(NSString *)source;
+ (UIImage *)resizeQRCodeImage:(CIImage *)image withSize:(CGFloat)size;
+ (UIImage *)specialColorImage:(UIImage*)image withRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withIconSize:(CGSize)iconSize;
+ (UIImage *)addIconToQRCodeImage:(UIImage *)image withIcon:(UIImage *)icon withScale:(CGFloat)scale;

@end
