//
//  QYHContactsCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/25.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <MGSwipeTableCell/MGSwipeTableCell.h>

@interface QYHContactsCell : MGSwipeTableCell

@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;

@end
