//
//  QYHContactsViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/20.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHContactsViewController.h"
#import "QYHAddTableViewController.h"
#import "MGSwipeTableCell.h"
#import "QYHContenViewController.h"
#import "QYHFMDBmanager.h"
#import "QYHContactModel.h"
#import "QYHDetailTableViewController.h"
#import "QYHContactsCell.h"

@interface QYHContactsViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

{
    NSFetchedResultsController *_resultsContr;
    
    QYHContactModel *_nickNameUser;
    QYHContactModel *_deletUser;
    NSIndexPath     *_deletIndex;
    
    QYHContenViewController *_chatVC;
    
    BOOL _isVisibleViewController;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

/**
 * 好友
 */
@property(strong,nonatomic)NSMutableArray *usersArray;

//@property(strong,nonatomic)NSMutableArray *messageArray;

@property(nonatomic,strong) QYHContactModel *model;

@end

@implementation QYHContactsViewController



- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {

//        _messageArray = [NSMutableArray array];
        
        _usersArray   = [NSMutableArray array];
    
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContentChange) name:KContentChangeNotification object:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isTrans) {
        
        UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                             target:self action:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            navigationSpacer.width = - 10.5;  // ios 7
            
        }else{
            navigationSpacer.width = - 6;  // ios 6
        }
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popVCAction)];
        
        
        self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
    }
    
}

- (void)popVCAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)getContentChange{
    
//    if (_isVisibleViewController) {
        NSLog(@"内容数据发生改变——联系人界面打印");
        
        _usersArray   = [QYHChatDataStorage shareInstance].usersArray;
//        _messageArray = [QYHChatDataStorage shareInstance].messageArray;
        
        [self.myTableView reloadData];
//    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    _isVisibleViewController = YES;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isVisibleViewController = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTableView.rowHeight = 60.0f;
    
    if (!self.isTrans) {
        self.myTableView.tableHeaderView = [self loadHearView];
        
    }else{
        self.navigationItem.rightBarButtonItem = nil;
        self.title = @"联系人";
    }
    
    self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    
    _chatVC = [QYHContenViewController shareInstance];
    
    _usersArray   = [QYHChatDataStorage shareInstance].usersArray;
    //        _messageArray = [QYHChatDataStorage shareInstance].messageArray;
    
    [self.myTableView reloadData];
}

/**
 *  tabbleviewHearView
 *
 *
 */
- (UIView *)loadHearView{
    
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 218)];
    hearView.backgroundColor = [UIColor whiteColor];
    
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    spaceView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(spaceView.frame), SCREEN_WIDTH, 0.35)];
    lineView1.backgroundColor = [UIColor colorWithHexString:@"DADADA"];

    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(hearView.frame)-0.35, SCREEN_WIDTH, 0.35)];
    lineView2.backgroundColor = [UIColor colorWithHexString:@"DADADA"];

    [hearView addSubview:spaceView];
    [hearView addSubview:lineView1];
    [hearView addSubview:lineView2];
    
    NSArray *imageArray = @[@"add_friend_icon_addgroup",@"Contact_icon_ContactTag",@"add_friend_icon_offical"];
    NSArray *nameArray  = @[@"群聊",@"标签",@"公众号"];
    
    for (int i = 0; i<3; i++) {
     
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(18, 45+61*i, 40, 40)];
        imgView.image = [UIImage imageNamed:imageArray[i]];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(imgView.frame)+15, 10, 200, 21)];
        nameLabel.text = nameArray[i];
        nameLabel.centerY = imgView.centerY;
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(18, CGRectGetMaxY(imgView.frame)+10, SCREEN_WIDTH, 0.35)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"DADADA"];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 60);
        button.backgroundColor = [UIColor clearColor];
        button.centerY = imgView.centerY;
        button.alpha = 0.3;
        button.tag = 100+i;
        
        [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [hearView addSubview:button];
        [hearView addSubview:imgView];
        [hearView addSubview:nameLabel];
        
        if (i < 2) {
            [hearView addSubview:lineView];
        }
        
    }
    
    return hearView;
}

- (void)didSelectButton:(UIButton *)button{
    
    button.backgroundColor = [UIColor lightGrayColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.backgroundColor = [UIColor clearColor];
    });
    
    [[[UIAlertView alloc]initWithTitle:@"未实现 ！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
    
    switch (button.tag -100) {
        case 0:
            NSLog(@"群聊");
            break;
        case 1:
            NSLog(@"标签");
            break;
        case 2:
            NSLog(@"公众号");
            break;
        default:
            break;
    }
}


- (IBAction)addFriendAction:(id)sender {
    
    QYHAddTableViewController *addVC  =[self.storyboard instantiateViewControllerWithIdentifier:@"QYHAddTableViewController"];
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return  _usersArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"QYHContactsCell";
    
    QYHContactsCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];

    if (!cell) {
        cell = [[QYHContactsCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    //获取对应的好友
    
    [self configDateIndexPath:indexPath tableCell:cell];
    
    
    if (!self.isTrans) {
        cell.rightButtons = [self createRightButtons:2 indexPath:indexPath];
        cell.rightSwipeSettings.transition = MGSwipeStateSwippingRightToLeft;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QYHContactModel *model = _usersArray[indexPath.section + indexPath.row];
    
    if (self.isTrans) {
        
        QYHContactsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        if (self.isTrans) {
            
            _model = model;
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"确定发送给：" message:cell.titleLabel.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
            alerView.tag = 102;
            [alerView show];
            
            return;
        }
        
    }else{
        
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
        
        NSData   *imageUrl = model.vCard.photo ?model.vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
        NSString *nickName = model.vCard.nickname ?[model.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *sex = model.vCard.formattedName ?[model.vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *area = model.vCard.givenName ?[model.vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *personalSignature = model.vCard.middleName ?[model.vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
        NSString *phone = model.jid.user;
        
        detailVC.dic = @{@"imageUrl":imageUrl,
                         @"nickName":nickName,
                         @"sex":sex,
                         @"area":area,
                         @"personalSignature":personalSignature,
                         @"phone":phone
                         };
        
        detailVC.isFriend   = YES;
        //    detailVC.index      = indexPath.section + indexPath.row;
        detailVC.remarkName = model.nickname ?[model.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:nil;
        
        [self.navigationController pushViewController:detailVC animated:YES];
        
    }
//     XMPPJID *friendJid = [_usersArray[indexPath.section + indexPath.row] jid];
//    _chatVC.friendJid = friendJid;
//    _chatVC.isRefresh = YES;
//    
//    if ([self.messageArray[indexPath.section + indexPath.row] isKindOfClass:[NSString class]]) {
//        _chatVC.allDataArray = nil;
//    }else{
//        _chatVC.allDataArray = self.messageArray[indexPath.section + indexPath.row];
//    }
//    
//    
//    [self.navigationController pushViewController:_chatVC animated:YES];
   
        
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
         return 35;
    }
    return 5.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.0001;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{

    if (alertView.tag == 100)
    {
        
        if (buttonIndex == 1)
        {
            UITextField *nickNameTextField = [alertView textFieldAtIndex:0];
            
            if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
                
                if (nickNameTextField.text.length > 10) {
                    [QYHProgressHUD showErrorHUD:nil message:@"备注不能超过10个字符"];
                    return;
                }
                
                [[QYHXMPPTool sharedQYHXMPPTool].roster setNickname:
                 [nickNameTextField.text.length>0? nickNameTextField.text:nickNameTextField.placeholder stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forUser:_nickNameUser.jid];
                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
//                });
                
            }else{
                [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
                [self.myTableView reloadData];
            }
        }else
        {
            [self.myTableView reloadData];
        }
        
    }else if(alertView.tag == 101)
    {
        if (buttonIndex == 1)
        {
            if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
                
                [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                
                
                __weak typeof(self) weakself = self;
                
                [[QYHFMDBmanager shareInstance]deleteChatMessegeByFromUserID:_deletUser.jid.user completion:^(BOOL result) {
                    
                    if (result) {
                        
                        [[QYHFMDBmanager shareInstance]deleteAddFriendMessegeByFromUserID:_deletUser.jid.user completion:^(BOOL result) {
                            
                            if (result) {
                                
                                [self sendDeleteMessage:_deletUser.jid];
                                //删除好友
                                [[QYHXMPPTool sharedQYHXMPPTool].roster removeUser:_deletUser.jid];
                                
                                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                                
//                                [weakself.usersArray removeObjectAtIndex:_deletIndex.section];  //删除数组里的数据
//                                [weakself.myTableView deleteSections:[NSIndexSet indexSetWithIndex:_deletIndex.section] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
//                                
                                
//                                dispatch_async(dispatch_get_main_queue(), ^{
//                                    
//                                    
//                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                                        
//                                        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//                                        
//                                        [weakself.usersArray removeObjectAtIndex:_deletIndex.section];  //删除数组里的数据
//                                        [weakself.myTableView deleteSections:[NSIndexSet indexSetWithIndex:_deletIndex.section] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
//                                        
//                                        [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
//                                        
//                                    });
//                                });
                                
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
                [self.myTableView reloadData];
            }
            
        }else
        {
            [self.myTableView reloadData];
        }
        
    }else if (alertView.tag == 102){
        
        if (buttonIndex == 1) {
            
            self.isTrans = NO;
            
            __block QYHContenViewController *contentVC = _chatVC;
            /**
             *  聊天界面
             */
            contentVC.friendJid = _model.jid;
            contentVC.isRefresh = YES;
            contentVC.title = alertView.message;
            contentVC.isTrans = YES;
            
            __weak __typeof(self) weakSelf = self;
            [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:_model.jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    NSLog(@"messagesArray==%ld",messagesArray.count);
                    contentVC.allDataArray = [messagesArray mutableCopy];
//                    [weakSelf.navigationController popToViewController:contentVC animated:YES];
                    [weakSelf dismissViewControllerAnimated:YES completion:^{
                        
                    }];
                });
                
            }];
        }
        
    }
    
}


//发送信息
- (void)sendDeleteMessage:(XMPPJID *)jid
{
    NSDictionary *bodyDic = @{@"type":@(SendDeleteFrien)};
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



/**
 *  创建右滑按钮
 *
 *
 */
-(NSArray *) createRightButtons: (int) number indexPath:(NSIndexPath *)indexPath
{
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"删除", @"备注"};
    UIColor * colors[2] = {[UIColor redColor], [UIColor lightGrayColor]};
    
    __weak typeof(self) selfWeak = self;
    
    for (int i = 0; i < number; ++i)
    {
        MGSwipeButton * button = [MGSwipeButton buttonWithTitle:titles[i] backgroundColor:colors[i] callback:^BOOL(MGSwipeTableCell * sender){
            switch (i)
            {
                case 0:
                    [selfWeak deleteUserByIndexPath:indexPath];
                    break;
                    
                default:
                    [selfWeak updateNickNameByIndexPath:indexPath];
                    break;
            }
            
//            BOOL autoHide = i != 0;
            return NO;
        }];
        [result addObject:button];
    }
    return result;
}
/**
 *  修改备注
 *
 *
 */
- (void)updateNickNameByIndexPath:(NSIndexPath *)indexPath
{
     QYHContactModel *user =_usersArray[indexPath.row + indexPath.section];
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"修改备注" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.tag = 100;
    
    UITextField *nickNameTextField = [alertView textFieldAtIndex:0];
    nickNameTextField.placeholder  = user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : @"";
    _nickNameUser = user;
    
    
    [alertView show];
}

/**
 *  删除好友
 *
 *
 */
- (void)deleteUserByIndexPath:(NSIndexPath *)indexPath
{
    QYHContactModel *user = _usersArray[indexPath.row + indexPath.section];
    _deletUser  = user;
    _deletIndex = indexPath;
    
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"删除好友" message:@"您确定删除该好友，同时会将我从对方的列表中移除，且屏蔽对方的临时会话，不再接收此人的消息？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
 
    alertView.tag = 101;

    [alertView show];
}

/**
 *  展示好友
 *
 *
 */
- (void)configDateIndexPath:(NSIndexPath *)indexPath tableCell:(QYHContactsCell *)cell
{
     QYHContactModel *user = _usersArray[indexPath.row + indexPath.section];
    
    //标识用户是否在线
    // 0:在线 1：离开 2：离线
    NSLog(@"%@：在线状态%@",user.displayName,[user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]);
    
    NSRange range = [user.displayName rangeOfString:@"@"];
    
    NSString *displayName;
    
    if (range.location == NSNotFound)
    {
        displayName = user.displayName;
        
    }else
    {
        displayName = [user.displayName substringToIndex:range.location];
    }
    
    
    
    cell.titleLabel.text = [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : displayName;
    
    
//    switch ([user.sectionNum integerValue])
//    {
//        case 0:
//            cell.detailLabel.text = @"在线";
//            break;
//        case 1:
//            cell.detailLabel.text = @"离开";
//            break;
//        case 2:
//            cell.detailLabel.text = @"离线";
//            break;
//        default:
//            cell.detailLabel.text = @"不知道";
//            break;
//    }
    
    cell.detailLabel.text = @"";
    
    //显示好友的头像
    if (user.photo) {//默认的情况，不是程序一启动就有头像
        cell.imgView.image = user.photo ;
    }else{
        //从服务器获取头像
        NSData *imgData = [[QYHXMPPTool sharedQYHXMPPTool].avatar photoDataForJID:user.jid];
        cell.imgView.image = [UIImage imageWithData:imgData] ? [UIImage imageWithData:imgData]: [UIImage imageNamed:@"placeholder"];
    }
    
}


-(void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KContentChangeNotification object:nil];
}


@end
