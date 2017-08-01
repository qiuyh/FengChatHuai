//
//  QYHVerificationViewController.h
//  SmartCommunity
//
//  Created by iMacQIU on 16/6/31.
//  Copyright © 2016年 Horizontal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHVerificationViewController : UIViewController

@property (nonatomic,copy) NSString *friendName;
@property (nonatomic,strong) XMPPJID *userJid;

@end
