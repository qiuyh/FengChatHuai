//
//  QYHMessageTableView.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/22.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHMessageTableView.h"

@implementation QYHMessageTableView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setContentSize:(CGSize)contentSize
{
    if (!CGSizeEqualToSize(self.contentSize, CGSizeZero))
    {
        if (contentSize.height > self.contentSize.height)
        {
            CGPoint offset = self.contentOffset;
            offset.y += (contentSize.height - self.contentSize.height);
            self.contentOffset = offset;
        }
    }
    [super setContentSize:contentSize];
}



@end
