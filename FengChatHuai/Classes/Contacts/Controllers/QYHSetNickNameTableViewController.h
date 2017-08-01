//
//  QYHSetNickNameTableViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^NickNameBlock)(NSString *nickName);

@interface QYHSetNickNameTableViewController : UITableViewController

@property (nonatomic, copy) NSString *remarkName;

@property (nonatomic, copy) NSString *fromID;

@property (nonatomic,copy) NickNameBlock block;

@end
