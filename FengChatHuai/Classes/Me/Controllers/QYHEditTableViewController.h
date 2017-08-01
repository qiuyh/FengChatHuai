//
//  QYHEditTableViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYHEditTableViewControllerDelegate <NSObject>

- (void)didFinishedSave;

@end

@interface QYHEditTableViewController : UITableViewController


/**
 *  上一个控制器(个人信息控制器)传入的cell
 */
@property(strong,nonatomic)UITableViewCell *cell;


@property(nonatomic,assign) NSInteger tag;

@property (nonatomic,weak) id<QYHEditTableViewControllerDelegate>delegate;

@end
