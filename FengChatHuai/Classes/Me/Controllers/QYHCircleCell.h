//
//  QYHCircleCell.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHCircleModel.h"

@interface QYHCircleCell : UITableViewCell

@property (nonatomic,strong) UIView *contentBgView;

-(void)confitDataByQYHCircleContentModel:(QYHCircleContentModel *)model firstRow:(BOOL)isFirstRow;

@end
