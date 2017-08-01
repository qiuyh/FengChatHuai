//
//  QYHOperationMenuView.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHOperationMenuView : UIView

@property (nonatomic, assign, getter = isShowing) BOOL show;
@property (nonatomic, assign, getter = isLinking) BOOL isLink;

@property (nonatomic, copy) void (^likeButtonClickedOperation)(BOOL isLink);
@property (nonatomic, copy) void (^commentButtonClickedOperation)();

@end
