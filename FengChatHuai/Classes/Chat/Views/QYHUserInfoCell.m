//
//  QYHUserInfoCell.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHUserInfoCell.h"

@interface QYHUserInfoCell()

@property (strong, nonatomic) IBOutlet UIImageView *headImage;
@property (strong, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *jidLable;

@end


@implementation QYHUserInfoCell


-(void)setCellValue:(NSString *)username WithJid:(NSString *)jid
{
    self.userNameLabel.text = username;
    self.jidLable.text = jid;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
