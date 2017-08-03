//
//  QYHXMPPTool.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHXMPPTool.h"
#import "QYHFMDBmanager.h"
#import "QYHChatMssegeModel.h"
#import "QYHQiNiuRequestManarger.h"
#import "QYHChatDataStorage.h"
#import <AudioToolbox/AudioToolbox.h>

////枚举Cell类型
//typedef enum : NSUInteger {
//    SendText,
//    SendImage,
//    SendVoice
//    
//} MySendContentType;
//
//
//typedef enum : NSUInteger {
//    HImageType,
//    VImageType
//    
//} imageType;

/* 用户登录流程
 1.初始化XMPPStream
 
 2.连接服务器(传一个jid)
 
 3.连接成功，接着发送密码
 
 // 默认登录成功是不在线的
 4.发送一个 "在线消息" 给服务器 ->可以通知其它用户你上线
 */
@interface QYHXMPPTool ()<XMPPStreamDelegate,XMPPReconnectDelegate,XMPPRosterDelegate,XMPPStreamManagementDelegate,XMPPAutoPingDelegate>{
    XMPPReconnect *_reconnect;//自动连接模块,由于网络问题，与服务器断开时，它会自己连接服务器
    
    XMPPResultBlock _resultBlock;//结果回调Block
}
/**
 *  1.初始化XMPPStream
 */
-(void)setupStream;

/**
 *  释放资源
 */
-(void)teardownStream;

/**
 *  2.连接服务器(传一个jid)
 */
-(void)connectToHost;

/**
 *  3.连接成功，接着发送密码
 */
-(void)sendPwdToHost;

/**
 *  4.发送一个 "在线消息" 给服务器
 */
-(void)sendOnline;

/**
 *  发送 “离线” 消息
 */
-(void)sendOffline;

/**
 *  与服务器断开连接
 */
-(void)disconncetFromHost;
@end

@implementation QYHXMPPTool

singleton_implementation(QYHXMPPTool)

#pragma mark -私有方法
-(void)setupStream{
    
    _count = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillTerminate) name:UIApplicationWillTerminateNotification object:nil];
    
    // 创建XMPPStream对象
    _xmppStream = [[XMPPStream alloc] init];
    
    
    // 添加XMPP模块
    // 1.添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    // 激活
    [_vCard activate:_xmppStream];
    
    // 电子名片模块还会配置 "头像模块" 一起使用
    // 2.添加 头像模块
    _avatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_avatar activate:_xmppStream];
    
    
    // 3.添加 "花名册" 模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    
    // 4.添加 "消息" 模块
    _msgArchivingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgArchivingStorage];
    [_msgArchiving activate:_xmppStream];
    
    // 5.添加 “自动连接” 模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect setAutoReconnect:YES];
    [_reconnect activate:_xmppStream];
    
    //接入流管理模块
    _storage = [XMPPStreamManagementMemoryStorage new];
    _xmppStreamManagement = [[XMPPStreamManagement alloc] initWithStorage:_storage];
    _xmppStreamManagement.autoResume = YES;
    [_xmppStreamManagement addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppStreamManagement activate:self.xmppStream];

    
    //初始化并启动ping
    [self autoPingProxyServer:nil];
    
    
    //允许后台模式(注意ios模拟器上是不支持后台socket的)
    _xmppStream.enableBackgroundingOnSocket = YES;
    
    // 设置代理 -
    //#warnning 所有的代理方法都将在子线程被调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_reconnect  addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    [_roster     addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}

-(void)teardownStream{
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_avatar deactivate];
    [_vCard deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    [_reconnect deactivate];
    
    
    //断开连接
    [_xmppStream disconnect];
    
    //清空资源
    _reconnect = nil;
    _msgArchiving = nil;
    _msgArchivingStorage = nil;
    _roster = nil;
    _rosterStorage = nil;
    _vCardStorage = nil;
    _vCard = nil;
    _avatar = nil;
    _xmppStream = nil;
    
    
    //卸载监听
    [_xmppAutoPing deactivate];
    [_xmppAutoPing removeDelegate:self];
    _xmppAutoPing = nil;

}

-(void)connectToHost{
    
    if (!_xmppStream) {
        [self setupStream];
    }
    // 1.设置登录用户的jid
    XMPPJID *myJid = nil;
    // resource 用户登录客户端设备登录的类型
    
    /*
     if(注册请求){
     //设置注册的JID
     }else{
     //设置登录JID
     }*/
    QYHAccount *account = [QYHAccount shareAccount];
    if (self.isRegisterOperation) {//注册
        NSString *registerUser = account.registerUser;
        myJid = [XMPPJID jidWithUser:registerUser domain:account.domain resource:nil];
    }else{//登录操作
        NSString *loginUser = [QYHAccount shareAccount].loginUser;
        myJid = [XMPPJID jidWithUser:loginUser domain:account.domain resource:nil];
    }
  
    _xmppStream.myJID = myJid;
    
    // 2.设置主机地址
    _xmppStream.hostName = account.host;
    
    // 3.设置主机端口号 (默认就是5222，可以不用设置)
    _xmppStream.hostPort = account.port;
    
    _xmppStream.enableBackgroundingOnSocket = YES;
    // 4.发起连接
    NSError *error = nil;
    // 缺少必要的参数时就会发起连接失败 ? 没有设置jid
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        NSLog(@"%@",error);
    }else{
        NSLog(@"发起连接成功");
    }
    
}


-(void)sendPwdToHost{
    NSError *error = nil;
    NSString *pwd = [QYHAccount shareAccount].loginPwd;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        NSLog(@"%@",error);
    }
}


-(void)sendOnline{
    //XMPP框架，已经把所有的指令封闭成对象
    XMPPPresence *presence = [XMPPPresence presence];
    NSLog(@"%@",presence);
    [_xmppStream sendElement:presence];

}


-(void)sendOffline{
    XMPPPresence *offline = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offline];
}

-(void)disconncetFromHost{
    [_xmppStream disconnect];
}
#pragma mark -XMPPStream的代理
#pragma mark 连接建立成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender{
    NSLog(@"连接建立成功");
    if (self.isRegisterOperation) {//注册
        NSError *error = nil;
        NSString *reigsterPwd = [QYHAccount shareAccount].registerPwd;
        [_xmppStream registerWithPassword:reigsterPwd error:&error];
        if (error) {
            NSLog(@"%@",error);
        }
    }else{//登录
        [self sendPwdToHost];
    }
    
}

//初始化并启动ping
-(void)autoPingProxyServer:(NSString*)strProxyServer
{
    _xmppAutoPing = [[XMPPAutoPing alloc] init];
    [_xmppAutoPing activate:_xmppStream];
    [_xmppAutoPing addDelegate:self delegateQueue:dispatch_get_main_queue()];
    _xmppAutoPing.respondsToQueries = YES;
    _xmppAutoPing.pingInterval = 30;//ping 间隔时间
    if (nil != strProxyServer)
    {
        _xmppAutoPing.targetJID = [XMPPJID jidWithString: strProxyServer ];//设置ping目标服务器，如果为nil,则监听socketstream当前连接上的那个服务器
    }
}


#pragma mark XMPPAutoPingDelegate的委托方法:

//- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender
//{
//    NSLog(@"- (void)xmppAutoPingDidSendPing:(XMPPAutoPing *)sender");
//}
//- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender
//{
//    NSLog(@"- (void)xmppAutoPingDidReceivePong:(XMPPAutoPing *)sender");
//}
//
//- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender
//{
//    NSLog(@"- (void)xmppAutoPingDidTimeout:(XMPPAutoPing *)sender");
//}

#pragma mark 与服务器断开连接
-(void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    
    [QYHAccount shareAccount].isLogout = NO;
    
//    if (_resultBlock) {
//        _resultBlock(XMPPResultTypeServerFailure);
//        _resultBlock = nil;
//    }
    
    NSLog(@"与服务器断开连接%@",error);
}
#pragma mark 登录成功
-(void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    //NSLog(@"%s",__func__);
    NSLog(@"登录成功");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [QYHAccount shareAccount].isLogout = YES;
        _count = 0;
    });
    
    [self sendOnline];
    
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSucess);
        
        _resultBlock = nil;
    }
    
    
    //启用流管理
    [_xmppStreamManagement enableStreamManagementWithResumption:YES maxTimeout:0];
}

//重连机制的代理方法

-(BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkConnectionFlags)connectionFlags{
    
    // NSLog(@"开始尝试自动连接:%u", connectionFlags);
    
    return YES;
    
}

-(void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkConnectionFlags)connectionFlags{
    
    // NSLog(@"检测到意外断开连接:%u",connectionFlags);
    
}



#pragma mark 登录失败
-(void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    NSLog(@"登录失败%@",error);
    //回调resultBlock
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginFailure);
        _resultBlock = nil;
    }
}

#pragma mark 注册成功
-(void)xmppStreamDidRegister:(XMPPStream *)sender{
    NSLog(@"注册成功");
    //CZLog
    //    NSLog(@"abc");
    
    
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSucess);
        _resultBlock = nil;
    }
}

#pragma mark 注册失败
-(void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    NSLog(@"注册失败 %@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
        _resultBlock = nil;
    }
    
}

#pragma mark -公共方法
#pragma mark 用户登录
-(void)xmppLogin:(XMPPResultBlock)resultBlock{
    // 不管什么情况，把以前的连接断开
    [_xmppStream disconnect];
    
    // 保存resultBlock
    _resultBlock = resultBlock;
    
    
    // 连接服务器开始登录的操作
    [self connectToHost];
    
}


#pragma mark 用户注册
-(void)xmppRegister:(XMPPResultBlock)resultBlock{
    /* 注册步骤
     1.发送 "注册jid" 给服务器，请求一个长连接
     2.连接成功，发送注册密码
     */
    //保存block
    _resultBlock = resultBlock;
    
    // 去除以前的连接
    [_xmppStream disconnect];
    
    [self connectToHost];
    
    
}

#pragma mark 用户注销
-(void)xmppLogout{
    // 1.发送 "离线消息" 给服务器
    [self sendOffline];
    // 2.断开与服务器的连接
    [self disconncetFromHost];
    // [_xmppStream disconnect];
    //XMPPStream
}

#pragma mark 处理加好友回调,加好友
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    //请求的用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"presenceType:%@,presenceFromUser:%@",presenceType,presenceFromUser);
    
    NSLog(@"presence2:%@  sender2:%@",presence,sender);
    
}

#pragma mark 收到好友上下线状态
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    //    DDLogVerbose(@"%@: %@ ^^^ %@", THIS_FILE, THIS_METHOD, [presence fromStr]);
    
    //取得好友状态
    NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline、unsubscribe
    //当前用户
    //    NSString *userId = [NSString stringWithFormat:@"%@", [[sender myJID] user]];
    //在线用户
    NSString *presenceFromUser =[NSString stringWithFormat:@"%@", [[presence from] user]];
    NSLog(@"presenceType:%@",presenceType);
    NSLog(@"用户:%@",presenceFromUser);
    
    
    if ([presenceType isEqualToString:@"available"]) {
        
        if ([presenceFromUser isEqualToString:[QYHAccount shareAccount].loginUser]) {
            
            _count ++;
            
            if (_count == 2) {
                _count = 0;
                
                if ([QYHAccount shareAccount].isLogout) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter]postNotificationName:KReceiveErrorConflictNotification object:nil];
                        
                        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                                            message:@"您的账号已在其它手机登录"
                                                                           delegate:nil
                                                                  cancelButtonTitle:@"确认"
                                                                  otherButtonTitles:nil];
                        [alertView show];
                        
                    });
                    
                }
            }
        }
    }
    
    
    //收到对方定阅我的消息
//    if ([presence.type isEqualToString:@"subscribe"]) {
//        
//        QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
//        
//        //添加好友的信息
//        
//        messegeModel.messegeID   = [NSString acodeId];
//        messegeModel.fromUserID  = [presenceFromUser stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//        messegeModel.toUserID    = [QYHAccount shareAccount].loginUser;
//        messegeModel.content     = @"我是...";
//        messegeModel.time        = [NSString formatCurDate];
//        messegeModel.type        = 5;
//        messegeModel.addStatus   = AddFriendNormer;
//        messegeModel.isRead      = NO;
//        
//        [self inserNewFriendNoti:messegeModel];
//    }
    
    //收到对方取消定阅我的消息
    if ([presence.type isEqualToString:@"unsubscribe"]) {
        //从我的本地通讯录中将他移除
        
        if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
            //删除好友
            [[QYHXMPPTool sharedQYHXMPPTool].roster removeUser:presence.from];
            
            __weak typeof(self) weakself = self;
            
            [[QYHFMDBmanager shareInstance]deleteChatMessegeByFromUserID:presence.from.user completion:^(BOOL result) {
                
                if (result) {
                    
                    [[QYHFMDBmanager shareInstance]deleteAddFriendMessegeByFromUserID:presence.from.user completion:^(BOOL result) {
                        
                        if (result) {
                            
                            dispatch_async(dispatch_get_main_queue(), ^{
                                
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    
                                    /**
                                     *  传到信息聊天界面刷新数据
                                     */

                                    [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
                                });
                                
                            });
                            
                        }else{
                            NSLog(@"删除对应的新朋友信息失败");
                        }
                        
                    }];
                    
                }else{
                    NSLog(@"删除好友失败");
                }
            }];
            
        }else{
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
        }
    }

}

#pragma mark-接收到信息

-(void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{

    NSLog(@"didReceiveMessage==%@",message);
    
    if ([message isMessageWithBody])
    {
        
        NSString * bodyStr = [message elementForName:@"body"].stringValue;
        NSData  * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
        
        MySendContentType type = [dic[@"type"] integerValue];
        
        QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
        
        //添加好友的信息
        if (type == SendAddFriend) {
            
            messegeModel.messegeID   = dic[@"messegeID"];
            messegeModel.fromUserID  = [[message from] user];
            messegeModel.toUserID    = [[message to] user];
            messegeModel.content     = [dic[@"content"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            messegeModel.time        = dic[@"time"];
            messegeModel.type        = [dic[@"type"] integerValue];
            messegeModel.addStatus   = [dic[@"status"] integerValue];
            messegeModel.isRead      = [dic[@"isRead"] boolValue];
            
            [self inserNewFriendNoti:messegeModel];
            
            //朋友圈更新信息
        }else if(type == SendNewCircle){
            
        }else{
            
            messegeModel.messegeID   = dic[@"messegeID"];
            messegeModel.fromUserID  = [[message from] user];
            messegeModel.toUserID    = [[message to] user];
            messegeModel.content     = [dic[@"content"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            messegeModel.time        = dic[@"time"];
            messegeModel.type        = [dic[@"type"] integerValue];
            messegeModel.status      = [dic[@"status"] integerValue];
            messegeModel.audioTime   = [dic[@"audioTime"] integerValue];
            messegeModel.imageType   = [dic[@"imageType"] integerValue];
            messegeModel.ratioHW     = [dic[@"ratioHW"] floatValue];
            messegeModel.isRead      = [dic[@"isRead"] boolValue];
            messegeModel.isReadVioce = [dic[@"isReadVioce"] boolValue];
            
            
            __weak typeof (self) weak_self = self;
            
            [[QYHFMDBmanager shareInstance] insertChatMessege:messegeModel completion:^(BOOL result) {
                
                if (!result) {
                    NSLog(@"ChatMssege插入数据失败");
                }else{
                    //是语音的话就能下载好再推送，不是就直接推
                    if (messegeModel.type == SendVoice) {
                        [weak_self downloadVoice:messegeModel.content messegeModel:messegeModel];
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveChatMessageNotification object:messegeModel];
                            
                            [weak_self presentLocalNotice:@"您收到一条消息"];
                        });
                        
                    }
                    
                }
                
            }];
        }
    }
}


- (void)inserNewFriendNoti:(QYHChatMssegeModel *)messegeModel{
    
    __weak typeof (self) weak_self = self;
    
    [[QYHFMDBmanager shareInstance]deleteAddFriendMessegeByFromUserID:messegeModel.fromUserID  completion:^(BOOL result) {
        
        if (!result) {
            NSLog(@"AddFriend删除数据失败");
        }else{
            
            [[QYHFMDBmanager shareInstance] insertAddFriendMessege:messegeModel completion:^(BOOL result) {
                
                if (!result) {
                    NSLog(@"AddFriend插入数据失败");
                }else{
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveChatMessageNotification object:messegeModel];
                        
                        [weak_self presentLocalNotice:@"您收到一条消息"];
                    });
                }
                
            }];
        }
    }];

}


- (void)presentLocalNotice:(NSString *)notice
{
    
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.userInfo = @{@"alert": notice,
                                   @"badge": @"1"
                                   };
    
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = notice;
        
        [UIApplication sharedApplication].applicationIconBadgeNumber += 1;
        localNotification.fireDate = [NSDate date];
        
    }else{
        //防止多次震动
        [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(playShake) object:nil];
        [self performSelector:@selector(playShake) withObject:nil afterDelay:0.1f];
      
    }
    
   
    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
    
}


- (void)playShake{
    
    //系统震动
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

- (void)downloadVoice:(NSString *)voiceURL messegeModel:(QYHChatMssegeModel *)messegeModel
{

    __weak typeof (self) weak_self = self;
    
    [[QYHQiNiuRequestManarger shareInstance]getDataFromeQiNiuByfile:messegeModel.content Success:^(id responseObject) {
        
        NSData *data = responseObject;
        
        NSString *fileName = [NSString stringWithFormat:@"%ld.aac", (long)[[NSDate date] timeIntervalSince1970]];
        NSString *path     =[NSString stringWithFormat:@"%@%@",[QYHChatDataStorage shareInstance].homePath,fileName];
        
        [data writeToFile:path atomically:YES];

        messegeModel.content = fileName;
        
        [[QYHFMDBmanager shareInstance] updateMessegeContentByMessegeModel:messegeModel completion:^(BOOL result) {
            if (result) {
                
                NSLog(@"下载语音,更换数据库路径成功");
                
                [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveChatMessageNotification object:messegeModel];
                
                [weak_self presentLocalNotice:@"您收到一条消息"];
            }else{
                NSLog(@"下载语音，更换数据库路径失败");
            }
        }];
        
    } failure:^(NSError *error) {
        NSLog(@"下载语音失败");
    }];
    
}


#pragma mark -- terminate
/**
 *  申请后台时间来清理下线的任务
 */
-(void)applicationWillTerminate
{
    UIApplication *app=[UIApplication sharedApplication];
    UIBackgroundTaskIdentifier taskId;
    
    taskId=[app beginBackgroundTaskWithExpirationHandler:^(void){
        [app endBackgroundTask:taskId];
    }];
    
    if(taskId==UIBackgroundTaskInvalid){
        return;
    }
    
    //只能在主线层执行
    [_xmppStream disconnectAfterSending];
}


- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error{
    NSLog(@"didFailToSendIQ");
}


- (void)xmppStream:(XMPPStream *)sender didReceiveError:(DDXMLElement *)error{
    
    NSLog(@"error==%@",error);
    
    NSArray *elements = [error elementsForName:@"conflict"];
    if (elements.count) {
        
        [[NSNotificationCenter defaultCenter]postNotificationName:KReceiveErrorConflictNotification object:nil];
        
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"温馨提示"
                                                            message:@"您的账号已在其它手机登录"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确认"
                                                  otherButtonTitles:nil];
        [alertView show];
    }
}

-(void)dealloc{
    [self teardownStream];
}


@end
