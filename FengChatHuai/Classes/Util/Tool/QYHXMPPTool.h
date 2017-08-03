//
//  QYHXMPPTool.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
#import "XMPPStreamManagementMemoryStorage.h"
#import "XMPPRosterMemoryStorage.h"
#import "XMPPAutoPing.h"

typedef enum {
    XMPPResultTypeLoginSucess,//登录成功
    XMPPResultTypeLoginFailure,//登录失败
    XMPPResultTypeRegisterSucess,//注册成功
    XMPPResultTypeRegisterFailure,//注册失败
    XMPPResultTypeServerFailure//服务器连接
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface QYHXMPPTool : NSObject

singleton_interface(QYHXMPPTool)

@property(strong,nonatomic,readonly)XMPPAutoPing *xmppAutoPing;
@property(strong,nonatomic,readonly)XMPPStream *xmppStream;//与服务器交互的核心类

@property(strong,nonatomic,readonly)XMPPvCardTempModule *vCard;//电子名片模块
@property(strong,nonatomic,readonly)XMPPvCardCoreDataStorage *vCardStorage;//电子名片数据存储

@property(strong,nonatomic,readonly)XMPPvCardAvatarModule *avatar;//电子名片的头像模块

@property(strong,nonatomic,readonly)XMPPRoster *roster;//花名册
@property(strong,nonatomic,readonly)XMPPRosterCoreDataStorage *rosterStorage;//花名册数据存储

@property(nonatomic,strong)XMPPStreamManagementMemoryStorage *storage;
@property(nonatomic,strong)XMPPStreamManagement *xmppStreamManagement;

@property(strong,nonatomic,readonly)XMPPMessageArchiving *msgArchiving;
@property(strong,nonatomic,readonly)XMPPMessageArchivingCoreDataStorage *msgArchivingStorage;

@property (nonatomic,assign) NSInteger count;

/**
 *  标识 连接服务器 到底是 "登录连接"还是 “注册连接”
 *  NO 代表登录操作
 *  YES 代表注册操作
 */
@property(assign,nonatomic,getter=isRegisterOperation)BOOL registerOperation;

/**
 *  XMPP用户登录
 */
-(void)xmppLogin:(XMPPResultBlock)resultBlock;

/**
 *  用户注册
 *
 */
-(void)xmppRegister:(XMPPResultBlock)resultBlock;
/**
 *  用户注销
 */
-(void)xmppLogout;



@end
