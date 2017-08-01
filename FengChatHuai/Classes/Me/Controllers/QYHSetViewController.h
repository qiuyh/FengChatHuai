//
//  QYHSetViewController.h
//  FengChatHuai
//
//  Created by 邱永槐 on 16/7/3.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QYHSetViewControllerDelegate <NSObject>

- (void)didFinishedSave;

@end

@interface QYHSetViewController : UIViewController

/**
 *  上一个控制器(个人信息控制器)传入的cell
 */
@property(strong,nonatomic)UITableViewCell *cell;

@property (nonatomic,assign) BOOL isSecondPage;
@property (nonatomic,copy) NSString *provinceName;

@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *citysArray;
@property (nonatomic,strong) NSMutableArray *areasArray;


@property (nonatomic,weak) id<QYHSetViewControllerDelegate>delegate;
@end
