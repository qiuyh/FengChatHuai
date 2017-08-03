//
//  QYHAddTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/25.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHAddTableViewController.h"
#import "QYHKeyBoardManager.h"
#import "QYHVerificationViewController.h"
#import "QYHDetailTableViewController.h"
#import "XMPPvCardTemp.h"

@interface QYHAddTableViewController ()<UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inPutextField;

@end

@implementation QYHAddTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem.tintColor = [UIColor greenColor];
    self.title = @"添加好友";
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManager shareInstance].selfView = self.view;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [QYHKeyBoardManager shareInstance].selfView = nil;
}


- (IBAction)addAction:(id)sender {
    
    
    if ([QYHChatDataStorage shareInstance].usersArray.count>49) {
        [self showMsg:@"外接服务器不支持超过49个好友，请删除一些好友再添加！"];
        return;
    }
    //添加好友
    // 获取用户输入好友名称
//    NSString *user = [self.inPutextField.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    if (self.inPutextField.text.length < 1) {
        
        [self showMsg:@"该账号不存在！"];
        return;
    }
    
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [self showMsg:@"网络未连接！"];
        return;
    }
    
    XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
    XMPPJID *byJID = [XMPPJID jidWithUser:self.inPutextField.text  domain:myJid.domain resource:myJid.resource];
    
    XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
    
    if (!vCard) {
        vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:NO];
    }
    

    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
    
    NSData   *imageUrl = vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    NSString *nickName = vCard.nickname ?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *sex = vCard.formattedName ?[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *area = vCard.givenName ?[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *personalSignature = vCard.middleName ?[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *phone = self.inPutextField.text ;
    
    detailVC.dic = @{@"imageUrl":imageUrl,
                     @"nickName":nickName,
                     @"sex":sex,
                     @"area":area,
                     @"personalSignature":personalSignature,
                     @"phone":phone
                     };
//    detailVC.index      = 0;
    
    [self.navigationController pushViewController:detailVC animated:YES];

    
//    //1.不能添加自己为好友
//    if ([user isEqualToString:[QYHAccount shareAccount].loginUser]) {
//        [self showMsg:@"不能添加自己为好友"];
//        return;
//    }
//
//    //2.已经存在好友无需添加
//    XMPPJID *userJid = [XMPPJID jidWithUser:user domain:[QYHAccount shareAccount].domain resource:nil];
//    
//    XMPPUserCoreDataStorageObject *object = [[QYHXMPPTool sharedQYHXMPPTool].rosterStorage userForJID:userJid xmppStream:[QYHXMPPTool sharedQYHXMPPTool].xmppStream managedObjectContext:[QYHXMPPTool sharedQYHXMPPTool].rosterStorage.mainThreadManagedObjectContext];
////    BOOL userExists = [[QYHXMPPTool sharedQYHXMPPTool].rosterStorage userExistsWithJID:userJid xmppStream:[QYHXMPPTool sharedQYHXMPPTool].xmppStream];
//    
//    if (self.inPutextField.text.length < 1)
//    {
//        [self showMsg:@"用户名不能为空！"];
//        return;
//    }
//    
//    NSString *ojb  = [NSString stringWithFormat:@"%@",object];
//    
//    if (![ojb hasSuffix:@"data: <fault>)"] && object)
//    {
//        
//        [self showMsg:@"该好友已存在"];
//        return;
//    }
//    
//    //3.添加好友 (订阅)
////    [[QYHXMPPTool sharedQYHXMPPTool].roster addUser:userJid withNickname:user];
//    
//    /*添加好友在现有openfire存在的问题
//     1.添加不存在的好友，通讯录里面也现示了好友
//     解决办法1. 服务器可以拦截好友添加的请求，如当前数据库没有好友，不要返回信息
//     <presence type="subscribe" to="werqqrwe@teacher.local"><x xmlns="vcard-temp:x:update"><photo>b5448c463bc4ea8dae9e0fe65179e1d827c740d0</photo></x></presence>
//     
//     解决办法2.过滤数据库的Subscription字段查询请求
//     none 对方没有同意添加好友
//     to 发给对方的请求
//     from 别人发来的请求
//     both 双方互为好友
//     1901567800127
//     */
//    
//    QYHVerificationViewController *vc = [[QYHVerificationViewController alloc]initWithNibName:@"QYHVerificationViewController" bundle:nil];
//    vc.userJid = userJid;
//    vc.friendName = self.inPutextField.text;
//    [self.navigationController pushViewController:vc animated:YES];
}


-(void)showMsg:(NSString *)msg{
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    
    [av show];
}


@end
