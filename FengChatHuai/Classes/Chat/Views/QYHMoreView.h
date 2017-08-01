//
//  QYHMoreView.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^MoreBlock) (NSInteger index);

@interface QYHMoreView : UIView

-(void)setMoreBlock:(MoreBlock) block;

@end
