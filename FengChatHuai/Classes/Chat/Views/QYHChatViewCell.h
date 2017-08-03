//
//  QYHChatViewCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/25.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "MGSwipeTableCell/MGSwipeTableCell.h"

@interface QYHChatViewCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel1;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UILabel *redLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *redLabelWithConstraint;

@end
