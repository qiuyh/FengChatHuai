//
//  QYHNewFriendViewController.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/7/12.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHNewFriendViewController.h"
#import "QYHNewFriendTableViewCell.h"
#import "QYHChatMssegeModel.h"
#import "QYHFMDBmanager.h"
#import "QYHDetailTableViewController.h"
#import "XMPPvCardTemp.h"
#import "QYHContenViewController.h"
#import "QYHContactModel.h"

@interface QYHNewFriendViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)  QYHContenViewController *chatVC;
@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@end

@implementation QYHNewFriendViewController


- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _dataArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _chatVC = [QYHContenViewController shareInstance];
    
    [self reloaDate:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloaDate:) name:KReceiveNewAddFriendNotification object:nil];
}


- (void)reloaDate:(NSNotification *)noti{
    
    
    
    NSLog(@"QYHNewFriendViewController--reloaDatereloaDate");
    
    if ([noti object]) {
        
        NSLog(@"noti.object==%@",noti.object);
        _friendDataArray = [noti object];
        
        [QYHAccount shareAccount].isNeedRefresh = YES;//传到历史记录聊天那刷新界面
    }
    
    [_dataArray removeAllObjects];
    
    for (id model in _friendDataArray) {
        if (![model isKindOfClass:[NSString class]]) {
            [_dataArray addObject:model];
        }
    }
    
    /**
     *  数组倒序
     */
    _dataArray = (NSMutableArray *)[[_dataArray reverseObjectEnumerator] allObjects];
    
    [self.myTableView reloadData];
    
    //更新已读状态
    [[QYHFMDBmanager shareInstance]updateIsAllReadAddFriendMessegeCompletion:^(BOOL result) {
        
     if (result) {
            NSLog(@"添加新朋友更新已读状态成功");
        }else{
            NSLog(@"添加新朋友更新已读状态失败");
        }
    }];

}

#pragma mark - uitableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QYHNewFriendTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYHNewFriendTableViewCell"];
    
    QYHChatMssegeModel *messegeModel = _dataArray[indexPath.row];
    
    [cell setDataForCell:messegeModel];
    
    
    /**
     *  判断是列表中的第几个好友
     */
    NSInteger index = 0;
    
    if (messegeModel.addStatus != AddAgreeded && messegeModel.addStatus != AddRejected) {
        
        for (QYHContactModel *user in [QYHChatDataStorage shareInstance].usersArray) {
            
            if ([messegeModel.fromUserID isEqualToString:user.jid.user]) {
                
                break;
            }
            
            index ++;
        }
    }
    
    /**
     *  按钮点击事件
     */
    
    __weak typeof (cell) weakcell = cell;
    __weak typeof (self) weakself = self;
    
    [cell setBlock:^(BOOL isAccepted){
        
        if (isAccepted) {
            
            if (messegeModel.addStatus != AddAgreeded && messegeModel.addStatus != AddRejected) {
                //点击接受事件
                [weakself acceptedAction:weakcell bymessegeModel:messegeModel indexPath:indexPath];
                
            }else{
                //已经同意后的（会话按钮事件）
               XMPPJID *jid = [XMPPJID jidWithUser:messegeModel.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
                
                [weakself pushToChat:weakcell.nameLabel.text byXMPPJID:jid index:index];
            }
        }
    }];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __block QYHChatMssegeModel *messegeModel = _dataArray[indexPath.row];
    
    /**
     *  提示对方同意或者拒绝的信息不能点击
     */
    if (messegeModel.addStatus != AddAgreeded && messegeModel.addStatus != AddRejected) {
        
        /**
         *  获取好友的信息
         */
        
//        XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
//        XMPPJID *byJID = [XMPPJID jidWithUser:messegeModel.fromUserID domain:myJid.domain resource:myJid.resource];
//        
//        XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
        
        XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:messegeModel.fromUserID];
        
        NSData   *imageUrl = vCard.photo ? vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
        NSString *nickName = vCard.nickname ?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *sex = vCard.formattedName ?[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *area = vCard.givenName ?[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *personalSignature = vCard.middleName ?[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *phone = messegeModel.fromUserID;
        
        /**
         *  跳转到详情
         */
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
        
        detailVC.dic = @{@"imageUrl":imageUrl,
                         @"nickName":nickName,
                         @"sex":sex,
                         @"area":area,
                         @"personalSignature":personalSignature,
                         @"phone":phone
                         };
//        detailVC.index      = 0;
        
        if (messegeModel.addStatus == AddFriendNormer) {
            detailVC.isAddFriendVC   = YES;
            detailVC.content  = [NSString stringWithFormat:@"%@: %@",[nickName isEqualToString:@""]? phone : nickName ,messegeModel.content];
            detailVC.mssegeModel = messegeModel;
            
        }else if (messegeModel.addStatus == AddFriendReject){
            detailVC.isAddFriendVC   = YES;
            detailVC.isReject = YES;
            detailVC.content  = [NSString stringWithFormat:@"%@: %@",[nickName isEqualToString:@""]? phone : nickName ,messegeModel.content];
            
        }else{
            
        }
        
        __weak typeof(self) weakself = self;
        
        [detailVC setMyBlock:^(QYHChatMssegeModel *model){
            messegeModel.addStatus = model.addStatus;
            NSLog(@"model.addStatus==%lu",(unsigned long)model.addStatus);
            [weakself.myTableView reloadData];
        }];
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
         [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else{
        
         [tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    return UITableViewCellEditingStyleDelete;
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath{
    return @"删除";
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle ==UITableViewCellEditingStyleDelete)
    {
         QYHChatMssegeModel *messegeModel = _dataArray[indexPath.row];
        
        __weak typeof(self) weakself = self;
        
        [[QYHFMDBmanager shareInstance]deleteAddFriendMessegeByMessegeID:messegeModel.messegeID completion:^(BOOL result) {
            if (result) {
                /**
                 *  传到信息聊天界面刷新数据
                 */
                [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:messegeModel];
                
                [weakself.dataArray removeObjectAtIndex:indexPath.row];  //删除数组里的数据
                [weakself.myTableView deleteRowsAtIndexPaths:[NSMutableArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
                
            }else{
                NSLog(@"删除新朋友失败");
            }
        }];
    }
}


- (void)pushToChat:(NSString *)name byXMPPJID:(XMPPJID *)jid index:(NSInteger)index{
    
    _chatVC.friendJid = jid;
    _chatVC.isRefresh = YES;
    _chatVC.title = name;
    
    __weak __typeof(self) weakSelf = self;
    [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.chatVC.allDataArray = [messagesArray mutableCopy];
            [weakSelf.navigationController pushViewController:weakSelf.chatVC animated:YES];
        });
        
    }];
}

#pragma mark - 点击接受按钮事件

- (void)acceptedAction:(QYHNewFriendTableViewCell *)cell bymessegeModel:(QYHChatMssegeModel *)messegeModel indexPath:(NSIndexPath *)indexPath{
    
    __weak typeof (self) weakself = self;
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        NSLog(@"未成功登陆");
        [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];

        return;
    }
    
    cell.acceptButton.hidden   = YES;
    cell.acceptedLabel.hidden  = NO;
    cell.acceptedLabel.text    = @"已添加";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    messegeModel.addStatus = AddFriendAgreed;
    

    [[QYHFMDBmanager shareInstance] updateAddFriendMessegeStatusByMessegeModel:messegeModel completion:^(BOOL result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                
                /**
                 *  刷新数据
                 */
                [weakself.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
          
                /**
                 *  接受加为好友
                 */
                XMPPJID *jid = [XMPPJID jidWithUser:messegeModel.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
                
                [[QYHXMPPTool sharedQYHXMPPTool].roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
                
                
                /**
                 *  获取好友的信息
                 */
                
//                XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
//                XMPPJID *byJID = [XMPPJID jidWithUser:messegeModel.fromUserID domain:myJid.domain resource:myJid.resource];
//                
//                XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
                
                XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:messegeModel.fromUserID];
                
                NSData   *imageUrl = vCard.photo ? vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
                NSString *nickName = vCard.nickname ?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
                NSString *sex = vCard.formattedName ?[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
                NSString *area = vCard.givenName ?[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
                NSString *personalSignature = vCard.middleName ?[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
                NSString *phone = jid.user;
                
                /**
                 *  跳转到详情
                 */
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
                
                detailVC.dic = @{@"imageUrl":imageUrl,
                                 @"nickName":nickName,
                                 @"sex":sex,
                                 @"area":area,
                                 @"personalSignature":personalSignature,
                                 @"phone":phone
                                 };
//                detailVC.index      = 0;
                //                detailVC.isFriend   = YES;
                //                detailVC.index      = indexPath.row;
                
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                     [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
                    
                    [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                    
                    [weakself sendMessage:jid content:@"我们可以开始聊天了！" status:AddAgreeded];
                    
                    [weakself.navigationController pushViewController:detailVC animated:YES];
                });
                
            }else{
                
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                NSLog(@"数据库更状态失败");
            }
        });
        
    }];
}

//发送信息
- (void)sendMessage:(XMPPJID *)jid content:(NSString *)content status:(AddFriendStatus)status
{
    
    NSDictionary *bodyDic;
    
    NSString *curentTime = [NSString formatCurDate];
    
    bodyDic = @{@"type":@(SendAddFriend),
                @"messegeID":[NSString acodeId],
                @"time":curentTime,
                @"isRead":@(NO),
                @"status":@(status),
                @"content":[[NSString stringWithFormat:@"%@",content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    
    
    //把bodyDic转换成data类型
    NSError *error = nil;
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"解析错误%@", [error localizedDescription]);
    }
    
    //把data转成字符串进行发送
    NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    //发聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:jid];
    [msg addBody:bodyString];
    
    [[QYHXMPPTool sharedQYHXMPPTool].xmppStream sendElement:msg];
}


-(void)dealloc{
     [[NSNotificationCenter defaultCenter]removeObserver:self name:KReceiveNewAddFriendNotification object:nil];
}

@end
