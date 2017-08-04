//
//  QYHAccount.h
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QYHAccount : NSObject


/**
 *  判断是否需要是同一账号在另外一个手机登陆
 */

@property(nonatomic,assign)BOOL isLogout;


/**
 *  判断是否需要更新未读信息条数
 */

@property(nonatomic,assign)BOOL isHasNetWorking;

/**
 *  判断是否是从登陆进入主界面的
 */

@property(nonatomic,assign,getter=isFromLogin)BOOL fromLogin;

/**
 *  判断是否需要更新未读信息条数
 */

@property(nonatomic,assign)BOOL isNeedRefresh;


/**
 *  登录的用户名
 */
@property(nonatomic,copy)NSString *loginUser;

/**
 *  登录的密码
 */
@property(nonatomic,copy)NSString *loginPwd;

/**
 *  xmpp登录的密码
 */
@property(nonatomic,copy)NSString *xmppLoginPwd;

/**
 *  判断用户是否登录
 */
@property(nonatomic,assign,getter=isLogin)BOOL login;

/**
 *  注册的用户
 */
@property(nonatomic,copy)NSString *registerUser;

/**
 *  注册的密码
 */
@property(nonatomic,copy)NSString *registerPwd;


+(instancetype)shareAccount;

/**
 *  保存最新的登录用户数据到沙盒
 */
-(void)saveToSandBox;

/**
 *  保存最新的服务器配置
 */
-(void)saveDomain:(NSString *)domain host:(NSString *)host;


/**
 *  服务器的域名
 */
@property(nonatomic,copy,readonly)NSString *domain;

/**
 *  服务器IP
 */
@property(nonatomic,copy,readonly)NSString *host;

@property(nonatomic,assign,readonly)int port;

@end
