//
//  QYHToolView.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHMoreView.h"
#import "QYHFunctionView.h"

//定义block类型把ToolView中TextView中的文字传入到Controller中
typedef void (^MyTextBlock) (NSString *myText);

//录音时的音量
typedef void (^AudioVolumeBlock) (CGFloat volume);

//录音存储地址
typedef void (^AudioURLBlock) (NSString *audioURL);
//录音总时间
typedef void (^AudioTimeBlock) (CGFloat audioTime);

//改变根据文字改变TextView的高度
typedef void (^ContentSizeBlock)(CGSize contentSize);

//录音开始的回调
typedef void (^BeganRecordBlock)(int flag);

//录音取消的回调
typedef void (^CancelRecordBlock)(int flag);

//扩展功能块按钮tag的回调
typedef void (^ExtendFunctionBlock)(int buttonTag);


@interface QYHToolView : UIView<UITextViewDelegate,AVAudioRecorderDelegate,UIGestureRecognizerDelegate>

//文本视图
@property (nonatomic, strong) UITextView *sendTextView;

//more
@property (nonatomic, strong) QYHMoreView *moreView;

//表情键盘
@property (nonatomic, strong) QYHFunctionView *functionView;

@property (nonatomic,strong) UIView *faceMoreView;

@property (nonatomic,assign) BOOL isChating;

- (void)initView:(BOOL)isChating;

//变成表情键盘
-(void)tapChangeKeyBoardButton:(UIButton *) sender;

//功能扩展
-(void)tapMoreButton:(UIButton *) sender;

//设置MyTextBlock
-(void) setMyTextBlock:(MyTextBlock)block;

//设置声音回调
-(void) setAudioVolumeBlock:(AudioVolumeBlock) block;

//设置录音地址回调
-(void) setAudioURLBlock:(AudioURLBlock) block;

-(void) setAudioTimeBlock:(AudioTimeBlock) block;

-(void)setContentSizeBlock:(ContentSizeBlock) block;

-(void)setCancelRecordBlock:(CancelRecordBlock)block;

-(void)setBeganRecordBlock:(BeganRecordBlock)block;

-(void)setExtendFunctionBlock:(ExtendFunctionBlock) block;


-(void) changeFunctionHeight: (float) height;


@end
