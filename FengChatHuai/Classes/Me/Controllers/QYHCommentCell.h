//
//  QYHCommentCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/1.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MLEmojiLabel.h"

@protocol QYHCommentCellDelegate <NSObject>

- (void)clickNickNameByPhotoNumber:(NSString *)photoNumber;

- (void)openUrl:(NSString *)urlString;

- (void)showMenuCopy:(NSString *)copyString touch:(UITouch *)touch gesture:(UIGestureRecognizer *)gesture;

@end

@interface QYHCommentCell : UITableViewCell

@property(nonatomic,copy) NSString *toUserPhoneNumber;//回复别人的信息
@property (strong, nonatomic)  MLEmojiLabel *commetLabel;

@property (nonatomic, weak) id<QYHCommentCellDelegate> delegate;

- (void)confitDataByDic:(NSDictionary *)commentDic;

@end
