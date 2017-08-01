//
//  QYHDetailTableViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/5.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QYHChatMssegeModel.h"

typedef void(^MessageModelBlock)(QYHChatMssegeModel *model);

@interface QYHDetailTableViewController : UITableViewController

@property (nonatomic,strong) NSDictionary *dic;

@property (nonatomic,assign) BOOL isFromSC;

@property (nonatomic,copy) NSString *remarkName;

@property (nonatomic,assign) BOOL isFriend;

/**
 *  判断是哪个好友？用于发信息
 */
//@property (nonatomic,assign) NSInteger index;
/**
 *  从聊天界面过来的
 */
@property (nonatomic,assign) BOOL isFromChatVC;

/**
 *  是否是从添加朋友页面进来的（未通过验证的）
 */

@property (nonatomic,assign) BOOL isAddFriendVC;

@property (nonatomic,assign) BOOL isReject;

@property (nonatomic,copy) NSString *content;

@property (nonatomic,strong) QYHChatMssegeModel *mssegeModel;

//详情页面传回去给新朋友界面
@property (nonatomic,copy) MessageModelBlock myBlock;

@end
