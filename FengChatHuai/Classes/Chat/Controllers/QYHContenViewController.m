//
//  QYHContenViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/26.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHContenViewController.h"
#import "QYHChatCell.h"
#import "QYHHttpTool.h"
#import "QYHToolView.h"
#import "QYHChatCell.h"
#import "QYHQiNiuRequestManarger.h"
#import "UIImageView+WebCache.h"
#import "MWPhotoBrowser.h"
#import "UIImage+Additions.h"
#import "MJRefresh.h"
#import "QYHRecordingView.h"
#import "NSString+Additions.h"
#import "QYHFMDBmanager.h"
#import "QYHChatMssegeModel.h"
#import "UIView+SDAutoLayout.h"
#import "QYHMessageTableView.h"
#import "QYHMainTabbarController.h"
#import "QYHDetailTableViewController.h"
#import "XMPPvCardTemp.h"
#import "QYHWebViewController.h"
#import "QYHChatViewController.h"
#import "QYHContactModel.h"

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

@interface QYHContenViewController ()<UITableViewDelegate,UITableViewDataSource,NSFetchedResultsControllerDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MWPhotoBrowserDelegate,UIGestureRecognizerDelegate,QYHChatCellDelegate>

{
    NSFetchedResultsController *_resultContr;
    
    NSArray *_face;
    
    CGFloat _ratioHW;
    
    CGFloat _offSet;
    
    BOOL _isCaScroll;
    
    CGFloat _textViewHeight;
    
    UIActivityIndicatorView* _activity;
    BOOL _isRefresh;
    
    BOOL _isSendAgain;
    
    BOOL _isVisibleViewController;

}

@property (nonatomic,assign) NSInteger scrollToTopRow;

@property (nonatomic,strong) UIView* headView;


@property (weak, nonatomic) IBOutlet QYHMessageTableView *myTableView;

//工具栏
@property (weak, nonatomic) IBOutlet UIView *toolView;

@property (nonatomic,strong) QYHToolView *toolView1;


//音量图片
@property (strong, nonatomic) UIImageView *volumeImageView;

//工具栏的高约束，用于当输入文字过多时改变工具栏的约束
//@property (strong, nonatomic) NSLayoutConstraint *tooViewConstraintHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tooViewConstraintBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tooViewConstraintHeight;

@property (nonatomic,assign) MySendContentType sentType;

@property (nonatomic,assign) imageType sendImageType;

@property (nonatomic,assign) CGFloat audioTime;

@property (strong, nonatomic) QYHRecordingView* recordingView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) NSMutableArray *imageArray;

@property (nonatomic, strong) NSMutableArray *photosArray;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,strong) UIScrollView *imageScrollView;

@property (nonatomic,strong) QYHChatCell * preCell;

@property (nonatomic,strong) QYHChatCell * menuCell;

@property (nonatomic,assign) BOOL islager;

@property (nonatomic,strong)  QYHChatMssegeModel *transMssegeModel;


//@property (nonatomic,copy) NSString *contentStr;//复制的文字

@end

@implementation QYHContenViewController


static QYHContenViewController *contenVC = nil;
+(instancetype)shareInstance{
    @synchronized(self) {
        if(contenVC == nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            contenVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHContenViewController"];
        }
    }
    return contenVC;
}

+ (void)attemptDealloc
{
    contenVC = nil;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
        _friendJidDic = [NSMutableDictionary dictionary];
        _imageArray   = [NSMutableArray array];
        _photosArray  = [NSMutableArray array];
        _dataArray    = [NSMutableArray array];
        _allDataArray = [NSMutableArray array];
        _audioTime    = 0;
        
        _toolView1 = [[QYHToolView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
        //工具栏
        [_toolView1 initView:YES];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveChatMessage:) name:KReceiveChatMessageNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rRelayedChatMessage:) name:KRDelayedChatMessageNotification object:nil];
        
        //注册为被通知者
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuShow:) name:UIMenuControllerWillShowMenuNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(menuHide:) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view setBackgroundColor:[UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0]];

    [self.myTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.myTableView.backgroundColor = [UIColor colorWithRed:235.0/255 green:235.0/255 blue:235.0/255 alpha:1.0];

    _face = [QYHChatDataStorage shareInstance].faceDataArray;
    
    //加载数据库的聊天数据
//    [self setupResultContr];

    //添加基本的子视图
    [self addMySubView];

    //给子视图添加约束
    [self addConstaint];

    //设置工具栏的回调
    [self setToolViewBlock];
    
    //添加键盘掉落事件(针对UIScrollView或者继承UIScrollView的界面)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardwillHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = YES;
    tapGestureRecognizer.delegate = self;
    //将触摸事件添加到当前view
    [self.myTableView addGestureRecognizer:tapGestureRecognizer];
    
    [self getData];
    
    
}


- (void)popAction{
    
    NSLog(@"popToRootViewControllerAnimated");
    
    QYHMainTabbarController *tabbar = (QYHMainTabbarController *)self.tabBarController;
    tabbar.selectedIndex = 0;
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    [self keyboardwillHide:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    
    _isCaScroll  = YES;

    
    if (_isRefresh) {
        
        _isRefresh = NO;

        /**
         *  通过保存的字典里获取对应好友是否有草稿
         */
        if ([_friendJidDic objectForKey:_friendJid.user]) {
            _toolView1.sendTextView.text = [_friendJidDic objectForKey:_friendJid.user];
        }else{
            _toolView1.sendTextView.text = @"";
        }
        
        if (_toolView1.sendTextView.text.length > 0) {
            
            [_toolView1.sendTextView becomeFirstResponder];
        }else{
            
            [_toolView1.sendTextView resignFirstResponder];
        }
        
        [self getData];

    }
    
    
    UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:self action:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        navigationSpacer.width = - 10.5;  // ios 7
        
    }else{
        navigationSpacer.width = - 6;  // ios 6
    }
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popAction)];
    
    
    self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
    
    _isVisibleViewController = YES;
    
    /**
     *  转发信息
     */
    if (self.isTrans) {
        self.isTrans = NO;
        [self transSendMessage];
    }
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (_preCell) {
        [_preCell.audioPlayer stop];
        [_preCell.voiceImageView stopAnimating];
        
    }
    /**
     *  判断当前的好友是否有草稿，保存在字典里
     */

    if (_toolView1.sendTextView.text.length > 0) {
        
        [_friendJidDic setObject:_toolView1.sendTextView.text forKey:_friendJid.user];
    }else{
        [_friendJidDic removeObjectForKey:_friendJid.user];
    }
    
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHAccount shareAccount].isNeedRefresh = YES;//传到历史记录聊天那刷新界面

    NSLog(@"QYHContenViewController--viewDidAppear");
    [self updatereadedStatus];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    _isVisibleViewController = NO;
    
    NSLog(@"QYHContenViewController--viewDidDisappear");
}

- (void)updatereadedStatus{
    //更新已读状态
    [[QYHFMDBmanager shareInstance]updateIsAllReadMessegeByFromUserID:self.friendJid.user completion:^(BOOL result) {
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (result) {
                NSLog(@"更新已读状态成功");
            }else{
                NSLog(@"更新已读状态失败");
            }
        });
    }];
}

#pragma mark - 接收聊天信息
- (void)receiveChatMessage:(NSNotification *)noti
{
    QYHChatMssegeModel *messegeModel = [noti object];
    
    if (_isVisibleViewController) {
        if ([messegeModel.fromUserID isEqualToString:self.friendJid.user]) {
            
            [self updatereadedStatus];

            [self addNewMessage:messegeModel];
            
        }
    }
}

#pragma mark - 发送成功后的操作和延时发送的操作
- (void)rRelayedChatMessage:(NSNotification *)noti
{
//    
//    QYHChatMssegeModel *messegeModel = [noti object];
//    
//    NSInteger i = 0;
//    for (i = _dataArray.count-1;i>=0;i--) {
//        
//        if ([_dataArray[i] isKindOfClass:[QYHChatMssegeModel class]]) {
//            
//            QYHChatMssegeModel *model = _dataArray[i];
//            
//            if ([messegeModel.messegeID isEqualToString:model.messegeID]) {
//                model.status = messegeModel.status;
//                break;
//            }
//            
//        }
//    }
//    
//    if (messegeModel.type != SendText ||  _isSendAgain) {
//        
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
//        
//        [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
//        
//        if (_isCaScroll&&!_isSendAgain) {
//            
//            [self scrollToBottom];
//        }
//        
//    }
    
}

- (BOOL)isCanScrollToBottom{
    //判断是否滑动到最后一行
    if (_myTableView.visibleCells.count) {
        QYHChatCell *tmpcell = _myTableView.visibleCells[_myTableView.visibleCells.count-1];
        
        NSIndexPath *index = [_myTableView indexPathForCell:tmpcell];
        
        if (index.row == _dataArray.count -1) {
            return YES;
        }else{
            return NO;
        }
    }

    return NO;
}

- (void) scrollToBottom{
    
    if (_dataArray.count >5) {
        NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
        [self.myTableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }

}

- (void)getData{
    
    [_dataArray removeAllObjects];
    _dataArray = [NSMutableArray array];
    
    if (_allDataArray.count > 15) {
        
//        [self getMOreData];
        
        self.myTableView.tableHeaderView = self.headView;
        
    }else{
        
        self.myTableView.tableHeaderView = nil;
    }
    
    
    if (_allDataArray.count <= 15) {
        
        _dataArray = [ _allDataArray mutableCopy];
        
    }else
    {
        for (int i = 15;i>0;i--) {
            
            [_dataArray addObject:_allDataArray[_allDataArray.count - i]];
        }
    }
    
    [self.myTableView reloadData];
    
    //滑到表底部
    [self scrollToBottom];
    
    [self getImageData];
}

- (void)setupResultContr
{
    //加载数据库的聊天数据
    
    // 1.上下文
    NSManagedObjectContext *msgContext = [QYHXMPPTool sharedQYHXMPPTool].msgArchivingStorage.mainThreadManagedObjectContext;
    
    // 2.查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤 （当前登录用户 并且 好友的聊天消息）
    NSString *loginUserJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID.bare;
    
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    // 设置时间排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    // 3.执行请求
    _resultContr = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultContr.delegate = self;
    NSError *err = nil;
    [_resultContr performFetch:&err];
}

-(void) addMySubView
{
    
    //imageView实例化
//    self.volumeImageView = [[UIImageView alloc] init];
//    self.volumeImageView.hidden = YES;
//    self.volumeImageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.volumeImageView setImage:[UIImage imageNamed:@"record_animate_01.png"]];
//    [self.view addSubview:self.volumeImageView];
    
    _recordingView = [[QYHRecordingView alloc] initWithState:DDShowVolumnState];
    [_recordingView setHidden:YES];
    [_recordingView setCenter:CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0)];
    
    
    [_toolView addSubview:_toolView1];
    
    _toolView1.sd_layout.leftEqualToView(_toolView).rightEqualToView(_toolView).topEqualToView(_toolView).bottomEqualToView(_toolView);

//    _toolView = [[QYHToolView alloc] initWithFrame:CGRectZero];
//
//    [self.view addSubview:_toolView];
    
}

-(void) addConstaint
{
    
    //给volumeImageView进行约束
//    _volumeImageView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSArray *imageViewConstrainH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-60-[_volumeImageView]-60-|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
//    [self.view addConstraints:imageViewConstrainH];
//    
//    NSArray *imageViewConstaintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-150-[_volumeImageView(150)]" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_volumeImageView)];
//    [self.view addConstraints:imageViewConstaintV];
//    
    
    //toolView的约束
//    _toolView.translatesAutoresizingMaskIntoConstraints = NO;
//    NSArray *toolViewContraintH = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[_toolView]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
//    [self.view addConstraints:toolViewContraintH];
//    
//    NSArray * tooViewConstraintV = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[_toolView(44)]|" options:0 metrics:0 views:NSDictionaryOfVariableBindings(_toolView)];
//    [self.view addConstraints:tooViewConstraintV];
//    self.tooViewConstraintHeight = tooViewConstraintV[0];
}

- (UIView *)headView{
    
    if (!_headView) {
        _headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        _headView.backgroundColor = [UIColor clearColor];
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//         _activity.transform = CGAffineTransformMakeScale(2, 2);//改变大小
        [_headView addSubview:_activity];
        _activity.frame = CGRectMake(_headView.frame.size.width/2.0, _headView.frame.size.height/3.0, 20, 20);
        _headView.hidden = YES;
    }
    return _headView;
}

#pragma mark - 上拉加载更多
- (void)getMOreData
{
    
    //等待0.5s
    _headView.hidden = NO;
    [_activity startAnimating];
    _isRefresh = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        self.scrollToTopRow = self.dataArray.count;
        
        NSInteger index = self.allDataArray.count - self.dataArray.count -1;
        
        
        if (index >= 0) {
            
            if (index > 15) {
                
                for (int i = 0;i<15;i++) {
                    
                    [self.dataArray insertObject:self.allDataArray[index - i] atIndex:0];
                }
                
            }else{
                
                for (int i = 0;i<=index;i++) {
                    
                    [self.dataArray insertObject:self.allDataArray[index - i] atIndex:0];
                }
                
                self.myTableView.tableHeaderView = nil;
            }
            
            [self.myTableView reloadData];
            
//            NSIndexPath *scrollToIndex = [NSIndexPath indexPathForRow:self.dataArray.count - self.scrollToTopRow  inSection:0];
//            
//            [self.myTableView scrollToRowAtIndexPath:scrollToIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
            
        }
        
        [_activity stopAnimating];
        _headView.hidden = YES;
        _isRefresh = NO;
    });
}
    
//    
//    __unsafe_unretained __typeof(self) weakSelf = self;
//    
//    // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
//    self.myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//        
//        weakSelf.scrollToTopRow = weakSelf.dataArray.count;
//        
//        NSInteger index = weakSelf.allDataArray.count - weakSelf.dataArray.count -1;
//        
//        if (index > 0) {
//            
//            if (index > 15) {
//                
//                for (int i = 0;i<15;i++) {
//                    
//                    [weakSelf.dataArray insertObject:weakSelf.allDataArray[index - i] atIndex:0];
//                }
//                
//            }else{
//                
//                for (int i = 0;i<=index;i++) {
//                    
//                    [weakSelf.dataArray insertObject:weakSelf.allDataArray[index - i] atIndex:0];
//                }
//                
//                 weakSelf.myTableView.mj_header = nil;
//            }
//            
//            [weakSelf.myTableView reloadData];
//            
//            NSIndexPath *scrollToIndex = [NSIndexPath indexPathForRow:weakSelf.dataArray.count - weakSelf.scrollToTopRow  inSection:0];
//            
//            [weakSelf.myTableView scrollToRowAtIndexPath:scrollToIndex atScrollPosition:UITableViewScrollPositionTop animated:NO];
//            
//            
//        }
//        
//        // 拿到当前的下拉刷新控件，结束刷新状态
//        [weakSelf.myTableView.mj_header endRefreshing];
//        
//    }];
//    
//    
//    
//}

#pragma mark - 实现工具栏的回调
-(void)setToolViewBlock
{
    __weak __block QYHContenViewController *copy_self = self;
    //通过block回调接收到toolView中的text
    [self.toolView1 setMyTextBlock:^(NSString *myText) {
        NSLog(@"%@",myText);
        
        [copy_self sendMessage:SendText imageType:HImageType Content:myText];
      
    }];
    
    
    //回调输入框的contentSize,改变工具栏的高度
    [self.toolView1 setContentSizeBlock:^(CGSize contentSize) {
        [copy_self updateHeight:contentSize];
    }];
    
    //录音开始
    [self.toolView1 setBeganRecordBlock:^(int flag) {
        
        if (flag == 1) {
            
            if (![[copy_self.view subviews] containsObject:copy_self.recordingView])
            {
                [copy_self.view addSubview:copy_self.recordingView];
            }
            [copy_self.recordingView setHidden:NO];
            [copy_self.recordingView setRecordingState:DDShowVolumnState];
            [copy_self.recordingView setVolume:(0.5)];

        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [copy_self.recordingView setHidden:YES];
            });
            return;
        }
    }];
    
    //获取录音声量，用于声音音量的提示
    [self.toolView1 setAudioVolumeBlock:^(CGFloat volume) {
        
        [copy_self.recordingView setVolume:((volume*10)/6 + 0.5)];
        
//        copy_self.volumeImageView.hidden = NO;
//        int index = (int)(volume*100)%6+1;
//        [copy_self.volumeImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"record_animate_%02d.png",index]]];
        
    }];
    
    //获取录音的时间
    [self.toolView1 setAudioTimeBlock:^(CGFloat audioTime) {
        
        copy_self.audioTime = audioTime;
    }];
    
    //获取录音地址（用于录音播放方法）
    [self.toolView1 setAudioURLBlock:^(NSString *audioURL) {
//        copy_self.volumeImageView.hidden = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [copy_self.recordingView setHidden:YES];
        });
        
        NSLog(@"audioURL==%@",audioURL);
        
        copy_self.sentType = SendVoice;
        [copy_self sendMessage:copy_self.sentType imageType:copy_self.sendImageType Content:audioURL];
        
    }];
    
    //录音取消（录音取消后，把音量图片进行隐藏）
    [self.toolView1 setCancelRecordBlock:^(int flag) {
        if (flag == 1) {
//            copy_self.volumeImageView.hidden = YES;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [copy_self.recordingView setHidden:NO];
                [copy_self.recordingView setRecordingState:DDShowCancelSendState];
            });
            return;

        }
        
        if (flag == 0) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [copy_self.recordingView setHidden:NO];
                [copy_self.recordingView setRecordingState:DDShowRecordTimeTooShort];
            });
            return;
        }
    }];
    
    
    //扩展功能回调
    [self.toolView1 setExtendFunctionBlock:^(int buttonTag) {
        
        switch (buttonTag) {
            case 1:
                //从相册获取
                [copy_self imgChooseBtnClick:UIImagePickerControllerSourceTypePhotoLibrary];
                break;
            case 2:
                //拍照
                [copy_self imgChooseBtnClick:UIImagePickerControllerSourceTypeCamera];
                break;
                
            default:
                break;
        }
    }];
}

#pragma mark - 转发消息
-(void)transSendMessage
{
    //插入数据库
    NSString *curentTime = [NSString formatCurDate];
    
    QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
    
    messegeModel.messegeID   = [NSString acodeId];
    messegeModel.fromUserID  = [QYHAccount shareAccount].loginUser;
    messegeModel.toUserID    = self.friendJid.user;
    messegeModel.content     = _transMssegeModel.content;
    messegeModel.time        = curentTime;
    messegeModel.type        = _transMssegeModel.type;
    messegeModel.status      = ChatMessageSending;
    messegeModel.audioTime   = _transMssegeModel.audioTime;
    messegeModel.imageType   = _transMssegeModel.imageType;
    messegeModel.ratioHW     = _transMssegeModel.ratioHW;
    messegeModel.isRead      = YES;
    messegeModel.isReadVioce = YES;
    
    __weak typeof(self) weakSelf = self;
    [[QYHFMDBmanager shareInstance] insertChatMessege:messegeModel completion:^(BOOL result) {
        
        if (!result) {
            NSLog(@"ChatMssege插入数据失败");
        }else{
            
            [weakSelf updateDateFromFMDBAndNetworkMessage:messegeModel isSendAgain:NO];
        }
        
    }];
    
}


#pragma mark - 发送消息
-(void)sendMessage:(MySendContentType) sendType  imageType:(imageType)sendImageType Content:(NSString *)content
{
    //插入数据库
    NSString *curentTime = [NSString formatCurDate];
    
    QYHChatMssegeModel *messegeModel = [[QYHChatMssegeModel alloc]init];
    
    messegeModel.messegeID   = [NSString acodeId];
    messegeModel.fromUserID  = [QYHAccount shareAccount].loginUser;
    messegeModel.toUserID    = self.friendJid.user;
    messegeModel.content     = content;
    messegeModel.time        = curentTime;
    messegeModel.type        = sendType;
    messegeModel.status      = ChatMessageSending;
    messegeModel.audioTime   = _audioTime;
    messegeModel.imageType   = sendImageType;
    messegeModel.ratioHW     = _ratioHW;
    messegeModel.isRead      = YES;
    messegeModel.isReadVioce = YES;
    
    __weak typeof(self) weakSelf = self;
    [[QYHFMDBmanager shareInstance] insertChatMessege:messegeModel completion:^(BOOL result) {
        
        if (!result) {
            NSLog(@"ChatMssege插入数据失败");
        }else{
            
            [weakSelf updateDateFromFMDBAndNetworkMessage:messegeModel isSendAgain:NO];
        }
        
    }];
    
}

#pragma mark - 发送,发送失败，重发
- (void)updateDateFromFMDBAndNetworkMessage:(QYHChatMssegeModel *)messegeModel isSendAgain:(BOOL)isSendAgain
{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (!isSendAgain) {
            
            _isCaScroll = YES;
            
            //添加数据源
            [self addNewMessage:messegeModel];
        }
        
        _isSendAgain = isSendAgain;
        
        if (messegeModel.type == SendText) {
            
            if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
                
                messegeModel.status = ChatMessageSendSuccess;
                
                //发送信息
                [self sendMessage:messegeModel content:nil isSendAgain:isSendAgain];
                
            }else{
                messegeModel.status = ChatMessageSendFailure;
            }
            
            __weak typeof(self) weakself = self;
            
            [[QYHFMDBmanager shareInstance] updateMessegeStatusByMessegeModel:messegeModel completion:^(BOOL result) {
                if (result) {
                    NSLog(@"发文本更新状态成功");
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [weakself.myTableView reloadData];
                        
//                        [[NSNotificationCenter defaultCenter]postNotificationName:KRDelayedChatMessageNotification object:messegeModel];
//                        [QYHAccount shareAccount].isNeedRefresh = YES;
                    });
                    
                }else{
                    NSLog(@"发文本更新状态失败");
                }
            }];
            
            
        }else{
            
            if (messegeModel.type == SendImage && [messegeModel.content hasPrefix:@"http://"]) {
                /**
                 *  转发他人图片
                 */
                
                if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
                    //发送信息
                    messegeModel.status = ChatMessageSendSuccess;
                    [self sendMessage:messegeModel content:messegeModel.content isSendAgain:NO];
                    
                }else{
                    messegeModel.status = ChatMessageSendFailure;
                }
                
                __weak __block QYHContenViewController *copy_self = self;
                
                [[QYHFMDBmanager shareInstance] updateMessegeStatusByMessegeModel:messegeModel completion:^(BOOL result) {
                    if (result) {
                        NSLog(@"转发图片更新状态成功");
                        dispatch_async(dispatch_get_main_queue(), ^{
                            
                            [copy_self.myTableView reloadData];
                            
                        });
                    }else{
                        NSLog(@"转发图片更新状态失败");
                    }
                }];
                
            }else{
                //上传图片、语音
                NSString *fileName = messegeModel.type == SendImage ? @"picture.jpeg" : @"voice.aac";
                
                NSString *path     = [[QYHChatDataStorage shareInstance].homePath stringByAppendingString:messegeModel.content];
                NSData *data       = [NSData dataWithContentsOfFile:path];
                
                [self sendContentToServer:data fileName:fileName sendMessage:messegeModel];
            }
        }
    });

}

#pragma mark - 发送信息
- (void)sendMessage:(QYHChatMssegeModel *)messegeModel content:(NSString *)content isSendAgain:(BOOL)isSendAgain
{
    NSLog(@"messegeModel==%@,self.friendJid==%@",messegeModel,self.friendJid);
    NSDictionary *bodyDic;
    
    NSString *curentTime = [NSString formatCurDate];
    
    if ([messegeModel isKindOfClass:[NSURL class]]) {
        
        bodyDic = @{@"type":@(messegeModel.type),
                    @"messegeID":messegeModel.messegeID,
                    @"imageType":@(messegeModel.imageType),
                    @"ratioHW":@(messegeModel.ratioHW),
                    @"audioTime":@(messegeModel.audioTime),
                    @"time":isSendAgain ? curentTime:messegeModel.time,
                    @"isRead":@(NO),
                    @"isReadVioce":@(NO),
                    @"content":content ? [[NSString stringWithFormat:@"%@",content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : [[NSString stringWithFormat:@"%@",messegeModel.content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
    }
    else
    {
        bodyDic = @{@"type":@(messegeModel.type),
                    @"messegeID":messegeModel.messegeID,
                    @"imageType":@(messegeModel.imageType),
                    @"ratioHW":@(messegeModel.ratioHW),
                    @"audioTime":@(messegeModel.audioTime),
                    @"time":isSendAgain ? curentTime:messegeModel.time,
                    @"isRead":@(NO),
                    @"isReadVioce":@(NO),
                    @"content":content ? [[NSString stringWithFormat:@"%@",content] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] : [messegeModel.content stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]};
        
    }
    
    //把bodyDic转换成data类型
    NSError *error = nil;
    
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
    if (error)
    {
        NSLog(@"解析错误%@", [error localizedDescription]);
    }
    
    //把data转成字符串进行发送
    NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
    
    //    //发送字符串
    //    //1.构建JID
    //    XMPPJID *jid = [XMPPJID  jidWithUser:self.sendUserName domain:MY_DOMAIN resource:@"iPhone"];
    //
    //    //2.获取XMPPMessage
    //    XMPPMessage *xmppMessage = [XMPPMessage messageWithType:@"chat" to:jid];
    //
    //    //3.添加body
    //    [xmppMessage addBody:bodyString];
    //
    //    //4.发送message
    //    [self.xmppStream sendElement:xmppMessage];
    
    //发聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:bodyString];

    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        [[QYHXMPPTool sharedQYHXMPPTool].xmppStream sendElement:msg];
    }
    
    
//    for (QYHContactModel *user in [QYHChatDataStorage shareInstance].usersArray) {
//        if ([user.jid.user isEqualToString:self.friendJid.user]) {
//            
//            if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected] && !user.sectionNum) {
//                 [[QYHXMPPTool sharedQYHXMPPTool].xmppStream sendElement:msg];
//            }else{
//                //用户不在线就存起来，等上线再发
//                NSMutableArray *msgArrM = [self unarchiverArr];
//                
//                if (!msgArrM) {
//                    msgArrM = [NSMutableArray array];
//                }
//                
//                [msgArrM addObject:msg];
//                
//                [self archiver:msgArrM];
//            }
//            
//            break;
//        }
//    }
}


/**
 *  归档
 */
-(void)archiver:(NSMutableArray *)archiverArray{
    //获取文件路径
    NSString *key=[NSString stringWithFormat:@"%@%@sendMsg",[QYHAccount shareAccount].loginUser,[self.friendJid.user mutableCopy]];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:key];
    BOOL result = [NSKeyedArchiver archiveRootObject:archiverArray toFile:filePath];
    
    if (result) {
        NSLog(@"归档成功:%@",filePath);
    }else{
        NSLog(@"归档失败");
    }
    
}

/**
 * 解档
 */
- (NSMutableArray *)unarchiverArr{
    //获取文件路径
    NSString *key=[NSString stringWithFormat:@"%@%@sendMsg",[QYHAccount shareAccount].loginUser,[self.friendJid.user mutableCopy]];
    NSString *documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [documentPath stringByAppendingPathComponent:key];
    //反归档
    NSMutableArray *unarchiverArr = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithFile:filePath]];
    
    NSLog(@"unarchiverArr = %@",unarchiverArr);
    
    return unarchiverArr;
}



//发送失败，重发
//- (void)sendAgainMessage:(QYHChatMssegeModel *)messegeModel
//{
//    
//    NSString *curentTime = [NSString formatCurDate];
//    
//    NSDictionary *bodyDic = @{@"type":@(messegeModel.type),
//                              @"messegeID":messegeModel.messegeID,
//                              @"imageType":@(messegeModel.imageType),
//                              @"ratioHW":@(messegeModel.ratioHW),
//                              @"audioTime":@(messegeModel.audioTime),
//                              @"time":curentTime,
//                              @"isRead":@(NO),
//                              @"isReadVioce":@(NO),
//                              @"content":messegeModel.content
//                              };
//    
//    //把bodyDic转换成data类型
//    NSError *error = nil;
//    
//    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyDic options:NSJSONWritingPrettyPrinted error:&error];
//    if (error)
//    {
//        NSLog(@"解析错误%@", [error localizedDescription]);
//    }
//    
//    //把data转成字符串进行发送
//    NSString *bodyString = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
//    
//    //发聊天数据
//    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
//    [msg addBody:bodyString];
//    
//    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
//        [[QYHXMPPTool sharedQYHXMPPTool].xmppStream sendElement:msg];
//    }else{
//        
//    }
//    
//}
#pragma mark - 添加数据源
- (void)addNewMessage:(QYHChatMssegeModel *)messegeModel
{
    //判断是否滑动到最后一行
    _isCaScroll = [self isCanScrollToBottom];

    if (_isVisibleViewController) {
     
        dispatch_async(dispatch_get_main_queue(), ^{
            QYHChatMssegeModel *model = [self.allDataArray lastObject];
            
            if (!self.allDataArray.count) {
                self.allDataArray = [NSMutableArray array];
                self.dataArray = [NSMutableArray array];
            }//isMinute
            
            if (![NSString isMinute:model.time compare:messegeModel.time]) {
                
                [self.allDataArray addObject:messegeModel.time];
                [self.dataArray addObject:messegeModel.time];
            }
            
            [self.allDataArray addObject:messegeModel];
            [self.dataArray addObject:messegeModel];
            
            //表格滚动到底部
            
            if (_dataArray.count <=2) {
                [self.myTableView reloadData];
            }else{
                
                NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
                
                NSArray *indexPaths= nil;
                
                if (![NSString isMinute:model.time compare:messegeModel.time]) {
                    NSIndexPath *lastTwoIndex = [NSIndexPath indexPathForRow:_dataArray.count - 2 inSection:0];
                    
                    indexPaths = @[lastTwoIndex,lastIndex];
                }else{
                    indexPaths = @[lastIndex];
                }
                
//                [self.myTableView beginUpdates];
//                [self.myTableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
//                [self.myTableView endUpdates];
                
                [self.myTableView reloadData];
                
                if (_isCaScroll) {
                    
                    [self.myTableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    
                }
                
            }
            
            if (messegeModel.type == SendImage) {
                [self getImageData];
            }
        });
        
    }
    
}



#pragma mark - 把图片和声音传到服务器上服务器会返回上传资源的地址
-(void)sendContentToServer:(id) resource fileName:(NSString *)fileName sendMessage:(QYHChatMssegeModel *)messegeModel
{
    
    __weak __block QYHContenViewController *copy_self = self;
    
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName withphotoNumber:nil data:resource Success:^(id responseObject) {
        NSLog(@"上传图片,语音-responseObject==%@",responseObject);
        
        if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
            //发送信息
            messegeModel.status = ChatMessageSendSuccess;
            [self sendMessage:messegeModel content:responseObject isSendAgain:NO];
            
        }else{
            messegeModel.status = ChatMessageSendFailure;
        }
        NSLog(@"messegeModel==%@,,%lu",messegeModel.messegeID,(unsigned long)messegeModel.status);
        
        [[QYHFMDBmanager shareInstance] updateMessegeStatusByMessegeModel:messegeModel completion:^(BOOL result) {
            if (result) {
                NSLog(@"发图片,语音更新状态成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [copy_self.myTableView reloadData];
                    
//                    [[NSNotificationCenter defaultCenter]postNotificationName:KRDelayedChatMessageNotification object:messegeModel];
//                    [QYHAccount shareAccount].isNeedRefresh = YES;
                });
            }else{
                NSLog(@"发图片,语音更新状态失败");
            }
        }];
        
    } failure:^(NSError *error) {
        
        messegeModel.status = ChatMessageSendFailure;
        
        [[QYHFMDBmanager shareInstance] updateMessegeStatusByMessegeModel:messegeModel completion:^(BOOL result) {
            if (result) {
                NSLog(@"发图片,语音失败更新状态成功");
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [copy_self.myTableView reloadData];
                    
//                    [[NSNotificationCenter defaultCenter]postNotificationName:KRDelayedChatMessageNotification object:messegeModel];
//                    [QYHAccount shareAccount].isNeedRefresh = YES;
                });
            }else{
                NSLog(@"发图片,语音失败更新状态失败");
            }
        }];
        
        NSLog(@"上传图片,语音-失败");
        
    } progress:^(CGFloat progress) {
        
    }];
    
}



#pragma mark - 键盘出来的时候调整tooView的位置
-(void) keyChange:(NSNotification *) notify
{
    NSDictionary *dic = notify.userInfo;
    
    CGRect endKey = [dic[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    //坐标系的转换
    CGRect endKeySwap = [self.view convertRect:endKey fromView:self.view.window];
    //运动时间
    [UIView animateWithDuration:[dic[UIKeyboardAnimationDurationUserInfoKey] floatValue] animations:^{
        
        [UIView setAnimationCurve:[dic[UIKeyboardAnimationCurveUserInfoKey] doubleValue]];
        
        self.tooViewConstraintBottom.constant = SCREEN_HEIGHT - endKeySwap.origin.y;
        
//        CGRect frame = self.view.frame;
//        
//        frame.size.height = endKeySwap.origin.y;
//       
//        self.view.frame = frame;
        [self.view layoutIfNeeded];
    }];
    
    
    if (_dataArray.count >5) {
        
        
        if (endKey.size.height > 50) {
            
           [self scrollToBottom];
        }
        
        
    }
}


#pragma mark - 更新toolView的高度约束
-(void)updateHeight:(CGSize)contentSize
{
    
    float height = contentSize.height + 8;
    
    //    NSLog(@"height==%f",height);
    if (height > 110) {
         height = 110;
    }
    
    self.tooViewConstraintHeight.constant = height;
    
    [UIView animateWithDuration:0.05 animations:^{
        [self.view layoutIfNeeded];
        
        if (_textViewHeight != height) {
            [self scrollToBottom];
            _textViewHeight = height;
        }
        
    }];

}

#pragma mark - 获取图片数据
- (void)getImageData
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0)  , ^{
        
        [_imageArray removeAllObjects];
        
        for (id msgObj in _allDataArray) {
            
            if ([msgObj isKindOfClass:[QYHChatMssegeModel class]] ) {
                QYHChatMssegeModel *message = (QYHChatMssegeModel *)msgObj;
                
                MySendContentType contentType = message.type;
                
                if (contentType == SendImage) {
                    
                    [_imageArray addObject:msgObj];
                }
            }
            
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
//            [self.myTableView reloadData];
            
        });

    });
   
}

#pragma mark - 点击查看图片事件
- (void)setImageBlock:(QYHChatCell *)cell
{
    
    __weak __block QYHContenViewController *copy_self = self;
    
    //传出cell中的图片
    [cell setButtonImageBlock:^(NSString *imageURL) {
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [copy_self countIndexByContent:imageURL];
            
        });
        
    }];
    
}

-(void)countIndexByContent:(NSString *)content{
    
    NSInteger count = 0;
    for (QYHChatMssegeModel *msgObj in self.imageArray) {
        
        NSString *imageUrl = msgObj.content;
        
        if ([imageUrl isEqualToString:content]) {
            
            self.index = count;
            break;
        }
        
        count++;
    }
    
    [self displayImageIndex:self.index];

}

#pragma mark 数据库内容改变调用
-(void)controllerDidChangeContent:(NSFetchedResultsController *)controller{

//    [self getImageData];
    
//    
//    id msgObj  = [_allDataArray lastObject];
//    
//    if ([msgObj isKindOfClass:[QYHChatMssegeModel class]] ) {
//        QYHChatMssegeModel *message = (QYHChatMssegeModel *)msgObj;
//        
//        if (message.type == SendImage) {
//            
//            [_imageArray addObject:msgObj];
//        }
//    }
//    
//    [_dataArray addObject:msgObj];
//    
//    //表格滚动到底部
//    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_dataArray.count - 1 inSection:0];
//    
//    [self.myTableView insertRowsAtIndexPaths:@[lastIndex] withRowAnimation:UITableViewRowAnimationBottom];
//     
//    [self.myTableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y<=0  && _isRefresh==NO &&self.myTableView.tableHeaderView)
    {
        [self getMOreData];
    }
}

#pragma mark -tableView DataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
 
    return _dataArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //获取聊天信息
    id msgObj = _dataArray[indexPath.row];
    
    if ([msgObj isKindOfClass:[QYHChatMssegeModel class]] ) {
        QYHChatMssegeModel *message = (QYHChatMssegeModel *)msgObj;
        
        
        //根据类型选cell
        MySendContentType contentType = message.type;
        
        if (![message.fromUserID isEqualToString:[QYHAccount shareAccount].loginUser]) {
            switch (contentType) {
                case SendText:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textCell" forIndexPath:indexPath];
//                    NSMutableAttributedString *contentText = [self showFace:message.content];
                    [cell setMssegeModel:message];
                    [cell setCellValue:message.content urlString:nil type:HeTextContent headImage:nil imageType:3 audioTime:message.audioTime];
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    __weak typeof(self) weakSelf = self;
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];
                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];
                    
                    cell.delagete = self;
                    
                    return cell;
                }
                    break;
                    
                case SendImage:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"heImageCell" forIndexPath:indexPath];
                    [cell setMssegeModel:message];
                    [cell setCellValue:nil urlString:message.content type:HeImageContent headImage:nil imageType:message.imageType audioTime:message.audioTime];
                    
                    [self setImageBlock:cell];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    
                    __weak typeof(self) weakSelf = self;
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];
                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];
                    
                    return cell;
                }
                    break;
                    
                case SendVoice:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"heVoiceCell" forIndexPath:indexPath];
                    [cell setMssegeModel:message];
                    [cell setCellValue:nil urlString:message.content type:HeVoiceContent headImage:nil imageType:3 audioTime:message.audioTime];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    
                    __weak typeof(self) weakSelf = self;
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];

                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];

                    return cell;
                }
                    
                    break;
                    
                default:
                    break;
            }
            
        }else {
            
            switch (contentType) {
                case SendText:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myselfTextCell" forIndexPath:indexPath];
//                    NSMutableAttributedString *contentText = [self showFace:message.content];
                    
                    [cell setMssegeModel:message];
                    [cell setCellValue:message.content urlString:nil type:MyTextContent headImage:nil imageType:3 audioTime:message.audioTime];
                    
                    __weak typeof(cell) weak_cell = cell;
                    __weak typeof(self) weakSelf = self;
                    //重发
                    [cell setSendAgain:^(QYHChatMssegeModel *messageModel) {
                        
                        [weak_cell.activityView setHidden:NO];
                        [weak_cell.activityView startAnimating];
                        [weak_cell.sendFailuredImageView setHidden:YES];
                        [weakSelf updateDateFromFMDBAndNetworkMessage:messageModel isSendAgain:YES];
                    }];
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];

                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];

                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    
                    cell.delagete = self;
                    
                    return cell;
                }
                    break;
                    
                case SendImage:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myImageCell" forIndexPath:indexPath];
                    
                    [cell setMssegeModel:message];
                    [cell setCellValue:nil urlString:message.content type:MyImageContent headImage:nil imageType:message.imageType audioTime:message.audioTime];

                    [self setImageBlock:cell];

                    __weak typeof(cell) weak_cell = cell;
                    __weak typeof(self) weakSelf = self;
                    //重发
                    [cell setSendAgain:^(QYHChatMssegeModel *messageModel) {
                        
                        [weak_cell.activityView setHidden:NO];
                        [weak_cell.activityView startAnimating];
                        [weak_cell.sendFailuredImageView setHidden:YES];
                        [weakSelf updateDateFromFMDBAndNetworkMessage:messageModel isSendAgain:YES];
                    }];
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];
                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];
                    
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];
                    
                    return cell;
                }
                    break;
                    
                case SendVoice:
                {
                    QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myVoiceCell" forIndexPath:indexPath];
                    
                    [cell setMssegeModel:message];
                    [cell setCellValue:nil urlString:message.content type:MyVoiceContent headImage:nil imageType:3 audioTime:message.audioTime ];
                    
                    __weak typeof(cell) weak_cell = cell;
                    __weak typeof(self) weakSelf = self;
                    //重发
                    [cell setSendAgain:^(QYHChatMssegeModel *messageModel) {
                        
                        [weak_cell.activityView setHidden:NO];
                        [weak_cell.activityView startAnimating];
                        [weak_cell.sendFailuredImageView setHidden:YES];
                        [weakSelf updateDateFromFMDBAndNetworkMessage:messageModel isSendAgain:YES];
                    }];
                    //展示Menu
                    [cell setMenuBlock:^(QYHChatCell *cell){
                        
                        [weakSelf longGesture:cell];
                    }];
                    //点击头像进入详情
                    [cell setPushBlock:^(NSString *user){
                        [weakSelf pushToDetailVCByUser:user];
                    }];

                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setBackgroundColor:[UIColor clearColor]];

                    return cell;
                }
                    
                    break;
                    
                default:
                    break;
            }
        }
        
    }else{
        
        QYHChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeCell" forIndexPath:indexPath];
        
        [cell setTime:msgObj];
        
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        [cell setBackgroundColor:[UIColor clearColor]];
        
        return cell;
    }
    
    return nil;
}

//调整cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取聊天信息
    id  msgObj = _dataArray[indexPath.row];
    if ([msgObj isKindOfClass:[QYHChatMssegeModel class]] ) {
        QYHChatMssegeModel *message = (QYHChatMssegeModel *)msgObj;
        
        if (message.type == SendText)
        {
            MLEmojiLabel *emojiLabel2 = [MLEmojiLabel new];
            emojiLabel2.numberOfLines = 0;
            emojiLabel2.font = [UIFont systemFontOfSize:15.0f];
            
            //下面是自定义表情正则和图像plist的例子
            emojiLabel2.customEmojiRegex = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            emojiLabel2.customEmojiPlistName = @"expressionImage_custom";
            emojiLabel2.text = message.content;
            
            CGSize bound = [emojiLabel2 preferredSizeWithMaxWidth:SCREEN_WIDTH*2.0/3];
            
            float height = bound.height + 35;
            return height;
        }
        
        if (message.type == SendImage)
        {
            
            if (message.imageType == VImageType)
            {
                return 120*message.ratioHW;
            }
            
            return 150*message.ratioHW;
        }
        
        
        if (message.type == SendVoice)
        {
            return 60;
        }
        
    }else{
        return 30;
    }
    
    
    return 100;
}


#pragma mark - 点击查看图片，展示图片
- (void)displayImageIndex:(NSInteger)index
{
    [_photosArray removeAllObjects];
    
     _isCaScroll = NO;
    
    for (int i=0; i<_imageArray.count; i++) {
        
        QYHChatMssegeModel *msgObj = _imageArray[i];
        
        NSString *imageUrl = msgObj.content;
        
//        NSLog(@"msgObj.fromUserID ==%@,,%@",msgObj.fromUserID ,imageUrl);

        if (![imageUrl hasPrefix:@"http://"]) {
            
            [_photosArray addObject:[MWPhoto photoWithImage:[UIImage imageWithContentsOfFile:[[QYHChatDataStorage shareInstance].homePath stringByAppendingString:imageUrl]]]];
            
            NSLog(@"lisi===%@",[UIImage imageWithContentsOfFile:imageUrl]);
        }else{
            
            [_photosArray addObject:[MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]]];
        }
        
        
    }
    
    
    dispatch_async ( dispatch_get_main_queue (), ^{
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        
        // Set options
        browser.displayActionButton = YES; // Show action button to allow sharing, copying, etc (defaults to YES)
        browser.displayNavArrows = NO; // Whether to display left and right nav arrows on toolbar (defaults to NO)
        browser.displaySelectionButtons = NO; // Whether selection buttons are shown on each image (defaults to NO)
        browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
        browser.alwaysShowControls = NO; // Allows to control whether the bars and controls are always visible or whether they fade away to show the photo full (defaults to NO)
        browser.enableGrid = YES; // Whether to allow the viewing of all the photo thumbnails on a grid (defaults to YES)
        browser.startOnGrid = NO; // Whether to start on the grid of thumbnails instead of the first photo (defaults to NO)
        [browser setCurrentPhotoIndex:index];
        
        browser.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        // Present
        //    [self.navigationController pushViewController:browser animated:NO];
        [self presentViewController:browser animated:YES completion:^{
            
        }];
        
        // Manipulate
        //    [browser showNextPhotoAnimated:YES];
        //    [browser showPreviousPhotoAnimated:YES];
        //    [browser setCurrentPhotoIndex:10];
        
    });
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _photosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _photosArray.count) {
        return [_photosArray objectAtIndex:index];
    }
    return nil;
}

#pragma mark - 播放语音
- (IBAction)tapVoiceButton:(id)sender {
    
    if (_preCell) {
        [_preCell.audioPlayer stop];
        [_preCell.voiceImageView stopAnimating];
        
    }
    
    QYHChatCell * cell = nil;
    if (sender) {
        cell = (QYHChatCell *)[[sender superview] superview];
    }else{
        cell = _menuCell;
    }
    
    
    
    //播放语音
    [cell playAudioByPlayUrl:cell.playURL];
    
    
    
    NSArray *voiceArray = nil;
    
    if ([cell.reuseIdentifier isEqualToString:@"heVoiceCell"]) {
        
        if (!cell.redTipUIImageView.hidden) {
            cell.redTipUIImageView.hidden = YES;
            
            [[QYHFMDBmanager shareInstance]updateIsReadVoioceMessegeBymessegeID:cell.messageModel.messegeID completion:^(BOOL result) {
                
                if (result) {
                    NSLog(@"更新已读语音成功");
                    
                    //                    dispatch_async(dispatch_get_main_queue(), ^{
                    //
                    //                        NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
                    //
                    //                        [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                    //                    });
                    
                }else{
                    NSLog(@"更新已读语音失败");
                }
            }];
        }
        
        voiceArray = @[[UIImage imageNamed:@"dd_left_voice_one"],[UIImage imageNamed:@"dd_left_voice_two"],[UIImage imageNamed:@"dd_left_voice_three"]];
        
    }else{
        
        
        voiceArray = @[[UIImage imageNamed:@"dd_right_voice_one"],[UIImage imageNamed:@"dd_right_voice_two"],[UIImage imageNamed:@"dd_right_voice_three"]];
        
    }
    
    [cell.voiceImageView setContentMode:UIViewContentModeLeft];
    
    [cell.voiceImageView setAnimationImages:voiceArray];
    [cell.voiceImageView setAnimationRepeatCount:cell.playTime];
    [cell.voiceImageView setAnimationDuration:1];
    
    [cell.voiceImageView startAnimating];
    
    
    _preCell = cell;
    
}


#pragma mark - 已去掉
- (void)displayImage:(NSArray *)imageArray index:(NSInteger)index
{
//{
//
//    QYHImageViewController *imageVC = [[QYHImageViewController alloc]init];
//    imageVC.imageArray  = imageArray;
//    imageVC.index       = index;
//
//    _imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    _imageScrollView.backgroundColor = [UIColor blackColor];
//    _imageScrollView.showsVerticalScrollIndicator   = NO;
//    _imageScrollView.showsHorizontalScrollIndicator = NO;
////    _imageScrollView.maximumZoomScale = 2.0;
////    _imageScrollView.minimumZoomScale = 1.0;
//    _imageScrollView.delegate         = self;
//    _imageScrollView.pagingEnabled    = YES;
//    _imageScrollView.contentSize      = CGSizeMake(_imageArray.count*SCREEN_WIDTH, 0);
//    _imageScrollView.contentOffset    = CGPointMake(index*SCREEN_WIDTH, 0);
//    
//
//    
//    //添加键盘掉落事件(针对UIScrollView或者继承UIScrollView的界面)
//    UITapGestureRecognizer *tapGestureRecognizer1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss:)];
//    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
//    tapGestureRecognizer1.cancelsTouchesInView = NO;
//    //将触摸事件添加到当前view
//    
//    [self.view addGestureRecognizer:tapGestureRecognizer1];
//    
//
//    
//    for (int i=0; i<_imageArray.count; i++) {
//        
//       UIScrollView *scrollView1 = [[UIScrollView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH * i, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//
//        scrollView1.contentSize = CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT);
//        scrollView1.showsHorizontalScrollIndicator = NO;
//        scrollView1.showsVerticalScrollIndicator = NO;
//        scrollView1.multipleTouchEnabled = YES;
//        scrollView1.pagingEnabled = YES;
////        scrollView1.delegate = self;
////        scrollView1.maximumZoomScale = 3.0;
////        scrollView1.minimumZoomScale = 1.0;
//        
//        
//        XMPPMessageArchiving_Message_CoreDataObject *msgObj = _imageArray[i];
//        
//        NSString * bodyStr = msgObj.body;
//        NSData * bodyData = [bodyStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:bodyData options:NSJSONReadingAllowFragments error:nil];
//        
//        NSString *imageUrl = dic[@"content"];
//        UIImageView *imageView = [[UIImageView alloc]init];
//        
//        if (![dic[@"imageType"]integerValue]) {
//            
//            imageView.frame = CGRectMake(0*SCREEN_WIDTH,0 , SCREEN_WIDTH, SCREEN_WIDTH*[dic[@"ratioHW"] floatValue]);
//        }else
//        {
//            imageView.frame = CGRectMake(0*SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_WIDTH*[dic[@"ratioHW"] floatValue]);
//        }
//        
//        imageView.centerY  = scrollView1.centerY;
////        _imageView.backgroundColor = [UIColor redColor];
//        [imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:nil];
//        imageView.userInteractionEnabled = YES;
//        imageView.multipleTouchEnabled   = YES;
//        imageView.tag = 100+i;
//        
//        UIPinchGestureRecognizer *pinchGest = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(tapPichGesture:)];
//        [imageView addGestureRecognizer:pinchGest];
//        
//
//        UITapGestureRecognizer *tapGestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(enlager:)];
//        //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
//        tapGestureRecognizer2.cancelsTouchesInView = YES;
//        tapGestureRecognizer2.numberOfTapsRequired = 2;
//        
//        [tapGestureRecognizer1 requireGestureRecognizerToFail:tapGestureRecognizer2];
//        
//        //将触摸事件添加到当前view
//        [imageView addGestureRecognizer:tapGestureRecognizer2];
//
//        
//        
//        [scrollView1 addSubview:imageView];
//        
//        [_imageScrollView addSubview:scrollView1];
//    }
//    [[UIApplication sharedApplication] setStatusBarHidden:YES];
//    self.navigationController.navigationBarHidden = YES;
//    [self.view addSubview:_imageScrollView];
//    
//}
}


- (void)enlager:(UITapGestureRecognizer *)tap
{
    _islager = !_islager;
    
    if (_islager) {
        
        [UIView animateWithDuration:0.5 animations:^{
            tap.view.transform = CGAffineTransformMakeScale(2.0, 2.0);
        }];
        
        
    }else{
        
        [UIView animateWithDuration:0.5 animations:^{
            tap.view.transform = CGAffineTransformIdentity;
        }];
    }
    
}

- (IBAction)tapPichGesture:(UIPinchGestureRecognizer *)gesture {
    
    
    //手势改变时
    if (gesture.state == UIGestureRecognizerStateChanged)
    {
        
        //捏合手势中scale属性记录的缩放比例
//        gesture.view.transform = CGAffineTransformMakeScale(gesture.scale, gesture.scale);
        gesture.view.frame = CGRectMake(0, 0, gesture.view.frame.size.width* 1+gesture.scale, gesture.view.frame.size.height*gesture.scale);
        UIScrollView *scrollView  = (UIScrollView *)gesture.view.superview;
        scrollView.contentSize    = CGSizeMake(gesture.view.frame.size.width,gesture.view.frame.size.height);
        gesture.view.centerY = scrollView.centerY;
    }
    
    
    //结束后恢复
    if(gesture.state==UIGestureRecognizerStateEnded)
    {
        [UIView animateWithDuration:0.3 animations:^{
                if (gesture.scale <1.0) {
                    
                     gesture.view.transform = CGAffineTransformIdentity;//取消一切形变
                }
                
                if (gesture.scale >3.0) {
                    
                     gesture.view.transform = CGAffineTransformMakeScale(3.0, 3.0);
                }
               
            }];
        }
    
}


- (void)dismiss:(UITapGestureRecognizer *)tap
{

    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    self.navigationController.navigationBarHidden = NO;
    [_imageScrollView removeFromSuperview];
    
//    [self presentViewController:imageVC animated:YES completion:^{
//        
//    }];
}

#pragma mark - ScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    for (id v in scrollView.subviews) {
        
        return v;
        
    }
    
    return nil;
    
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    //位置修正.将view放在中间
    //    view.center = scrollView.center;
}

//判断视图有没有显示在当前页面,如果在就不做任何操作,如果不在当前页面,就遍历scrollView上的子视图上的视图,把它们的放大倍数设为1.0.
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
  
//    
//    if (scrollView == self.imageScrollView) {
//        
//        CGFloat x = scrollView.contentOffset.x;
//        
//        _offSet = SCREEN_WIDTH*_index;
//        
//        if (x == _offSet) {
//            
//            
//            
//        }else{
//            
//            for (UIScrollView *view in scrollView.subviews) {
//                
//                if ([view isKindOfClass:[UIScrollView class]]) {
//                    //                    [view setZoomScale:1.0];
//                    UIImageView *imgView = [view viewWithTag:_index +100];
//                    imgView.transform = CGAffineTransformIdentity;
//                    
//                }
//                
//            }
//            
//            _offSet = x;
//            _index  = _offSet/SCREEN_WIDTH;
//            
//        }
//        
//    }
    
}


#pragma mark - gesture delegate

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    NSLog(@"touch==%@",touch.view);
    
    if ([touch.view isKindOfClass:[MLEmojiLabel class]]) {
        MLEmojiLabel *mlEmojiLabel = (MLEmojiLabel *)touch.view;
        return ![mlEmojiLabel containslinkAtPoint:[touch locationInView:mlEmojiLabel]];
    }
    return YES;
    
}


#pragma mark - QYHChatCellDelegate
- (void)pushToWebViewControllerByUrl:(NSString *)url{
    
    QYHWebViewController *webVC = [[QYHWebViewController alloc]init];
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];
}


#pragma mark - 显示表情
//显示表情,用属性字符串显示表情
-(NSMutableAttributedString *)showFace:(NSString *)str
{
    if (str != nil) {
        
            //创建一个可变的属性字符串
            
            NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:str];
            
            UIFont *baseFont = [UIFont systemFontOfSize:17];
            [attributeString addAttribute:NSFontAttributeName value:baseFont
                                    range:NSMakeRange(0, str.length)];
            
            //正则匹配要替换的文字的范围
            //正则表达式
            NSString * pattern = @"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]";
            NSError *error = nil;
            NSRegularExpression * re = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
            
            if (!re) {
                NSLog(@"%@", [error localizedDescription]);
            }
            
            //通过正则表达式来匹配字符串
            NSArray *resultArray = [re matchesInString:str options:0 range:NSMakeRange(0, str.length)];
            
            //用来存放字典，字典中存储的是图片和图片对应的位置
            NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:resultArray.count];

            //根据匹配范围来用图片进行相应的替换
            for(NSTextCheckingResult *match in resultArray) {
                //获取数组元素中得到range
                NSRange range = [match range];
                
                //获取原字符串中对应的值
                NSString *subStr = [str substringWithRange:range];
                
                UIFont *font = [UIFont systemFontOfSize:18];
                
                //face[i][@"gif"]就是我们要加载的图片
                //新建文字附件来存放我们的图片
                
                NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
                
                //给附件添加图片
                textAttachment.image = [UIImage imageNamed:[QYHChatDataStorage shareInstance].faceDictionary[subStr]];
                textAttachment.bounds = CGRectMake(0, -5,font.lineHeight, font.lineHeight);
                
                
                //把附件转换成可变字符串，用于替换掉源字符串中的表情文字
                
                NSAttributedString *imageStr = [NSAttributedString attributedStringWithAttachment:textAttachment];
                
                //把图片和图片对应的位置存入字典中
                NSMutableDictionary *imageDic = [NSMutableDictionary dictionaryWithCapacity:2];
                [imageDic setObject:imageStr forKey:@"image"];
                [imageDic setObject:[NSValue valueWithRange:range] forKey:@"range"];
                
                //把字典存入数组中
                [imageArray addObject:imageDic];
                
            }
        
        //从后往前替换
        for (int i = (int)imageArray.count -1; i >= 0; i--)
        {
            NSRange range;
            [imageArray[i][@"range"] getValue:&range];
            //进行替换
            [attributeString replaceCharactersInRange:range withAttributedString:imageArray[i][@"image"]];
            
        }

        return attributeString;
        
    }
    
    return nil;
    
}



#pragma mark 发送聊天数据
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    NSString *txt = textField.text;
    
    // 清空输入框的文本
    textField.text = nil;
    
    //怎么发聊天数据
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:txt];
    [[QYHXMPPTool sharedQYHXMPPTool].xmppStream sendElement:msg];
    
    return YES;
    
}



#pragma mark 表格滚动，隐藏键盘

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    [self keyboardwillHide:nil];
}
-(void)keyboardwillHide:(UITapGestureRecognizer*)tap{
    
    if ([_toolView1.sendTextView.inputView isEqual:_toolView1.faceMoreView])
    {
        if (!_toolView1.moreView.hidden) {
            [_toolView1 tapMoreButton:nil];
            
        }if (!_toolView1.functionView.hidden) {
            [_toolView1 tapChangeKeyBoardButton:nil];
        }
    }
    
    [self.view  endEditing:YES];
}


#pragma mark 文件发送(以图片发送为例)
- (IBAction)imgChooseBtnClick:(UIImagePickerControllerSourceType)sourceType {
    //从图片库选取图片
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    imgPC.sourceType = sourceType;
    //imgPC.allowsEditing = YES;
    imgPC.delegate = self;
    
    [self presentViewController:imgPC animated:YES completion:nil];
    
}

#pragma mark 用户选择的图片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    NSLog(@"%@",info);
    
    UIImage *image = info[@"UIImagePickerControllerOriginalImage"];
    
    if (image) {
        
        self.sendImageType = image.size.height > image.size.width ? VImageType : HImageType;
        _ratioHW = image.size.height*1.0/image.size.width;
        
//        //压缩到指定的尺寸
//        CGSize size = CGSizeMake(SCREEN_WIDTH*2, (SCREEN_WIDTH/image.size.width) * image.size.height*2);
//        UIImage * newImage = [UIImage imageByScalingAndCroppingForSize:size withImage:image];
        //等比縮放image
        UIImage * newImage = [UIImage scaleImage:image toScale:0.8];
        
        //将压缩过的图片 转化成二进制流
        NSData *data = UIImageJPEGRepresentation(newImage, 1.0);
        
        NSString *fileName = [NSString stringWithFormat:@"%ld.jpeg", (long)[[NSDate date] timeIntervalSince1970]];
        NSString *path     =[NSString stringWithFormat:@"%@%@",[QYHChatDataStorage shareInstance].homePath,fileName];
        
        [data writeToFile:path atomically:YES];
        
        //发送图片
        //[self sendMessage:SendImage Content:pickerImage];
        self.sentType = SendImage;
        
        [self dismissViewControllerAnimated:YES completion:^{
            
            [self keyboardwillHide:nil];
            [self sendMessage:self.sentType imageType:self.sendImageType Content:fileName];
        }];
        
    }else{
        
        [QYHProgressHUD showErrorHUD:nil message:@"选取图片失败，请选取另外的图片或者重新选取！"];
    }
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        [self keyboardwillHide:nil];
    }];

}

#pragma mark - pushToDetailVC

- (void)pushToDetailVCByUser:(NSString *)user{
    
//    XMPPJID *myJid = [QYHXMPPTool sharedQYHXMPPTool].xmppStream.myJID;
//    XMPPJID *byJID = [XMPPJID jidWithUser:user domain:myJid.domain resource:myJid.resource];
//    
//    XMPPvCardTemp *vCard =  [[QYHXMPPTool sharedQYHXMPPTool].vCard vCardTempForJID:byJID shouldFetch:NO];
    
    XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:[user isEqualToString:[QYHAccount shareAccount].loginUser] ? nil :user];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
    
    NSData   *imageUrl = vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    NSString *nickName = vCard.nickname ?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *sex = vCard.formattedName ?[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *area = vCard.givenName ?[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *personalSignature = vCard.middleName ?[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *phone = user;
    
    detailVC.dic = @{@"imageUrl":imageUrl,
                     @"nickName":nickName,
                     @"sex":sex,
                     @"area":area,
                     @"personalSignature":personalSignature,
                     @"phone":phone
                     };
        detailVC.isFromChatVC = YES;
    
    [self.navigationController pushViewController:detailVC animated:YES];

}

- (IBAction)PushToFriendDetailVC:(id)sender {
    [self pushToDetailVCByUser:self.friendJid.user];
}


#pragma mark - UIMenuController

-(IBAction)longGesture:(QYHChatCell *)cell
{
    
//    self.contentStr = cell.messageModel.content;
    
    
    _menuCell = cell;
    
    [self becomeFirstResponder];
    
    NSString *str = nil;
    switch (cell.messageModel.type) {
        case SendText:
            str = @"复制";
            break;
        case SendImage:
            str = @"点击查看";
            break;
        case SendVoice:
            str = @"听筒播放";
            break;
        default:
            break;
    }
    
    UIMenuItem * itemPase = [[UIMenuItem alloc] initWithTitle:str action:@selector(copyString)];
    UIMenuItem * itemTrans = [[UIMenuItem alloc] initWithTitle:@"转发" action:@selector(trans)];
    UIMenuItem * itemCollect = [[UIMenuItem alloc] initWithTitle:@"收藏" action:@selector(collect)];
    UIMenuItem * itemCancel = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(cancel)];
    
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems: @[itemPase,itemTrans,itemCancel,itemCollect]];
    
//    CGPoint location = [longPress locationInView:[longPress view]];
//    CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
//    [menuController setTargetRect:menuLocation inView:[longPress view]];
//    menuController.arrowDirection = UIMenuControllerArrowDown;
    
    [menuController setTargetRect:cell.chatBgImageView.bounds inView:cell.chatBgImageView];
    
    [menuController setMenuVisible:YES animated:YES];
    
}

#pragma mark - UIMenuControllerNoti
-(void)menuShow:(UIMenuController *)menu
{
    [self setCellBgImagePlaceByIsHide:NO];
}
-(void)menuHide:(UIMenuController *)menu
{
    [self setCellBgImagePlaceByIsHide:YES];

    UIMenuController * menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:nil];
    
    [self resignFirstResponder];
}

/**
 *  长按切换图片和释放切换图片
 *
 *
 */
- (void)setCellBgImagePlaceByIsHide:(BOOL)isHide{
    
    /**
     *  right YES:为我的信息  NO：为他的信息
     */
    if ([_menuCell.reuseIdentifier isEqualToString:@"myImageCell"]||
        [_menuCell.reuseIdentifier isEqualToString:@"myVoiceCell"]||
        [_menuCell.reuseIdentifier isEqualToString:@"myselfTextCell"])
    {
       
        [self setCellBgImageByIsHide:isHide right:YES];
        
    }else{
        [self setCellBgImageByIsHide:isHide right:NO];
    }
    
}

- (void)setCellBgImageByIsHide:(BOOL)isHide right:(BOOL )isRight{
    
    UIImage *image = nil;
    
    if (isHide) {
        
        if (isRight) {
            if ([_menuCell.reuseIdentifier isEqualToString:@"myImageCell"])
            {
                image = [UIImage imageNamed:@"message_sender_background_reversed"];
            }else{
                image = [UIImage imageNamed:@"chatto_bg_normal.png"];
            }
            
        }else{
            if ([_menuCell.reuseIdentifier isEqualToString:@"heImageCell"])
            {
                image = [UIImage imageNamed:@"message_receiver_background_reversed"];
            }else{
                
                image = [UIImage imageNamed:@"chatfrom_bg_normal.png"];
            }
        }
        
    }else{
        
        if (isRight) {
            if ([_menuCell.reuseIdentifier isEqualToString:@"myImageCell"])
            {
                image = [UIImage imageNamed:@"message_sender_background_focused"];
            }else{
                image = [UIImage imageNamed:@"chatto_bg_focused.png"];
            }
        }else{
            if ([_menuCell.reuseIdentifier isEqualToString:@"heImageCell"])
            {
                image = [UIImage imageNamed:@"message_receiver_background_focused"];
            }else{
                image = [UIImage imageNamed:@"chatfrom_bg_focused.png"];
            }
        }
    }
    
    if ([_menuCell.reuseIdentifier isEqualToString:@"myImageCell"] || [_menuCell.reuseIdentifier isEqualToString:@"heImageCell"])
    {
        _menuCell.imgbView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(28, 20, 15, 20) resizingMode:UIImageResizingModeStretch];
    }else{
        
        image = [image resizableImageWithCapInsets:(UIEdgeInsetsMake(image.size.height * 0.6, image.size.width * 0.4, image.size.height * 0.3, image.size.width * 0.4))];
        
        _menuCell.chatBgImageView.image = image;
    }
    
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}

/**
 *  复制、查看图片、播放语音
 */
-(void)copyString
{
    if (!_menuCell.messageModel.content) {
        return;
    }
    
    switch (_menuCell.messageModel.type) {
        case SendText:
            [[UIPasteboard generalPasteboard]setString:_menuCell.messageModel.content];
            break;
        case SendImage:
        {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                [self countIndexByContent:_menuCell.messageModel.content];
                
            });
            break;
        }
        case SendVoice:
            [self tapVoiceButton:nil];
            break;
        default:
            break;
    }
}
/**
 *  转发
 */
- (void)trans{
    QYHChatViewController *chatVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHChatViewController"];
    chatVC.isTrans = YES;
    _transMssegeModel = _menuCell.messageModel;
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:chatVC];
    
//    [self.navigationController pushViewController:chatVC animated:YES];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}
/**
 *  收藏
 */
- (void)collect{
    
    [[[UIAlertView alloc]initWithTitle:@"未实现 ！" message:nil delegate:nil cancelButtonTitle:@"确认" otherButtonTitles:nil, nil] show];
}
/**
 *  删除
 */
- (void)cancel{
    
    __weak typeof(self)weakself = self;
    
    [[QYHFMDBmanager shareInstance]deleteChatMessegeByMessegeID:_menuCell.messageModel.messegeID completion:^(BOOL result) {
        if (result) {
            NSLog(@"删除单条信息成功");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                NSInteger indexCount = [weakself.dataArray indexOfObject:weakself.menuCell.messageModel];
                
                id obj1 = nil;
                id obj2 = @"";
                
                if (indexCount - 1 >= 0) {
                    obj1 = [weakself.dataArray objectAtIndex:indexCount -1];
                }
                
                if (indexCount + 1 < weakself.dataArray.count) {
                    obj2 = [weakself.dataArray objectAtIndex:indexCount +1];
                }
                
                if ([obj1 isKindOfClass:[NSString class]]&&[obj2 isKindOfClass:[NSString class]])
                {
                    [weakself.dataArray removeObjectAtIndex:indexCount -1];
                    [indexPaths addObject:[NSIndexPath indexPathForRow:indexCount -1 inSection:0]];
                }
                
                [weakself.dataArray removeObject:weakself.menuCell.messageModel];
                
                [indexPaths addObject:[_myTableView indexPathForCell:_menuCell]];
                
                [weakself.myTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            });
            
        }else{
             NSLog(@"删除单条信息失败");
        }
        
    }];
}


- (void)dealloc
{
   
    NSLog(@"QYHContenViewController -- dealloc");
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KReceiveChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KRDelayedChatMessageNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    
}


@end
