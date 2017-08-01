//
//  QYHContenViewController.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QYHContenViewController : UIViewController

/**
 * 好友的jid
 */
@property(strong,nonatomic)XMPPJID *friendJid;

@property (nonatomic, strong) NSMutableArray *allDataArray;

@property (nonatomic,assign) BOOL isRefresh;

@property (nonatomic,assign) BOOL isTrans;//是否转发的

@property (nonatomic,strong) NSMutableDictionary *friendJidDic;//保存未发信息的草稿

+ (instancetype)shareInstance;

+ (void)attemptDealloc;

- (void) scrollToBottom;

-(void)keyboardwillHide:(UITapGestureRecognizer*)tap;

@end
