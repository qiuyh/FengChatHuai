//
//  QYHNewFriendTableViewCell.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/7/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHNewFriendTableViewCell.h"
#import "XMPPvCardTemp.h"

@implementation QYHNewFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.acceptButton.layer.cornerRadius = 5;
    self.acceptButton.clipsToBounds = YES;
    
    self.acceptedLabel.hidden = YES;
}

-(void)setDataForCell:(QYHChatMssegeModel *)messegeModel{
    
    switch (messegeModel.addStatus) {
        case AddFriendNormer:
            self.acceptButton.hidden  = NO;
            self.acceptedLabel.hidden = YES;
            [self.acceptButton setTitle:@"接受" forState:UIControlStateNormal];
            break;
            
        case AddFriendAgreed:
            self.acceptButton.hidden  = YES;
            self.acceptedLabel.hidden = NO;
            self.acceptedLabel.text = @"已接受";
            break;

        case AddFriendReject:
            self.acceptButton.hidden  = YES;
            self.acceptedLabel.hidden = NO;
            self.acceptedLabel.text = @"已拒绝";
            break;
        case AddAgreeded:
            self.acceptButton.hidden  = NO;
            self.acceptedLabel.hidden = YES;
            [self.acceptButton setTitle:@"会话" forState:UIControlStateNormal];
            break;
            
        case AddRejected:
            self.acceptButton.hidden  = YES;
            self.acceptedLabel.hidden = NO;
            self.acceptedLabel.text = @"已拒绝";
            break;
            
        default:
            break;
    }
    
    
//    XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
//    XMPPJID *byJID = [XMPPJID jidWithUser:messegeModel.fromUserID domain:myJid.domain resource:myJid.resource];
//    
//    XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
    
     XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:messegeModel.fromUserID];
    
    self.nameLabel.text    = vCard.nickname ? [vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:messegeModel.fromUserID;
    self.imgView.image     = [UIImage imageWithData:vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0)];
    self.contentLabel.text = messegeModel.content;
    
//    messegeModel.messegeID
//    messegeModel.fromUserID
//    messegeModel.toUserID
//    messegeModel.content
//    messegeModel.time
//    messegeModel.type
//    messegeModel.addStatus
//    messegeModel.isRead
}

- (IBAction)acceptAction:(id)sender {
    
    if (self.block) {
        self.block(YES);
    }
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
