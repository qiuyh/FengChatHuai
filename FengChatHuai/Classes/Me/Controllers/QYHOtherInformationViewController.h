//
//  QYHOtherInformationViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/22.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHOtherInformationViewController : UIViewController

@property (nonatomic,copy) NSString *photoNumber;

@property (nonatomic,assign) BOOL isRefreshDisVC;

- (void)getFriendHeadImage;

@end
