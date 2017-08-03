//
//  QYHAccount.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHAccount.h"
#define kUserKey @"user"
#define kPwdKey @"pwd"
#define kXMPPPwdKey @"xmppPwd"
#define kLoginKey @"login"

//static NSString *domain = @"qiuyonghuai.local";//qiuyonghuai.local
//static NSString *host = @"192.168.1.101";//本地网络192.168.1.102

static NSString *domain = @"cluster.openfire";
static NSString *host = @"tt.hori-gz.com";//本地网络

//
//static NSString *domain = @"imacqiu.local";//qiuyonghuai.local
//static NSString *host = @"192.168.51.93";//本地网络192.168.51.93
////@"127.0.0.1";
static int port = 5222;

@implementation QYHAccount


+(instancetype)shareAccount{
    return [[self alloc] init];
}

#pragma mark 分配内存创建对象
+(instancetype)allocWithZone:(struct _NSZone *)zone{
    NSLog(@"%s",__func__);
    static QYHAccount *acount;
    
    // 为了线程安全
    // 三个线程同时调用这个方法
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //        if (acount == nil) {
        acount = [super allocWithZone:zone];
        
        //从沙盒获取上次的用户登录信息
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        acount.loginUser    = [defaults objectForKey:kUserKey];
        acount.loginPwd     = [defaults objectForKey:kPwdKey];
        acount.xmppLoginPwd = [defaults objectForKey:kXMPPPwdKey];
        acount.login        = [defaults boolForKey:kLoginKey];
        //        }
    });
    
    
    
    return acount;
    
}


-(void)saveToSandBox{
    
    // 保存user pwd login
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.loginUser forKey:kUserKey];
    [defaults setObject:self.loginPwd forKey:kPwdKey];
    [defaults setObject:self.xmppLoginPwd forKey:kXMPPPwdKey];
    [defaults setBool:self.isLogin forKey:kLoginKey];
    [defaults synchronize];
    
}


-(NSString *)domain{
    return domain;
}

-(NSString *)host{
    return host;
}

-(int)port{
    return port;
}


@end
