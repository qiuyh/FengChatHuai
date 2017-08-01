//
//  QYHChatCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/27.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHChatMssegeModel.h"
#import "MLEmojiLabel.h"

@class QYHChatCell;

typedef  NS_ENUM(NSInteger,ContentType)
{
    HeTextContent,
    MyTextContent,
    HeImageContent,
    MyImageContent,
    HeVoiceContent,
    MyVoiceContent,
};

//button点击回调传出图片
typedef void (^ButtonImageBlock) (NSString *imageURL);
typedef void(^ClickTheSendAgainBlock)(QYHChatMssegeModel* messageModel);
typedef void(^ShowMenuBlock)(QYHChatCell *view);
typedef void(^PushToDetailVCBlock)(NSString *user);

@protocol QYHChatCellDelegate <NSObject>

- (void)pushToWebViewControllerByUrl:(NSString *)url;

@end

@interface QYHChatCell : UITableViewCell


@property (strong, nonatomic) IBOutlet UIImageView *headImageView;//头像
@property (strong, nonatomic) IBOutlet UIImageView *chatBgImageView;//背景图
@property (strong, nonatomic) IBOutlet UITextView *chatTextView;//文字内容
@property (strong, nonatomic)  MLEmojiLabel *mlEmojiLabel;

@property (strong, nonatomic) IBOutlet UIButton *imageButton;//图片、声音

@property (strong, nonatomic) IBOutlet UIImageView *voiceImageView;//声音标志
@property (strong, nonatomic) IBOutlet UIImageView *redTipUIImageView ;//红点提示
@property (strong, nonatomic) IBOutlet UILabel *voiceTimeLabel;//声音的时间

@property (weak, nonatomic) IBOutlet UIImageView *imgbView;

@property (strong, nonatomic) AVAudioPlayer *audioPlayer;

@property (strong, nonatomic) NSString *playURL;

@property (assign, nonatomic) NSInteger playTime;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatBgImageWidthConstraint;//背景图的宽度约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *chatTextWidthConstaint;//文字内容的宽度约束
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *buttonWidthConstraint;//图片、声音的宽度约束
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *timeLabelWithConstraint;



@property (nonatomic,retain) IBOutlet UIActivityIndicatorView* activityView;
@property (nonatomic,retain) IBOutlet UIImageView* sendFailuredImageView;

@property (strong, nonatomic) QYHChatMssegeModel *messageModel;
@property (nonatomic,copy) ClickTheSendAgainBlock sendAgain;
@property (nonatomic,copy) ShowMenuBlock menuBlock;
@property (nonatomic,copy) PushToDetailVCBlock pushBlock;

@property (nonatomic,weak) id<QYHChatCellDelegate> delagete;

- (void)setMssegeModel:(QYHChatMssegeModel*)messageModel;

-(void)setCellValue:(NSString *)str urlString:(NSString *)urlString type:(ContentType)contentType headImage:(UIImage*)headImage imageType:(NSInteger)imageType audioTime:(NSInteger)audioTime;

-(void)setButtonImageBlock:(ButtonImageBlock) block;

-(void)setSendAgainBlock:(ClickTheSendAgainBlock)block;

- (void)playAudioByPlayUrl:(NSString *)urlString;

- (void)setTime:(NSString *)msgObj;

@end
