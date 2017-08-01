//
//  QYHRecordingView.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/6/11.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, DDRecordingState)
{
    DDShowVolumnState,
    DDShowCancelSendState,
    DDShowRecordTimeTooShort
};


@interface QYHRecordingView : UIView

@property (nonatomic,assign)DDRecordingState recordingState;

- (instancetype)initWithState:(DDRecordingState)state;
- (void)setVolume:(float)volume;


@end
