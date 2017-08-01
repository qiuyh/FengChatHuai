//
//  QYHChatViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/20.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHChatViewController.h"
#import "QYHAddTableViewController.h"
#import "MGSwipeTableCell.h"
#import "QYHContenViewController.h"
#import "QYHFMDBmanager.h"
#import "QYHContactModel.h"
#import "QYHChatMssegeModel.h"
#import "XMPPvCardTemp.h"
#import "QYHNewFriendViewController.h"
#import "QYHChatViewCell.h"
#import "QYHContactsViewController.h"


@interface QYHChatViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIAlertViewDelegate>

{
    NSFetchedResultsController *_resultsContr;

    BOOL _isRes;
    
//    NSInteger _index;//判断第几section是新朋友
//    
//    BOOL _isHasNewFriend;
    
//    BOOL _isExecutiving;
}

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property(nonatomic,strong) QYHContenViewController *chatVC;

/**
 * 好友
 */
@property(strong,nonatomic) NSMutableArray *usersArray;
@property(nonatomic,strong) NSMutableArray *msgDataArray;
@property(nonatomic,strong) NSMutableArray *dataArray;
@property(nonatomic,strong) NSMutableArray *addFriendArray;

@property(nonatomic,strong) QYHChatMssegeModel *model;

@end

@implementation QYHChatViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        NSLog(@"QYHChatViewController--initWithCoder");
        
        _msgDataArray   = [NSMutableArray array];
        
        _dataArray      = [NSMutableArray array];
        
        _addFriendArray = [NSMutableArray array];
        
        _usersArray     = [NSMutableArray array];
        
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContentUser) name:KLoginSuccessNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllChatMessage) name:KReceiveChatMessageNotification object:nil];
        //            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getAllChatMessage) name:KRDelayedChatMessageNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getContentUser) name:KReceiveAddFriendNotification object:nil];
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if ([QYHAccount shareAccount].isNeedRefresh) {
        [QYHAccount shareAccount].isNeedRefresh = NO;
        
        [self getAllChatMessage];
        
//        [self queryAllUnread];
//        
//        [self.myTableView reloadData];
        
    }else{
        
        if (self.navigationController.tabBarItem.badgeValue) {
            [self.myTableView reloadData];
        }
    }
    
    if (self.isTrans) {
        
        UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                             initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                             target:self action:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            navigationSpacer.width = - 10.5;  // ios 7
            
        }else{
            navigationSpacer.width = - 6;  // ios 6
        }
        
        UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissAction)];
        
        
        self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
    }
    
}

- (void)dismissAction{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"QYHChatViewController--viewDidLoad");
    
     self.myTableView.rowHeight = 60.0f;
    
    if (self.isTrans) {
        self.myTableView.tableHeaderView = [self loadHearView];
        self.title = @"最近联系人";
        self.navigationItem.rightBarButtonItem = nil;
    }
     self.myTableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 20)];
    
    //首先实例化聊天界面
    _chatVC = [QYHContenViewController shareInstance];
    
    
    [self getunArchiver];
    
    [self loadUsers2];
    
    [self getAllChatMessage];
    
    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [self getContentUser];
        
    }
    
}

/**
 *  tabbleviewHearView
 *
 *
 */
- (UIView *)loadHearView{
    
    UIView *hearView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 95)];
    hearView.backgroundColor = [UIColor whiteColor];
    
    UIView *spaceView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
    spaceView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(spaceView.frame), SCREEN_WIDTH, 1)];
    lineView1.backgroundColor = [UIColor colorWithHexString:@"DADADA"];
    
    UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 55, 200, 21)];
    nameLabel.text = @"创建新的聊天";
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 36, SCREEN_WIDTH, 60);
    button.backgroundColor = [UIColor clearColor];
    button.alpha = 0.3;
    
    [button addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(hearView.frame)-1, SCREEN_WIDTH, 1)];
    lineView2.backgroundColor = [UIColor colorWithHexString:@"DADADA"];
    
    [hearView addSubview:spaceView];
    [hearView addSubview:button];
    [hearView addSubview:lineView1];
    [hearView addSubview:nameLabel];
    [hearView addSubview:lineView2];
    
    return hearView;
}


- (void)didSelectButton:(UIButton *)button{
    
    button.backgroundColor = [UIColor lightGrayColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        button.backgroundColor = [UIColor clearColor];
    });

    QYHContactsViewController *contactsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHContactsViewController"];
    contactsVC.isTrans = YES;
    [self.navigationController pushViewController:contactsVC animated:YES];
}

- (void)getContentUser{
    
    if (_resultsContr.fetchedObjects.count) {
        
        [self ChangeContent];
        
    }else{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSInteger count = 0;
            while (!_resultsContr.fetchedObjects.count) {
                
                count ++;
                if (count==10000) {
                    break;
                }
            }
            
            NSLog(@"count=======%lu",count);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self ChangeContent];
                
            });
            
        });
        
    }

}


//从归档里获取数据
- (void)getunArchiver
{
    // 1.得到data
    
    NSString *path=[NSString stringWithFormat:@"%@%@",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    // 2.创建反归档对象
    
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    
    // 3.解码并存到数组中
    
    NSArray *userArray  = [unArchiver decodeObjectForKey:[QYHAccount shareAccount].loginUser];
    
    _usersArray = [NSMutableArray arrayWithArray:userArray];
    
    
    [QYHChatDataStorage shareInstance].usersArray = [_usersArray mutableCopy];
    
    [[QYHChatDataStorage shareInstance].userDic removeAllObjects];
    for (QYHContactModel *model in _usersArray) {
         [[QYHChatDataStorage shareInstance].userDic setObject:model forKey:model.jid.user];
    }
   
//    if (_usersArray.count) {
//        [self.myTableView reloadData];
//    }
    
}
-(void)loadUsers2{
    //显示好友数据 （保存XMPPRoster.sqlite文件）
    
    //1.上下文 关联XMPPRoster.sqlite文件
    NSManagedObjectContext *rosterContext = [QYHXMPPTool sharedQYHXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2.Request 请求查询哪张表
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    request.sortDescriptors = @[sort];
    
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    request.predicate = pre;
    
    //3.执行请求
    //3.1创建结果控制器
    // 数据库查询，如果数据很多，会放在子线程查询
    // 移动客户端的数据库里数据不会很多，所以很多数据库的查询操作都主线程
    _resultsContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsContr.delegate = self;
    NSError *err = nil;
    //3.2执行
   [_resultsContr performFetch:&err];
    
    NSLog(@"_resultsContr==%@",_resultsContr.fetchedObjects);
    
}

- (void)ChangeContent
{
    
    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [QYHXMPPvCardTemp shareInstance].vCard = [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
        
        [[QYHXMPPvCardTemp shareInstance] setVCard:[QYHXMPPvCardTemp shareInstance] byUser:nil];
        
        [_usersArray removeAllObjects];
    }
    
    
    [[QYHChatDataStorage shareInstance].userDic removeAllObjects];
     
    for (XMPPUserCoreDataStorageObject *user in _resultsContr.fetchedObjects) {
        
        NSLog(@"user.jid==%@",user.jid);

        NSString *jid = [NSString stringWithFormat:@"%@",user.jid];
        
        if ([jid hasSuffix:[QYHAccount shareAccount].domain]) {
            
            
            XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
            XMPPJID *byJID = [XMPPJID jidWithUser:user.jid.user domain:myJid.domain resource:myJid.resource];
            
            XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
            
            //归档
            [QYHXMPPvCardTemp shareInstance].vCard = vCard;
            
            [[QYHXMPPvCardTemp shareInstance] setVCard:[QYHXMPPvCardTemp shareInstance] byUser:user.jid.user];
            
//            NSLog(@"myvCard==%@,,jid==%@,,1==%@,,%@,%@,%@,%@,%@,%@,%@,user.photo==%@",vCard,byJID,[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.familyName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.prefix stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[vCard.suffix stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],vCard.photo,user.photo);
            
            
            QYHContactModel *model = [[QYHContactModel alloc]init];
            
            model.vCard       = vCard;
            model.jid         = user.jid;
            model.nickname    = user.nickname;
            model.displayName = vCard.nickname ? vCard.nickname : user.jid.user;
            model.photo       = [UIImage imageWithData:vCard.photo];
            model.sectionNum  = user.sectionNum;
            
            [_usersArray addObject:model];
            
            [[QYHChatDataStorage shareInstance].userDic setObject:model forKey:model.jid.user];
        }
        
    }
    

    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        // 1.创建可变的data对象，装数据
        
        NSMutableData *data = [NSMutableData data];
        
        // 2.创建归档对象
        
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        
        // 3.把对象编码
        
        [archiver encodeObject:_usersArray forKey:[QYHAccount shareAccount].loginUser];
        
        // 4.编码完成
        
        [archiver finishEncoding];
        
        // 5.保存归档
        
        //取到沙盒路径
        NSString *path=[NSString stringWithFormat:@"%@%@",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
        
        [data writeToFile:path atomically:YES];
        
        
//        if (!_resultsContr.fetchedObjects.count) {
//            
//            [QYHChatDataStorage shareInstance].usersArray   = [self.usersArray mutableCopy];
//            
//            /**
//             *  传到联系人界面刷新数据
//             */
//            [[NSNotificationCenter defaultCenter]postNotificationName:KContentChangeNotification object:nil];
//        }
        
    }
    
    
    [self getAllChatMessage];
}


//获取全部的聊天信息
- (void)getAllChatMessage
{
    
     [QYHChatDataStorage shareInstance].usersArray   = [self.usersArray mutableCopy];
    
    /**
     *  传到联系人界面刷新数据
     */
    [[NSNotificationCenter defaultCenter]postNotificationName:KContentChangeNotification object:nil];
    
    [self queryAllUnread];
    
    NSLog(@"getAllChatMessage");
    
    
    __weak __typeof(self) weakSelf = self;
    [[QYHFMDBmanager shareInstance] queryAllMessegeByUserArray:_usersArray completion:^(NSArray *addFriendArray, NSArray *messagesArray) {
        
        [weakSelf.addFriendArray removeAllObjects];
        [weakSelf.msgDataArray removeAllObjects];
        
        /**
         *  获取新朋友信息
         */
        if (!self.isTrans) {
            
            NSMutableArray *array = [addFriendArray mutableCopy];
            
            if (addFriendArray.count){
                weakSelf.addFriendArray = array;
                NSLog(@"addFriendArray==%@",array);
                [weakSelf.msgDataArray addObject:weakSelf.addFriendArray];
                
            }else{
                
                NSLog(@"getAllChatMessage11-获取消息失败");
            }
        }
        
        //        NSLog(@"weakSelf.msgDataArray111==%@",weakSelf.msgDataArray);
        
        /**
         *  获取聊天信息记录
         */
        NSMutableArray *array1 = [messagesArray mutableCopy];
        
        if (messagesArray.count) {
            
            for (NSArray *arr in array1) {
                if (arr.count) {
                    [weakSelf.msgDataArray addObject:arr];
                }
            }
            
        }else{
            
            NSLog(@"getAllChatMessage22-获取消息失败");
        }
        
        
//         NSLog(@"weakSelf.msgDataArray11122==%@",weakSelf.msgDataArray);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf sortTimeByDes];
        });
    }];
    
//    /**
//     *  获取新朋友信息
//     */
//    __weak __typeof(self) weakSelf = self;
//    [[QYHFMDBmanager shareInstance] queryAllAddFriendMessegeCompletion:^(NSArray *messagesArray, BOOL result) {
//        
//        [weakSelf.addFriendArray removeAllObjects];
//        [weakSelf.msgDataArray removeAllObjects];
//        
//        NSMutableArray *array = [messagesArray mutableCopy];
//        
//        if (messagesArray.count){
//            weakSelf.addFriendArray = array;
//            NSLog(@"array==%@",array);
//            [weakSelf.msgDataArray addObject:weakSelf.addFriendArray];
//            
//        }else{
//            
//            NSLog(@"getAllChatMessage11-获取消息失败");
//        }
//        
//        
//        if (!weakSelf.usersArray.count) {
//            /**
//             *  传到联系人界面刷新数据
//             */
//            [[NSNotificationCenter defaultCenter]postNotificationName:KContentChangeNotification object:nil];
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf sortTimeByDes];
//            });
//            
//        }
//        
//        /**
//         *  获取聊天信息
//         */
//        
//        
//        __block NSInteger count = 0;
//        for (QYHContactModel *user in weakSelf.usersArray) {
//            
//            __weak __typeof(self) weakSelf = self;
//            [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:user.jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
//                
//                NSMutableArray *array = [messagesArray mutableCopy];
//                
//                 count ++;
//                
//                if (messagesArray.count) {
//                   
//                    [weakSelf.msgDataArray addObject:array];
//                    
//                }else{
//                
//                    NSLog(@"getAllChatMessage22-获取消息失败");
//                }
//               
//                
//                if (count == weakSelf.usersArray.count) {
//                    
//                    [QYHChatDataStorage shareInstance].usersArray   = [weakSelf.usersArray mutableCopy];
//                    
//                    /**
//                     *  传到联系人界面刷新数据
//                     */
//                    [[NSNotificationCenter defaultCenter]postNotificationName:KContentChangeNotification object:nil];
//                    
//                    if (weakSelf.msgDataArray.count) {
//                        
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [weakSelf sortTimeByDes];
//                        });
//                        
//                    }
//                }
//                
//            }];
//            
//        }
//        
//    }];
    
}


/**
 *  时间排序，按照时间先后顺序显示
 *
 *
 */

- (void)sortTimeByDes{
    
    [_dataArray removeAllObjects];
    
    for (NSArray *arr in _msgDataArray) {
        
         NSLog(@"lastObject==%@",[arr lastObject]);
        
        [_dataArray addObject:[arr lastObject]];

    }
    
    NSLog(@"_dataArray==%@",_dataArray);
    
    if (_dataArray.count >1) {
        NSArray *dateStringArray = [_dataArray mutableCopy];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        
        _dataArray = [NSMutableArray arrayWithArray:[dateStringArray sortedArrayUsingComparator:^NSComparisonResult(QYHChatMssegeModel *messegeModel1, QYHChatMssegeModel *messegeModel2) {
            
            NSDate *date1 = [dateFormatter dateFromString:messegeModel1.time];
            NSDate *date2 = [dateFormatter dateFromString:messegeModel2.time];
            
            return [date2 compare:date1];
        }]];
        
//        if (_messageArray.count >1) {
//            
//            NSMutableArray *messageModelArray = [NSMutableArray array];
//            
//            for (id obj in _messageArray) {
//                
//                if (![obj isKindOfClass:[NSString class]]) {
//                    [messageModelArray addObject:obj];
//                }
//                
//            }
//            
//            NSArray *messageArray = [messageModelArray mutableCopy];
//            
//            _messageArray = [NSMutableArray arrayWithArray:[messageArray sortedArrayUsingComparator:^NSComparisonResult(NSArray *arr1, NSArray *arr2) {
//                
//                QYHChatMssegeModel *messegeModel1 = [arr1 lastObject];
//                QYHChatMssegeModel *messegeModel2 = [arr2 lastObject];
//                
//                NSDate *date1 = [dateFormatter dateFromString:messegeModel1.time];
//                NSDate *date2 = [dateFormatter dateFromString:messegeModel2.time];
//                
//                return [date2 compare:date1];
//            }]];
//            
//        }
    }
    
    NSLog(@"myTableView reloadData");
    
    
//    _isExecutiving = NO;
    
    if (self.addFriendArray.count) {
        /**
         *  传到添加朋友信息界面刷新数据
         */
        [[NSNotificationCenter defaultCenter]postNotificationName:KReceiveNewAddFriendNotification object:self.addFriendArray];
    }
    
    [self.myTableView reloadData];
    
}

//获取全部未读信息
- (void)queryAllUnread{
    
    __weak __typeof(self) weakSelf = self;
    [[QYHFMDBmanager shareInstance] queryAllUnReadCompletion:^(NSInteger count, BOOL result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (count) {
                
                if (count>99) {
                    weakSelf.navigationController.tabBarItem.badgeValue = @"99+";
                }else{
                    weakSelf.navigationController.tabBarItem.badgeValue = [NSString stringWithFormat:@"%lu",count];
                }
                
            }else{
                weakSelf.navigationController.tabBarItem.badgeValue = nil;
            }
        });
        
    }];
}


#pragma mark -结果控制器的代理
#pragma mark -数据库内容改变
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    NSLog(@"currentThread%@",[NSThread currentThread]);
    
    [self getContentUser];
}


- (IBAction)addFriendAction:(id)sender {
    
    QYHAddTableViewController *addVC  =[self.storyboard instantiateViewControllerWithIdentifier:@"QYHAddTableViewController"];
    [self.navigationController pushViewController:addVC animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
//    _isHasNewFriend  = NO;
//    
//    _index = 0;
    
    return  _dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return  1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *reuseIdentifier = @"QYHChatViewCell";
    
    QYHChatViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    
    if (!cell) {
        cell = [[QYHChatViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    }
    
    
    [self configDateIndexPath:indexPath cell:cell];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    QYHChatMssegeModel *model = _dataArray[indexPath.row + indexPath.section];
    
    QYHChatViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (self.isTrans) {
        
        _model = model;
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"确定发送给：" message:cell.titleLabel1.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alerView show];
        
        return;
    }
    
    
    if (!cell.redLabel.hidden) {
        [QYHAccount shareAccount].isNeedRefresh = YES;//传到历史记录聊天那刷新界面
    }
    
    
    if (model.type != SendText&&model.type != SendImage&&model.type != SendVoice) {
        /**
         *  申请添加好友界面
         */
        
        QYHNewFriendViewController *newFriendVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHNewFriendViewController"];
        
        newFriendVC.friendDataArray = [_addFriendArray mutableCopy];
        
        [self.navigationController pushViewController:newFriendVC animated:YES];
        
        NSLog(@"跳到处理申请加为好友界面");
    }else{
        /**
         *  聊天界面
         */
        
        XMPPJID *jid = [XMPPJID jidWithUser:[model.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]?model.toUserID:model.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
        _chatVC.friendJid = jid;
        _chatVC.isRefresh = YES;
        _chatVC.title = cell.titleLabel1.text;
        
        __weak __typeof(self) weakSelf = self;
        [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"messagesArray==%ld",messagesArray.count);
                weakSelf.chatVC.allDataArray = [messagesArray mutableCopy];
                [weakSelf.navigationController pushViewController:weakSelf.chatVC animated:YES];
            });
            
        }];
    }
    
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    if (section == 0)
    {
        if (self.isTrans) {
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 100, 21)];
            label.text = @"  最近聊天";
            label.textColor = [UIColor grayColor];
            label.font = [UIFont systemFontOfSize:15];
            
            return label;
        }
    }
    
    return nil;
}

- (void)configDateIndexPath:(NSIndexPath *)indexPath cell:(QYHChatViewCell *)cell
{
    QYHChatMssegeModel *model = _dataArray[indexPath.row + indexPath.section];

    NSString *content = nil;
    
    switch (model.type) {
        case SendText:
            content = model.content;
            break;
        case SendImage:
            content = @"[图片]";
            break;
        case SendVoice:
            content = @"[语音]";
            break;
        default:
            content = model.content;
            break;
    }
    
    cell.detailLabel1.text = content;
    if (model.type == SendVoice && !model.isReadVioce) {
        
        NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:content];
        
        [AttributedStr addAttribute:NSForegroundColorAttributeName
         
                              value:[UIColor colorWithRed:185.0/255 green:10.0/255 blue:0.0/255 alpha:1.0]
         
                              range:NSMakeRange(0, 4)];
        
        cell.detailLabel1.attributedText = AttributedStr;
    }

    cell.timeLabel.text    = [NSString getMessageDateStringFromdateString:model.time andNeedTime:NO];
    
    if (model.type != SendText&&model.type != SendImage&&model.type != SendVoice) {
        
        if (!self.isTrans) {
            cell.rightButtons = [self createRightButtons:1 indexPath:indexPath];
            cell.rightSwipeSettings.transition = MGSwipeStateSwippingRightToLeft;
            
            cell.imgView1.image    = [UIImage imageNamed:@"plugins_FriendNotify"];
            cell.titleLabel1.text  = @"新朋友";
            
            //        XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
            //        XMPPJID *byJID = [XMPPJID jidWithUser:model.fromUserID domain:myJid.domain resource:myJid.resource];
            //
            //        XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:YES];
            
            XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:model.fromUserID];
            
            NSString *contentSting;
            switch (model.addStatus) {
                case AddAgreeded:
                    contentSting = @"已同意您添加为好友";
                    break;
                case AddRejected:
                    contentSting = @"已拒绝您添加为好友";
                    break;
                default:
                    contentSting = @"请求添加为好友";
                    break;
            }
            cell.detailLabel1.text = [NSString stringWithFormat:@"%@ %@",vCard.nickname?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:model.fromUserID,contentSting];
            
            //获取未读的信息条数
            __weak __typeof(cell) weakCell = cell;
            __weak __typeof(self) weakself = self;
            [[QYHFMDBmanager shareInstance]queryAllUnReadAddFriendMessegeCompletion:^(NSInteger count, BOOL result) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (count) {
                        
                        weakCell.redLabel.hidden = NO;
                        
                        if (count>99) {
                            weakCell.redLabel.text   = @"99+";
                        }else{
                            
                            weakCell.redLabel.text   = [NSString stringWithFormat:@"%lu",count];
                        }
                        
                        [weakself startShake:weakCell.redLabel];
                        
                    }else{
                        weakCell.redLabel.hidden = YES;
                        weakCell.redLabel.text   = [NSString stringWithFormat:@"%lu",count];
                        [weakself stopShake:weakCell.redLabel];
                    }
                    
                    
                    weakCell.redLabelWithConstraint.constant = ([NSString getContentSize:weakCell.redLabel.text fontOfSize:13 maxSizeMake:CGSizeMake(35, 20)].width + 8 )> 18 ?[NSString getContentSize:weakCell.redLabel.text fontOfSize:13 maxSizeMake:CGSizeMake(35, 15)].width + 5:18;
                    weakCell.redLabel.layer.cornerRadius = weakCell.redLabel.frame.size.height/2.0;
                    weakCell.redLabel.clipsToBounds = YES;
                });
                
            }];
        }
        
    }else{
        
        if (!self.isTrans) {
            cell.rightButtons = [self createRightButtons:2 indexPath:indexPath];
            cell.rightSwipeSettings.transition = MGSwipeStateSwippingRightToLeft;
        }
        
        for (QYHContactModel *user in _usersArray) {
            if ([user.jid.user isEqualToString:[model.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]?model.toUserID:model.fromUserID]) {
                
                NSLog(@"user.nickname==%@,user.vCard.nickname==%@,user.displayName==%@",user.nickname,user.vCard.nickname,user.displayName);
                
                
                /**
                 *  通过保存的字典里获取对应好友是否有草稿
                 */
                if ([_chatVC.friendJidDic objectForKey:user.jid.user]) {

                    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"[草稿] %@",[_chatVC.friendJidDic objectForKey:user.jid.user]]];
                    
                    [AttributedStr addAttribute:NSForegroundColorAttributeName
                     
                                          value:[UIColor colorWithRed:185.0/255 green:10.0/255 blue:0.0/255 alpha:1.0]
                     
                                          range:NSMakeRange(0, 4)];
                    
                    cell.detailLabel1.attributedText = AttributedStr;
                }
                
                
                cell.titleLabel1.text  = user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [user.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                
                //显示好友的头像
                if (user.photo) {//默认的情况，不是程序一启动就有头像
                    cell.imgView1.image = user.photo ;
                }else{
                    //从服务器获取头像
                    NSData *imgData = [[QYHXMPPTool sharedQYHXMPPTool].avatar photoDataForJID:user.jid];
                    cell.imgView1.image = [UIImage imageWithData:imgData] ? [UIImage imageWithData:imgData]: [UIImage imageNamed:@"placeholder"];
                }
                
                if (!self.isTrans) {
                    //获取未读的信息条数
                    __weak __typeof(cell) weakCell = cell;
                    __weak __typeof(self) weakself = self;
                    [[QYHFMDBmanager shareInstance]queryAllUnReadChatMessegeByFromUserID:user.jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSInteger count, BOOL result) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (count) {
                                weakCell.redLabel.hidden = NO;
                                
                                if (count>99) {
                                    weakCell.redLabel.text   = @"99+";
                                }else{
                                    
                                    weakCell.redLabel.text   = [NSString stringWithFormat:@"%lu",count];
                                }
                                
                                [weakself startShake:weakCell.redLabel];
                                
                            }else{
                                weakCell.redLabel.hidden = YES;
                                weakCell.redLabel.text   = [NSString stringWithFormat:@"%lu",count];
                                [weakself stopShake:weakCell.redLabel];
                            }
                            
                            
                            weakCell.redLabelWithConstraint.constant = ([NSString getContentSize:weakCell.redLabel.text fontOfSize:13 maxSizeMake:CGSizeMake(35, 15)].width + 8) > 18 ?[NSString getContentSize:weakCell.redLabel.text fontOfSize:13 maxSizeMake:CGSizeMake(35, 15)].width + 5:18;
                            weakCell.redLabel.layer.cornerRadius = weakCell.redLabel.frame.size.height/2.0;
                            weakCell.redLabel.clipsToBounds = YES;
                            
                        });
                    }];
                }
                
            }
        }
    }
}

//抖动动画
- (void)startShake:(UILabel *)redLabel
{
    // 设定为缩放
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    
    // 动画选项设定
    animation.duration = 2.0f; // 动画持续时间
    animation.repeatCount = MAXFLOAT; // 重复次数
    animation.autoreverses = YES; // 动画结束时执行逆动画
    
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1.0]; // 开始时的倍率
    animation.toValue   = [NSNumber numberWithFloat:1.5]; // 结束时的倍率
    
    // 添加动画
    [redLabel.layer addAnimation:animation forKey:@"scale-layer"];
    
//    CAKeyframeAnimation *rotationAni = [CAKeyframeAnimation animation];
//    
//    rotationAni.keyPath = @"transform.rotation.z";
//    
//    CGFloat angle = M_PI_4*2;
//    
//    rotationAni.values = @[@(-angle),@(angle),@(-angle)];
//    
//    rotationAni.repeatCount = MAXFLOAT;
//    
//    rotationAni.duration = 1.5;
//    
//    [redLabel.layer addAnimation:rotationAni forKey:@"shake"];
}

//移除抖动动画
- (void)stopShake:(UILabel *)redLabel
{
    
    [redLabel.layer removeAnimationForKey:@"scale-layer"];

    
//    [redLabel.layer removeAnimationForKey:@"shake"];
}


/**
 *  创建右滑按钮
 *
 *
 */
-(NSArray *) createRightButtons: (int) number indexPath:(NSIndexPath *)indexPath
{
    QYHChatMssegeModel *model = _dataArray[indexPath.row + indexPath.section];
    NSString *title2 = model.isRead ? @"标为未读":@"标为已读";
    
    NSMutableArray * result = [NSMutableArray array];
    NSString* titles[2] = {@"删除", title2};
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
                    [selfWeak updateIsReadOrNoReadByIndexPath:indexPath messageModel:model];
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
 *  标为未读或者标为已读
 *
 *
 */
- (void)updateIsReadOrNoReadByIndexPath:(NSIndexPath *)indexPath messageModel:(QYHChatMssegeModel *)messageModel
{
    if (messageModel.isRead) {
        
        //标为未读
        [[QYHFMDBmanager shareInstance]updateLastNoReadMessegeByMessegeModel:messageModel completion:^(BOOL result) {
            if (result) {
                NSLog(@"标为未读状态成功");
            }else{
                NSLog(@"标为未读状态失败");
            }
            
            [self getAllChatMessage];
        }];

        
    }else{
        //标为已读
        [[QYHFMDBmanager shareInstance]updateIsAllReadMessegeByFromUserID:messageModel.fromUserID completion:^(BOOL result) {
            if (result) {
                NSLog(@"标为已读状态成功");
            }else{
                NSLog(@"标为已读状态失败");
            }
            
            [self getAllChatMessage];
        }];
 
    }
}

/**
 *  删除聊天记录
 *
 *
 */
- (void)deleteUserByIndexPath:(NSIndexPath *)indexPath
{
    QYHChatMssegeModel *messegeModel = _dataArray[indexPath.section];
    
    if (messegeModel.type != SendText&&messegeModel.type != SendImage&&messegeModel.type != SendVoice) {
        
        __weak typeof(self) weakself = self;
        
        [[QYHFMDBmanager shareInstance]deleteAllAddFriendMessegeCompletion:^(BOOL result) {
            if (result) {

                [weakself.dataArray removeObjectAtIndex:indexPath.section];  //删除数组里的数据
                [weakself.myTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
                
                /**
                 *  传到信息聊天界面刷新数据
                 */
                [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:messegeModel];
                
            }else{
                NSLog(@"删除新朋友信息失败");
            }
        }];
        
    }else{
        
        __weak typeof(self) weakself = self;
        
        [[QYHFMDBmanager shareInstance]deleteChatMessegeByFromUserID:[messegeModel.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]? messegeModel.toUserID:messegeModel.fromUserID completion:^(BOOL result) {
            if (result) {
                
                [weakself.dataArray removeObjectAtIndex:indexPath.section];  //删除数组里的数据
                [weakself.myTableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];  //删除对应数据的cell
                
                /**
                 *  传到信息聊天界面刷新数据
                 */
                [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:messegeModel];
                
            }else{
                NSLog(@"删除好友信息失败");
            }
        }];
    }
    
}

#pragma mark - alerViewDelagete

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        
        self.isTrans = NO;
        
       __block QYHContenViewController *contentVC = _chatVC;
        /**
         *  聊天界面
         */
        
        XMPPJID *jid = [XMPPJID jidWithUser:[_model.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]?_model.toUserID:_model.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
        contentVC.friendJid = jid;
        contentVC.isRefresh = YES;
        contentVC.title = alertView.message;
        contentVC.isTrans = YES;
        
        __weak __typeof(self) weakSelf = self;
        [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:jid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSLog(@"messagesArray==%ld",messagesArray.count);
                contentVC.allDataArray = [messagesArray mutableCopy];
//                 [weakSelf.navigationController popToViewController:contentVC animated:YES];
                [weakSelf dismissViewControllerAnimated:YES completion:^{
                    
                }];
            });
            
        }];
    }
}


-(void)dealloc{
    
    NSLog(@"QYHChatViewController--dealloc");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KReceiveChatMessageNotification object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:KRDelayedChatMessageNotification object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:KReceiveAddFriendNotification object:nil];
//    
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:KLoginSuccessNotification object:nil];
    
}


@end
