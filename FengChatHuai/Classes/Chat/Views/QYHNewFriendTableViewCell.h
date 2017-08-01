//
//  QYHNewFriendTableViewCell.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/7/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHChatMssegeModel.h"

typedef void(^AcceptBlock)(BOOL isAccepted);

@interface QYHNewFriendTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *acceptButton;
@property (weak, nonatomic) IBOutlet UILabel *acceptedLabel;

@property (nonatomic,copy) AcceptBlock block;

- (void)setDataForCell:(QYHChatMssegeModel *)messegeModel;

@end
