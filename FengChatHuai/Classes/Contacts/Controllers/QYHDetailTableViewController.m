//
//  QYHDetailTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/5.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHDetailTableViewController.h"
#import "UIImageView+WebCache.h"
#import "QYHSetNickNameTableViewController.h"
#import "QYHContactModel.h"
#import "MWPhotoBrowser.h"
#import "QYHVerificationViewController.h"
#import "QYHContenViewController.h"
#import "QYHFMDBmanager.h"
#import "QYHOtherInformationViewController.h"

@interface QYHDetailTableViewController ()<UIAlertViewDelegate,MWPhotoBrowserDelegate>

{
    NSString *_nickName;
    
}

@property (strong, nonatomic) QYHContenViewController *chatVC;
@property (strong, nonatomic) IBOutlet UITableView *myTableView;

@property (weak, nonatomic) IBOutlet UIImageView *headImgView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;


@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;

@property (weak, nonatomic) IBOutlet UIImageView *sexImgView;

@property (weak, nonatomic) IBOutlet UILabel *areaLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nickNameLabelWithConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *imageView1;

@property (weak, nonatomic) IBOutlet UIImageView *imageView2;

@property (weak, nonatomic) IBOutlet UIImageView *imageView3;

@property (weak, nonatomic) IBOutlet UILabel *singelLabel;

@property (weak, nonatomic) IBOutlet UITextView *contentTextViwe;

@property (nonatomic, strong) NSMutableArray *photosArray;

@property (nonatomic,copy) NSString *phoneNumber;

//@property(strong,nonatomic)NSMutableArray *messageArray;

@property(strong,nonatomic)UIButton *addAendButton;
@property(strong,nonatomic)UIButton *videoButton;

@end

@implementation QYHDetailTableViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
//        _messageArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _chatVC = [QYHContenViewController shareInstance];
    
//    _messageArray = [QYHChatDataStorage shareInstance].messageArray;
    
    UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:nil action:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        navigationSpacer.width = - 10.5;  // ios 7
        
    }else{
        navigationSpacer.width = - 6;  // ios 6
    }
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popAction)];
    
    
    self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
    
    [self laySubViews];
    [self getThreePhotos];
    
}

- (void)popAction{
    
    if (_isFromSC) {
        [self.navigationController popToViewController:self.navigationController.viewControllers[0] animated:YES];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)laySubViews{
    
    /**
     *  解析字典
     */
    
    _nickName = [_dic objectForKey:@"nickName"];
    NSString *sex      = [_dic objectForKey:@"sex"];
    NSString *area     = [_dic objectForKey:@"area"];
    NSString *phone    = [_dic objectForKey:@"phone"];
    NSString *personalSignature = [_dic objectForKey:@"personalSignature"];
    
    _phoneNumber = phone;
    _headImgView.layer.cornerRadius = 5;
    _headImgView.clipsToBounds = YES;
    
    /**
     *  如果是扫一扫进入的界面就用网络请求图片，否则。。。
     */
    
    if ([[_dic objectForKey:@"imageUrl"] isKindOfClass:[NSString class]]) {
        NSString *imageUrl = [_dic objectForKey:@"imageUrl"];
        [_headImgView sd_setImageWithURL:[NSURL URLWithString:imageUrl]];
    }else{
        NSData *imageUrl = [_dic objectForKey:@"imageUrl"];
        _headImgView.image = [UIImage imageWithData:imageUrl];
    }
    
    
    /**
     *  判断扫扫过来的是否也已经加为好友，如果是，。。。
     */
    
    if (!_isFriend) {
        
        QYHContactModel *user = [[QYHChatDataStorage shareInstance].userDic objectForKey:phone];
        if (user) {
            
            _remarkName = user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]:nil;
            _isFriend = YES;
        }
    }
//        for (QYHContactModel *user in [QYHChatDataStorage shareInstance].usersArray) {
//            
//            if ([phone isEqualToString:user.jid.user]) {
//                
//                _remarkName = user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding ]:nil;
//                _isFriend = YES;
//                break;
//            }
//            
////            _index ++;
//        }
//        
//    }
    
    /**
     *  判断是否是自己
     */
    if ([phone isEqualToString:[QYHAccount shareAccount].loginUser]) {
        _remarkName = nil;
         _isFriend = NO;
    }

    
    
    _nickNameLabelWithConstraint.constant = [NSString getContentSize: _remarkName ? _remarkName:![_nickName isEqualToString:@""] ?_nickName:phone fontOfSize:20 maxSizeMake:CGSizeMake(200, 21)].width;
    
    _nickNameLabel.hidden   = _remarkName ? NO : YES;
    _contentTextViwe.hidden = _content    ? NO : YES;
    
    _nameLabel.text     = _remarkName ? _remarkName : ![_nickName isEqualToString:@""] ?_nickName:phone;
    _nickNameLabel.text = [@"昵称：" stringByAppendingString:_nickName];
    _phoneLabel.text    = [NSString stringWithFormat:@"手机号: %@",phone];
    _numberLabel.text   = phone;
    _areaLabel.text     = area;
    _singelLabel.text   = personalSignature;

    _contentTextViwe.text = _content;
    
//    /**
//     *  展示个人相册
//     */
//    NSString *path1 = [NSString stringWithFormat:@"%@%@headImage1.jpeg",[QYHChatDataStorage shareInstance].homePath,phone];
//    NSString *path2 = [NSString stringWithFormat:@"%@%@headImage2.jpeg",[QYHChatDataStorage shareInstance].homePath,phone];
//    NSString *path3 = [NSString stringWithFormat:@"%@%@headImage3.jpeg",[QYHChatDataStorage shareInstance].homePath,phone];
//    
//    _imageView1.image = [UIImage imageWithContentsOfFile:path1];
//    _imageView2.image = [UIImage imageWithContentsOfFile:path2];
//    _imageView3.image = [UIImage imageWithContentsOfFile:path3];
    
    if ([sex isEqualToString:@""]) {
        _sexImgView.image = [UIImage imageNamed:@"noSex"];
    }else{
        _sexImgView.image = [UIImage imageNamed:[sex isEqualToString:@"男"]? @"man" : @"woman"];
    }
    /**
     点击放大头像
     */
    
    UITapGestureRecognizer *tapGest = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigImage)];
    _headImgView.userInteractionEnabled = YES;
    [_headImgView addGestureRecognizer:tapGest];
    
    
    /**
     *  判断是否是自己
     */
    if (![phone isEqualToString:[QYHAccount shareAccount].loginUser]) {
        /**
         *  添加FootView
         */

        [self addFootView];
    }

}

-(void)getThreePhotos{
    
     NSString *fileName = @"personalThreePhotos.json";
     __weak typeof(self) weakself = self;
    
    [[QYHQiNiuRequestManarger shareInstance]getFile:fileName withphotoNumber:_phoneNumber Success:^(id responseObject) {
        NSLog(@"获取个人三张图片信息成功-responseObject==%@",responseObject);
//        http://7xt8p0.com2.z0.glb.qiniucdn.com/15817188551personalThreePhotos.json
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSArray *array = [responseObject objectForKey:@"all"];
            
            /**
             *  展示个人相册
             */
            
            [weakself.imageView1 sd_setImageWithURL:array[0]];
            [weakself.imageView2 sd_setImageWithURL:array[1]];
            [weakself.imageView3 sd_setImageWithURL:array[2]];
            
        });

    } failure:^(NSError *error) {
        
    }];
}

#pragma mark -添加footView

- (void)addFootView{
    
    /**
     tableFooterView,添加，添加好友或者和视频聊天按钮
     */
    UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _isFriend||(_isAddFriendVC&&!_isReject)? 180 : 110)];
    footView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    
    _addAendButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _addAendButton.frame = CGRectMake(30, 30, SCREEN_WIDTH - 60, 50);
    [_addAendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addAendButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_addAendButton setBackgroundColor:[UIColor colorWithRed:46/255.0 green:178/255.0 blue:30/255.0 alpha:1.0]];
    _addAendButton.tag = 100;
    _addAendButton.layer.cornerRadius = 5;
    _addAendButton.clipsToBounds      = YES;
    
    [_addAendButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    [footView addSubview:_addAendButton];
    
    
    _videoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    _videoButton.frame = CGRectMake(30, 100, SCREEN_WIDTH - 60, 50);
    [_videoButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _videoButton.titleLabel.font = [UIFont systemFontOfSize:18];
    [_videoButton setBackgroundColor:[UIColor whiteColor]];
    _videoButton.layer.cornerRadius = 5;
    _videoButton.clipsToBounds      = YES;
    _videoButton.layer.borderColor  = [UIColor lightGrayColor].CGColor;
    _videoButton.layer.borderWidth  = 0.5;
    [_videoButton addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isFriend) {
        
        [_addAendButton setTitle:@"发信息" forState:UIControlStateNormal];
        _addAendButton.tag = 102;
        
        
        [_videoButton setTitle:@"视频聊天" forState:UIControlStateNormal];
        _videoButton.tag = 101;
        
        [footView addSubview:_videoButton];
        
    }else if (_isAddFriendVC){
        
        if (_isReject) {
            
            [_addAendButton setTitle:@"已拒绝" forState:UIControlStateNormal];
            [_addAendButton setBackgroundColor:[UIColor lightGrayColor]];
            [_addAendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            _addAendButton.enabled = NO;
            _addAendButton.tag = 105;
            
        }else{
            
            [_addAendButton setTitle:@"通过验证" forState:UIControlStateNormal];
            _addAendButton.tag = 103;
            
            
            [_videoButton setTitle:@"拒绝" forState:UIControlStateNormal];
            _videoButton.tag = 104;
            
            
            [footView addSubview:_videoButton];
        }
        
    }else{
        [_addAendButton setTitle:@"添加好友" forState:UIControlStateNormal];
    }
    
    self.myTableView.tableFooterView = footView;
    
}


#pragma mark -点击头像放大

- (void)showBigImage{
    
    _photosArray  = [NSMutableArray array];
    
    [_photosArray addObject:[MWPhoto photoWithImage:_headImgView.image]];
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    
    // Set options
    browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
    browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
    browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
    browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
    browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
    browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
    browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
    [browser setCurrentPhotoIndex:0];
    
    browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
   
    // Present
    //    [self.navigationController pushViewController:browser animated:NO];
    [self presentViewController:browser animated:YES completion:^{
        
    }];

}

#pragma mark - MWPhotoBrowserDelegae

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photosArray.count) {
        return [_photosArray objectAtIndex:index];
    }
    return nil;
}



- (void)click:(UIButton *)button{
    NSLog(@"添加为好友或者跳转到聊天界面");
    
    switch (button.tag) {
        case 100:
            //添加好友
        {
            QYHVerificationViewController *vc = [[QYHVerificationViewController alloc]initWithNibName:@"QYHVerificationViewController" bundle:nil];
            vc.userJid = [XMPPJID jidWithUser:_numberLabel.text domain:[QYHAccount shareAccount].domain resource:nil];
            vc.friendName = _numberLabel.text;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 101:
            //视频聊天
            NSLog(@"视频聊天");
            [[[UIAlertView alloc]initWithTitle:@"未实现 ！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
            break;
            
        case 102:
            //发信息
        {
            
            if (_isFromChatVC) {
                [self.navigationController popViewControllerAnimated:YES];
                
            }else{
                _chatVC.friendJid = [XMPPJID jidWithUser:_numberLabel.text domain:[QYHAccount shareAccount].domain resource:nil];
                _chatVC.isRefresh = YES;
                _chatVC.title = _nameLabel.text;
                
                __weak __typeof(self) weakSelf = self;
                [[QYHFMDBmanager shareInstance] queryAllChatMessegeByFromUserID:_chatVC.friendJid.user orToUserID:[QYHAccount shareAccount].loginUser completion:^(NSArray *messagesArray, BOOL result) {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.chatVC.allDataArray = [messagesArray mutableCopy];
                        [weakSelf.navigationController pushViewController:weakSelf.chatVC animated:YES];
                    });
                    
                }];

//                
//                if ([self.messageArray[_index] isKindOfClass:[NSString class]]) {
//                    _chatVC.allDataArray = nil;
//                }else{
//                    _chatVC.allDataArray = self.messageArray[_index];
//                }
//                
//                [self.navigationController pushViewController:_chatVC animated:YES];
            }
            
        }
            break;
        case 103:
            //通过验证
            [self agreed];
            NSLog(@"通过验证");
            break;
        case 104:
            //拒绝验证
            [self reject];
            NSLog(@"拒绝验证");
            break;
        default:
            break;
    }
}

/**
 *  点击通过验证事件
 */

#pragma mark -点击通过验证事件

- (void)agreed{
    
    __weak typeof (self) weakself = self;
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        NSLog(@"未成功登陆");
        [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
        
        return;
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _mssegeModel.addStatus = AddFriendAgreed;
    
    if (self.myBlock) {
        self.myBlock(_mssegeModel);
    }
    
    [_addAendButton setTitle:@"发信息" forState:UIControlStateNormal];
    _addAendButton.tag = 102;
    
    
    [_videoButton setTitle:@"视频聊天" forState:UIControlStateNormal];
    _videoButton.tag = 101;

    
    [[QYHFMDBmanager shareInstance] updateAddFriendMessegeStatusByMessegeModel:_mssegeModel completion:^(BOOL result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                
                /**
                 *  接受加为好友
                 */
                XMPPJID *jid = [XMPPJID jidWithUser:_mssegeModel.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
                
                [[QYHXMPPTool sharedQYHXMPPTool].roster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
            
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    
                     [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                    
                    /**
                     *  传到信息聊天界面刷新数据
                     */
                    [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
                    
                    [weakself sendMessage:jid content:@"我们可以开始聊天了！" status:AddAgreeded];
                    
                    /**
                     *  刷新数据
                     */
                    
                    _isFriend = YES;
                    _isAddFriendVC = NO;
                    
                    [weakself.myTableView reloadData];

                });
                
            }else{
                
                [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                
                NSLog(@"数据库更状态失败");
            }
        });
        
    }];
}


#pragma mark -点击拒绝事件

- (void)reject{
    
    __weak typeof (self) weakself = self;
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        NSLog(@"未成功登陆");
        [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
        
        return;
    }
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    _mssegeModel.addStatus = AddFriendReject;
    
    if (self.myBlock) {
        self.myBlock(_mssegeModel);
    }
    
    [_addAendButton setTitle:@"已拒绝" forState:UIControlStateNormal];
    [_addAendButton setBackgroundColor:[UIColor lightGrayColor]];
    [_addAendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _addAendButton.enabled = NO;
    _videoButton.hidden = YES;
    
    [[QYHFMDBmanager shareInstance] updateAddFriendMessegeStatusByMessegeModel:_mssegeModel completion:^(BOOL result) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result) {
                
                /**
                 *  刷新数据
                 */
                [weakself.myTableView reloadData];
                
                /**
                 *  拒绝加为好友
                 */
                XMPPJID *jid = [XMPPJID jidWithUser:_mssegeModel.fromUserID domain:[QYHAccount shareAccount].domain resource:nil];
                
                [[QYHXMPPTool sharedQYHXMPPTool].roster rejectPresenceSubscriptionRequestFrom:jid];
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    /**
                     *  传到信息聊天界面刷新数据
                     */
                    [[NSNotificationCenter defaultCenter] postNotificationName:KReceiveAddFriendNotification object:nil];
                    
                    [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                    
                    [weakself sendMessage:jid content:@"我已拒绝您的请求" status:AddRejected];
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



#pragma mark - tablewviewDelegae

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (_isAddFriendVC) {
        return 5;
    }
    
    return [_singelLabel.text isEqualToString:@""] ? 3:4;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return _isFriend ? 2:0;
            break;
        case 2:
            return _isFriend ? 2:1;
            break;
        case 3:
            return [_singelLabel.text isEqualToString:@""] ? 0:1;
            break;
        case 4:
            return _isAddFriendVC ? 1:0;
            break;
        default:
            break;
    }
    
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (_isFriend) {
        if (indexPath.section == 1) {
            if (indexPath.row) {
                 //拨打电话
                UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:_numberLabel.text delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
                [alerView show];
                
            }else{
                //设置备注
                QYHSetNickNameTableViewController *setNickNameVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"QYHSetNickNameTableViewController"];
                
                setNickNameVC.remarkName = [NSString stringWithFormat:@"%@",_remarkName ? _remarkName : @""];
                setNickNameVC.fromID = _numberLabel.text;
                
                [setNickNameVC setBlock:^(NSString *remarkName){
                    
                    _remarkName = remarkName;
                    self.nickNameLabel.hidden = NO;
                    self.nickNameLabel.text = [@"昵称：" stringByAppendingString:_nickName];
                    
                     _nickNameLabelWithConstraint.constant = [NSString getContentSize:remarkName fontOfSize:20 maxSizeMake:CGSizeMake(200, 21)].width;
                    
                     self.nameLabel.text = remarkName;
                    
                    [self.myTableView reloadData];
                }];
                
                [self.navigationController pushViewController:setNickNameVC animated:YES];
              
            }
            
        }else if (indexPath.section == 2) {
            if (indexPath.row) {
                 //查看个人朋友圈
                
                QYHOtherInformationViewController *otherInformationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHOtherInformationViewController"];
                
                otherInformationVC.photoNumber = _phoneNumber;
                [self.navigationController pushViewController:otherInformationVC animated:YES];
                
                 NSLog(@"查看个人朋友圈");
//                [[[UIAlertView alloc]initWithTitle:@"未实现 ！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
            }
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
//    
//    NSInteger lastSection = _isAddFriendVC ? 3:4;
//    
//    if (section == lastSection) {
//        return 15;
//    }else{
//        return 0.000001;
//    }
//    
//}



#pragma mark - alerViewDelegage

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]];
            
        }
    }
}


@end
