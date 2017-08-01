//
//  QYHDiscoverViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/15.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHDiscoverViewController.h"
#import "QYHDiscoverTableViewCell.h"
#import "MJRefresh.h"
#import "UIView+SDAutoLayout.h"
#import "QYHTrendsViewController.h"
#import "QYHContactModel.h"
#import "QYHDiscoverHeight.h"
#import "QYHOtherInformationViewController.h"
#import "MWPhoto.h"
#import "MWPhotoBrowser.h"
#import "QYHToolView.h"
#import "QYHWebViewController.h"
#import "UIImageView+WebCache.h"
#import "QYHUploadHeadImageTableViewController.h"

#define kHEIGHT 250
#define kSaveDataArray       @"kSaveDataArray"
#define kSaveResponseObject  @"kSaveResponseObject"

@interface QYHDiscoverViewController ()<UITableViewDelegate,UITableViewDataSource,QYHDiscoverTableViewCellDelagete,MWPhotoBrowserDelegate,UIGestureRecognizerDelegate,UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITableView *myTableView;

@property (nonatomic,strong) NSMutableArray *allDataArray;
@property (nonatomic,strong) NSMutableArray *displayPhotosArray;
@property (nonatomic,strong) NSMutableArray *heightArray;
@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImageView *myHeadimageView;
@property (nonatomic,strong) UILabel *myNameLabel;
@property (nonatomic,strong) UIImageView *reflashIconView;
@property (nonatomic,strong) CABasicAnimation *rotateAnimation;

@property (nonatomic,assign) NSInteger indexCount;


@property (nonatomic,strong) UIView *toolView;

@property (nonatomic,strong) QYHToolView *toolView1;

@property (nonatomic,strong) NSString *commentContent;
@property (nonatomic,strong) NSString *photoNumber;
@property (nonatomic,strong) NSString *time;

@property(nonatomic,strong) NSIndexPath *commentIndexPath;
@property(nonatomic,strong) NSDictionary *currentCommentDic;

@property (nonatomic,assign) BOOL isAnswer;//是否为回复的评论
@property (nonatomic,strong) NSString *toUser;//回复谁

@property (nonatomic,assign) CGFloat keybordHeight;
@property (nonatomic,assign) CGFloat toolViewHight;

@property (nonatomic,copy) NSString *cpStr;

@property(nonatomic,strong) UILabel *textViewPlaceholder;

@property (nonatomic,copy) NSString *refreshTime;

@property (nonatomic,assign) CGFloat offsetY;

@end

@implementation QYHDiscoverViewController

static QYHDiscoverViewController * discoverVC = nil;
+(instancetype)shareIstance{
    
    @synchronized (self) {
        if (discoverVC == nil) {
            UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            discoverVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDiscoverViewController"];
        }
    }
    return discoverVC;
}

+(void)attemptDealloc
{
    discoverVC = nil;
}

-(UILabel *)textViewPlaceholder{
    if (!_textViewPlaceholder) {
        _textViewPlaceholder = [[UILabel alloc]initWithFrame:CGRectMake(5, 8, SCREEN_WIDTH-100, 21)];
        _textViewPlaceholder.backgroundColor = [UIColor clearColor];
        _textViewPlaceholder.textColor = [UIColor lightGrayColor];
        _textViewPlaceholder.font =[UIFont systemFontOfSize:15.0f];
        _textViewPlaceholder.hidden = YES;
        
        [self.toolView1.sendTextView addSubview:_textViewPlaceholder];
    }
    
    return _textViewPlaceholder;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _allDataArray = [NSMutableArray array];
        _dataArray = [NSMutableArray array];
        _displayPhotosArray = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.myTableView.tableFooterView = [[UIView alloc]init];
    
    if (!self.isDetail) {
        
        self.title = @"朋友圈";
        
        [self initMJ_refresh];
        
        [self setupReflashIconView];
        
        [self.myTableView insertSubview:self.imageView atIndex:0];
        [self getFriendHeadImage];
        
        XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
        NSData *data   = myvCard.photo ? myvCard.photo : UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
        
        self.myHeadimageView.image = [UIImage imageWithData:data];
        
        self.myNameLabel.text = myvCard.nickname ? [myvCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [QYHAccount shareAccount].loginUser;
        
        /**
         *  从缓存里取出数据
         */
        NSArray *responseObject = [[NSUserDefaults standardUserDefaults]objectForKey:[[QYHAccount shareAccount].loginUser stringByAppendingString:kSaveResponseObject]];
        _allDataArray   = [NSMutableArray array];
        
        for (NSDictionary *dic in responseObject) {
            NSArray *arr = [dic objectForKey:@"all"];
            
            [_allDataArray addObjectsFromArray:arr];
        }
        
        [self sotrByTime];
        
        [self hideKeyboardTap];
        
        [self addToolView];
        
    }else{
        
        [self hideKeyboardTap];
        
        [self addToolView];

        self.title = @"详情";
        self.navigationItem.rightBarButtonItem = nil;
        
        self.textViewPlaceholder.hidden = NO;
        self.textViewPlaceholder.text = @"评论";
        self.commentIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
      
        NSDictionary *dic = [self.dataArray lastObject];
        NSString *photoNumber = [dic objectForKey:@"photoNumber"];
        NSString *time        = [dic objectForKey:@"time"];
        _photoNumber = photoNumber;
        _time = time;
        
        self.myTableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
        
        [self getCellHeight];
    }
    
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [self addNotification];
    
    if (!self.isDetail) {
        
        _isNeedRefresh = [NSString isOutThreeSeconde:_refreshTime];
        
        if (_isNeedRefresh) {
            _refreshTime = [NSString formatCurDate];
            _isNeedRefresh = NO;
            // 马上进入刷新状态
            [self.myTableView.mj_header beginRefreshing];
        }
        
        if (_isDetailRefresh) {
            _isDetailRefresh = NO;
            NSMutableArray *userArray = [NSMutableArray arrayWithArray:[QYHChatDataStorage shareInstance].usersArray];
            [userArray insertObject:@"" atIndex:0];
            [self getAllTrends:userArray];
        }
        
        if (_isInsertObject) {
            _isInsertObject = NO;
            [_allDataArray insertObject:[_dataArray firstObject] atIndex:0];
            [self getCellHeight];
            [self.myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        }
    }
    
    UIBarButtonItem *navigationSpacer = [[UIBarButtonItem alloc]
                                         initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                         target:self action:nil];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        navigationSpacer.width = - 10.5;  // ios 7
        
    }else{
        navigationSpacer.width = - 6;  // ios 6
    }
    
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(popViewAction)];
    
    
    self.navigationItem.leftBarButtonItems = @[navigationSpacer,leftBarButtonItem];
}

- (void)popViewAction{
    
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    self.toolView1.sendTextView.text = nil;
   
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self hideOperationMenu];
    [self.view endEditing:YES];
}

#pragma mark - 轻点收起键盘

- (void)hideKeyboardTap{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboard)];
    tap.cancelsTouchesInView = NO;
    tap.delegate = self;
    [self.myTableView addGestureRecognizer:tap];
}
- (void)hideKeyboard{
    [self hideOperationMenu];
    [self.view endEditing:YES];
}

#pragma mark - 通知

- (void)addNotification{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)noti{
    float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keboardFrame = [noti.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    _keybordHeight= keboardFrame.size.height+44;
    _isShowKeyBoard = YES;
    
//    NSLog(@"keboardFrame==%@",NSStringFromCGRect(keboardFrame));
    [UIView animateWithDuration:duration animations:^{
       self.toolView.frame = CGRectMake(0, SCREEN_HEIGHT-44-keboardFrame.size.height, SCREEN_WIDTH, 44);
        if (_keybordHeight>200) {
            [self setContentOffset];
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)noti{
    
    _isShowKeyBoard = NO;
    
    float duration = [noti.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [UIView animateWithDuration:duration animations:^{
        
        self.toolView1.sendTextView.text = nil;
        self.toolView.frame = CGRectMake(0, _isDetail?SCREEN_HEIGHT-44:SCREEN_HEIGHT, SCREEN_WIDTH, 44);
        
        [self.myTableView setContentOffset:CGPointMake(0, _offsetY) animated:YES];
//        if (!self.isDetail) {
//            _keybordHeight = SCREEN_HEIGHT/4.0;
//            [self setContentOffset];
//        }
    }];
    
}

#pragma mark - 评论工具栏
- (void)addToolView{
    _toolView1 = [[QYHToolView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
    //工具栏
    [_toolView1 initView:NO];
    
    [self.toolView addSubview:_toolView1];
    
    _toolView1.sd_layout.leftEqualToView(self.toolView).rightEqualToView(self.toolView).topEqualToView(self.toolView).bottomEqualToView(self.toolView);
    
    __weak typeof(self) copy_self = self;
    //通过block回调接收到toolView中的text
    [self.toolView1 setMyTextBlock:^(NSString *myText) {
        NSLog(@"%@",myText);
        
        [copy_self.toolView1.sendTextView resignFirstResponder];
        copy_self.commentContent = myText;
        
        [copy_self getTrendsByPhoneNumber:copy_self.photoNumber time:copy_self.time isLink:NO isComment:YES];
        
    }];
    
    
    //回调输入框的contentSize,改变工具栏的高度
    [self.toolView1 setContentSizeBlock:^(CGSize contentSize) {
        if (copy_self.toolView1.sendTextView.text.length >0) {
            copy_self.textViewPlaceholder.hidden = YES;
        }else{
            copy_self.textViewPlaceholder.hidden = NO;
        }
        [copy_self updateHeight:contentSize];
    }];

}

#pragma mark - 更新toolView的高度约束
-(void)updateHeight:(CGSize)contentSize
{
    
    float height = contentSize.height + 8;
    
//        NSLog(@"updateHeightheight==%f",height);
    if (height > 110) {
        height = 110;
    }
    
    CGRect rect = self.toolView.frame;
    rect.origin.y -= (height - rect.size.height);
    rect.size.height = height;
    
    
    if (height!=_toolViewHight&&_toolViewHight>10) {
        _keybordHeight+= height - _toolViewHight;
        [self setContentOffset];
    }
    
    _toolViewHight = height;
    
    [UIView animateWithDuration:0.05 animations:^{
        self.toolView.frame = rect;
        [self.view layoutIfNeeded];
        [self.toolView layoutIfNeeded];
    }];
    
}


-(UIView *)toolView{
    if (!_toolView) {
        _toolView = [[UIView alloc]initWithFrame:CGRectMake(0, _isDetail?SCREEN_HEIGHT-44:SCREEN_HEIGHT, SCREEN_WIDTH, 44)];
        //        _toolView.hidden = YES;
        [self.view addSubview:_toolView];
    }
    
    return _toolView;
}

#pragma mark - 获取相册封面
- (void)getFriendHeadImage{
    NSString *path = [NSString stringWithFormat:@"%@%@friendHeadImage.jpeg",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    NSLog(@"getFriendHeadImage-image==%@",image);
    //<UIImage: 0x14701a5f0> size {638, 424} orientation 0 scale 1.000000
    if (!image) {
        image = [UIImage imageNamed:@"tx.jpeg"];
    }
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f",a];
    
    NSString *imageUrl  = [NSString stringWithFormat:@"http://7xt8p0.com2.z0.glb.qiniucdn.com/%@friendHeadImage.jpeg?_=%@",[QYHAccount shareAccount].loginUser,timeString];
    
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *path = [NSString stringWithFormat:@"%@%@friendHeadImage.jpeg",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
        [data writeToFile:path atomically:YES];
    }];
}


#pragma mark - 获取所有的说说信息
/**
 *  获取之前所有的说说信息
 *
 */
- (void)getAllTrends:(NSArray *)array{
    
    __weak typeof(self) weakself = self;
        
    [[QYHQiNiuRequestManarger shareInstance] getAllTrendsByUserArray:array success:^(id responseObject) {
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.myTableView.mj_header endRefreshing];
        
        NSLog(@"获取全部发表说说信息-responseObject==%@",responseObject);
        
        if (![responseObject isKindOfClass:[NSArray class]]) {
            return ;
        }

        
        NSArray *arr = [[NSUserDefaults standardUserDefaults]objectForKey:[[QYHAccount shareAccount].loginUser stringByAppendingString:kSaveResponseObject]];
        if ([arr isEqualToArray:responseObject]) {
            return;
        }
              NSLog(@"获取全部发表说说信息不相同");
        
        [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[[QYHAccount shareAccount].loginUser stringByAppendingString:kSaveResponseObject]];
        
        
        [weakself.allDataArray removeAllObjects];
        
        [weakself.myTableView.mj_footer resetNoMoreData];
        
        for (NSDictionary *dic in responseObject) {
            NSArray *arr = [dic objectForKey:@"all"];
            
            [weakself.allDataArray addObjectsFromArray:arr];
        }
        
        [weakself sotrByTime];
        
        
    } failure:^(NSError *error) {
        
        // 拿到当前的下拉刷新控件，结束刷新状态
        [self.myTableView.mj_header endRefreshing];
        
        NSDictionary *err = error.userInfo;
        
        NSLog(@"NSLocalizedDescription==%@",err[@"NSLocalizedDescription"]);
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败,请稍后重试"];
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
            
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"请求超时。"]){
            
             [QYHProgressHUD showErrorHUD:nil message:@"请求超时"];
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"似乎已断开与互联网的连接。"]){
            [QYHProgressHUD showErrorHUD:nil message:@"已断开与互联网的连接!"];
        }else{
            [QYHProgressHUD showErrorHUD:nil message:@"未知错误"];
        }
        
    }];
  
}


/**
 *  按时间排序
 */
- (void)sotrByTime{
    
    NSArray *dateStringArray = [_allDataArray mutableCopy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    _allDataArray = [NSMutableArray arrayWithArray:[dateStringArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        
        NSDate *date1 = [dateFormatter dateFromString:[dic1 objectForKey:@"time"]];
        NSDate *date2 = [dateFormatter dateFromString:[dic2 objectForKey:@"time"]];
        
        return [date2 compare:date1];
    }]];
    
    
    [_dataArray removeAllObjects];
    
    if (_allDataArray.count<20) {
        [_dataArray addObjectsFromArray:_allDataArray];
    }else{
        for (int i = 0; i<20; i++) {
            [_dataArray addObject:_allDataArray[i]];
        }
    }
    
    [self getCellHeight];

}

/**
 *  获取cell的高度和其他控件的宽高
 */
- (void)getCellHeight{
    
    _heightArray = [NSMutableArray array];
    
    for (NSDictionary *dic in _dataArray) {
        
        QYHDiscoverHeight *heightModel = [[QYHDiscoverHeight alloc]init];
        
        [heightModel setCellHeightByDic:dic];
        
        [_heightArray addObject:heightModel];
    }
    
    
    [self.myTableView reloadData];
    
}

#pragma mark - MJ 刷新

- (void)initMJ_refresh{
    
    /**
     *  已经去掉原来所有提示的文字和图标
     */
    
    __weak typeof(self) weakself = self;
    self.myTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSMutableArray *userArray = [NSMutableArray arrayWithArray:[QYHChatDataStorage shareInstance].usersArray];
            [userArray insertObject:@"" atIndex:0];
            [weakself getAllTrends:userArray];
            [weakself getFriendHeadImage];
        });
    }];
    
    // 马上进入刷新状态
    [self.myTableView.mj_header beginRefreshing];
    
    
    self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        weakself.indexCount = weakself.dataArray.count;
        if (weakself.allDataArray.count - weakself.indexCount < 20) {
            
            for (NSInteger i = weakself.indexCount; i<weakself.allDataArray.count; i++) {
                [weakself.dataArray addObject:weakself.allDataArray[i]];
            }
            
            weakself.indexCount = weakself.allDataArray.count;

        }else{
            for (NSInteger i = weakself.indexCount;i<weakself.indexCount+20; i++) {
                [weakself.dataArray addObject:weakself.allDataArray[i]];
            }
            weakself.indexCount += 20;
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            // 拿到当前的下拉刷新控件，结束刷新状态
            [weakself.myTableView.mj_footer endRefreshing];
            
//            NSLog(@"weakself.indexCount==%ld,weakself.allDataArray.count==%ld",weakself.indexCount,weakself.allDataArray.count);
            if (weakself.indexCount == weakself.allDataArray.count) {
                [weakself.myTableView.mj_footer endRefreshingWithNoMoreData];
            }
            
            [weakself getCellHeight];
        });
        
    }];
}

#pragma mark - initView

-(UIImageView *)imageView{
    if (!_imageView) {
        self.myTableView.contentInset = UIEdgeInsetsMake(kHEIGHT, 0, 50, 0);
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -kHEIGHT, SCREEN_WIDTH, kHEIGHT)];
        
//        _imageView.image = [UIImage imageNamed:@"tx.jpeg"];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendHeadImage)];
        [_imageView addGestureRecognizer:tap];
//        _imageView.tag = 101;
       
    }
    
    return _imageView;
}

-(UIImageView *)myHeadimageView{
    if (!_myHeadimageView) {
        _myHeadimageView = [[UIImageView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-70, - 50, 65, 65)];
//        _myHeadimageView.backgroundColor =[ UIColor redColor];
        UIView *lineTopView = [[UIView alloc]initWithFrame:CGRectMake(0, -0.5, 66, 0.5)];
        lineTopView.backgroundColor = [UIColor lightGrayColor];
        
        UIView *lineLeftView = [[UIView alloc]initWithFrame:CGRectMake(-0.5, 0, 0.5, 66)];
        lineLeftView.backgroundColor = [UIColor lightGrayColor];

        UIView *lineBottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 65.5, 66, 0.5)];
        lineBottomView.backgroundColor = [UIColor lightGrayColor];

        UIView *lineRightView = [[UIView alloc]initWithFrame:CGRectMake(65.5, 0, 0.5, 66)];
        lineRightView.backgroundColor = [UIColor lightGrayColor];
        
        _myHeadimageView.layer.borderWidth = 3;
        _myHeadimageView.layer.borderColor = [UIColor whiteColor].CGColor;
        _myHeadimageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadImage)];
        [_myHeadimageView addGestureRecognizer:tap];
        
        [_myHeadimageView addSubview:lineTopView];
        [_myHeadimageView addSubview:lineLeftView];
        [_myHeadimageView addSubview:lineBottomView];
        [_myHeadimageView addSubview:lineRightView];
        [self.myTableView addSubview:_myHeadimageView];
    }
    
    return _myHeadimageView;
}
-(UILabel *)myNameLabel{
    if (!_myNameLabel) {
        _myNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,-30, SCREEN_WIDTH - 80, 21)];
        _myNameLabel.textAlignment = NSTextAlignmentRight;
        _myNameLabel.textColor     = [UIColor whiteColor];
        
        [self.myTableView addSubview:_myNameLabel];
    }
    
    return _myNameLabel;
}


- (void)friendHeadImage{
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"更改相册封面", nil];
    [sheet showInView:self.view];
  
}


#pragma mark - 发表

- (IBAction)CameraButton:(id)sender {
    
    QYHTrendsViewController *trendsVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHTrendsViewController"];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:trendsVC];
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}


#pragma mark - 设置转圈圈
- (void)setupReflashIconView
{
    
    _reflashIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"AlbumReflashIcon"]];
    _reflashIconView.frame = CGRectMake(15, -230, 35, 35);
    [self.myTableView.mj_header addSubview:_reflashIconView];
    
    
    _rotateAnimation = [[CABasicAnimation alloc] init];
    _rotateAnimation.keyPath = @"transform.rotation.z";
    _rotateAnimation.fromValue = @0;
    _rotateAnimation.toValue = @(M_PI * 2);
    _rotateAnimation.duration = 1.0;
    _rotateAnimation.repeatCount = MAXFLOAT;
}



- (void)updateRefreshHeaderWithOffsetY:(CGFloat)y
{
    CGFloat rotateValue = (y+314) / 50.0 * M_PI;
    
    if ([self.myTableView.mj_header isRefreshing])
    {
        if (![self.reflashIconView.layer animationForKey:@"reflashIconRotate"]) {
            [self.reflashIconView.layer addAnimation:_rotateAnimation forKey:@"reflashIconRotate"];
        }
        
        return;
    }else{
        [self.reflashIconView.layer removeAnimationForKey:@"reflashIconRotate"];
    }
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
//    transform = CGAffineTransformTranslate(transform, 0, -y);
    transform = CGAffineTransformRotate(transform, rotateValue);
    
    self.reflashIconView.transform = transform;
    
}


#pragma mark- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QYHDiscoverTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QYHDiscoverTableViewCell"];
    
    cell.delegate = self;
    
    QYHDiscoverHeight *heightModel = _heightArray[indexPath.row];
    
    [cell confitDataByDic:_dataArray[indexPath.row] height:heightModel detail:self.isDetail];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"QYHDiscoverTableViewCell");
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QYHDiscoverHeight *heightModel = _heightArray[indexPath.row];
    
    if (self.isDetail) {
        return heightModel.cellHeight;
    }
    
    
    if (heightModel.contentLabelHeight>65) {
        if (heightModel.isOpening) {
             return heightModel.cellHeight+25;
        }else{
             return heightModel.cellHeight-heightModel.contentLabelHeight + 65 +25;
        }
        
    }
    
    return heightModel.cellHeight;
}

#pragma mark - scrollerDelagete

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (self.isDetail) {
        return;
    }
    
    [self updateRefreshHeaderWithOffsetY:scrollView.contentOffset.y];
    
    CGPoint point = scrollView.contentOffset;
//    NSLog(@"point.y==%f",point.y);
    if (point.y < -kHEIGHT*0.5) {
        CGRect rect = self.imageView.frame;
        rect.origin.y = point.y;
        rect.size.height = -point.y;
        self.imageView.frame = rect;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self hideOperationMenu];
    [self.view endEditing:YES];
}

- (void)hideOperationMenu{
    for (QYHDiscoverTableViewCell *cell in self.myTableView.visibleCells) {
        if (cell.operationMenu.show) {
            cell.operationMenu.show = NO;
        }
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex) {
        return;
    }
    
    QYHUploadHeadImageTableViewController *uploadImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHUploadHeadImageTableViewController"];
    uploadImageVC.isFromDiscoverVC = YES;
    [self.navigationController pushViewController:uploadImageVC animated:YES];

}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
//    NSLog(@"gestureRecognizer==%@,touch==%@",gestureRecognizer,touch.view);
    
    if ([touch.view isKindOfClass:[UIButton class]]) {
        
        if ( touch.view.frame.size.height == 36||touch.view.frame.size.height == 30) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - QYHDiscoverTableViewCellDelagete

-(void)dismissOperationView:(QYHDiscoverTableViewCell *)cell{
    
    [self.view endEditing:YES];
    
    for (QYHDiscoverTableViewCell *cell1 in self.myTableView.visibleCells) {
        if (cell1.operationMenu.show&&![cell1 isEqual:cell]) {
            cell1.operationMenu.show = NO;
        }
    }

//    [self hideOperationMenu];
}

-(void)gotoWebViewByUrlString:(NSString *)urlString{
    QYHWebViewController *webVC = [[QYHWebViewController alloc]init];
    webVC.url = urlString;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)showMenuCopy:(NSString *)copyString touch:(UITouch *)touch gesture:(UIGestureRecognizer *)gesture{
    
    _cpStr = copyString;
    
    [self becomeFirstResponder];
    
    UIMenuItem * itemPase = [[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyString)];
    
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems: @[itemPase]];

    CGPoint location = [touch locationInView:[touch view]];
    CGRect menuLocation = CGRectMake(location.x, location.y, 0, 0);
    [menuController setTargetRect:touch?menuLocation:gesture.view.bounds inView:touch?[touch view]:[gesture view]];
    menuController.arrowDirection = UIMenuControllerArrowDown;
    
    [menuController setMenuVisible:YES animated:YES];
    
}

- (BOOL)canBecomeFirstResponder{
    return YES;
}
- (void)copyString{
    [[UIPasteboard generalPasteboard]setString:_cpStr];
    UIMenuController * menuController = [UIMenuController sharedMenuController];
    [menuController setMenuItems:nil];
    [self resignFirstResponder];
}


-(void)answerCommentByToUser:(NSString *)toUser phoneNumber:(NSString *)phoneNumber time:(NSString *)time indexCell:(QYHDiscoverTableViewCell *)commentIndexCell{
    
    _toUser = toUser;
    _photoNumber = phoneNumber;
    _time = time;
    _isAnswer = YES;
    _commentIndexPath = [self.myTableView indexPathForCell:commentIndexCell];
    
    if (![self.toolView1.sendTextView isFirstResponder]) {
        NSString *toName = [self getNickName:_toUser];
        NSString *str = [NSString stringWithFormat:@"回复%@：",toName];
        self.textViewPlaceholder.hidden = NO;
        self.textViewPlaceholder.text = str;
        [self.toolView1.sendTextView becomeFirstResponder];
    }
}

-(void)setCommentIndexCell:(QYHDiscoverTableViewCell *)commentIndexCell{
    
  _commentIndexPath = [self.myTableView indexPathForCell:commentIndexCell];
}

-(void)clickAllTextButton:(BOOL)isOpening indexCell:(QYHDiscoverTableViewCell *)cell{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:cell];
    
    QYHDiscoverHeight *heightModel = _heightArray[indexPath.row];
    heightModel.isOpening = isOpening;
    [self.myTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tapHeadImage{
    [self clickHeadImageByPhotoNumber:[QYHAccount shareAccount].loginUser];
}

/**
 *  进入其他的朋友圈信息界面
 *
 */
-(void)clickHeadImageByPhotoNumber:(NSString *)photoNumber{
    
    if (_isDetail) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        QYHOtherInformationViewController *otherInformationVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHOtherInformationViewController"];
        
        otherInformationVC.photoNumber = photoNumber;
        [self.navigationController pushViewController:otherInformationVC animated:YES];
    }
}

/**
 *  评论、赞
 *
 */
-(void)commentActionByPhotoNumber:(NSString *)photoNumber time:(NSString *)time type:(ClickCommentType)type isLink:(BOOL)isLink{
    
    _isAnswer = NO;
    
    if (type == LikeButtonClickedOperation) {
        
        if (isLink) {
            NSLog(@"点击了赞");
        }else{
            NSLog(@"点击了取消");
        }
        
        [self getTrendsByPhoneNumber:photoNumber time:time isLink:isLink isComment:NO];
        
    }else if (type == CommentButtonClickedOperation){
        [UIView animateWithDuration:0.5 animations:^{
            self.isAnswer = NO;
            if (![self.toolView1.sendTextView isFirstResponder]) {
                self.textViewPlaceholder.hidden = NO;
                self.textViewPlaceholder.text = @"评论";
                [self.toolView1.sendTextView becomeFirstResponder];
                
            }
        }];
        _photoNumber = photoNumber;
        _time = time;
        
        NSLog(@"点击了评论");
    }
}

- (void)setContentOffset{
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    UITableViewCell *cell = [self.myTableView cellForRowAtIndexPath:_commentIndexPath];
    CGRect rect = [cell.superview convertRect:cell.frame toView:window];
    
    CGFloat delta = CGRectGetMaxY(rect) - (window.bounds.size.height - _keybordHeight);
    CGPoint offset = self.myTableView.contentOffset;
    
    const CGFloat y = offset.y;

    _offsetY = y;
//    NSLog(@"delta==%f,,%f",delta,offset.y);
    offset.y += delta;
    
//    if (offset.y < 0) {
//        offset.y = 0;
//    }
    
    [self.myTableView setContentOffset:offset animated:YES];
}


#pragma mark - 获取昵称

- (NSString *)getNickName:(NSString *)phoneNumber{
    QYHContactModel *user = [[QYHChatDataStorage shareInstance].userDic objectForKey:phoneNumber];
    NSString *name = @"我";
    if (user) {
        name =  user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [user.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    return name;
}


/**
 *  获取之前评论、赞个人所有的说说信息
 *
 */
- (void)getTrendsByPhoneNumber:(NSString *)phoneNumber time:(NSString *)time isLink:(BOOL)isLink isComment:(BOOL)isComment{
    
     NSString *fileName = @"trends.json";
    
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[QYHQiNiuRequestManarger shareInstance]getFile:fileName withphotoNumber:phoneNumber Success:^(id responseObject) {
        
        NSLog(@"获取发表说说信息-responseObject==%@",responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *array1 = [responseObject objectForKey:@"all"];
            
           __block NSMutableArray *arrayM = [NSMutableArray arrayWithArray:array1];
           __block NSMutableArray *arrM ;
            
            [arrayM enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                NSLog(@"dicdicdicdic==%@",arrayM[idx]);
                if ([[arrayM[idx]objectForKey:@"time"] isEqualToString:time]) {
                    
                    if ([arrayM[idx] objectForKey:@"comment"]) {
                        
                        NSArray *array2 = [arrayM[idx] objectForKey:@"comment"];
                        arrM = [NSMutableArray arrayWithArray:array2];
                        
                    }else{
                        
                        arrM = [NSMutableArray array];
                    }
                    
                    NSString *content = isComment? weakself.commentContent:@"";
                    
                    NSDictionary *contentDic = @{@"content" :content,
                                                 @"isAnswer":@(weakself.isAnswer),
                                                 @"toUser":weakself.isAnswer ? weakself.toUser:[QYHAccount shareAccount].loginUser};
                    
                    NSDictionary *commetDic = @{@"phone":[QYHAccount shareAccount].loginUser,
                                                @"support":@(isLink),
                                                @"content":contentDic,
                                                @"isComment":@(isComment),
                                                @"time":[NSString formatCurDate]
                                                };
                    [arrM addObject:commetDic];
                    
                    
                    NSDictionary *dic1   = @{@"photoNumber" : [arrayM[idx] objectForKey:@"photoNumber"],
                                             @"time"        : [arrayM[idx] objectForKey:@"time"],
                                             @"content"     : [arrayM[idx] objectForKey:@"content"],
                                             @"imagesUrl"   : [arrayM[idx] objectForKey:@"imagesUrl"],
                                             @"comment"     : arrM
                                             };
                    
                    weakself.currentCommentDic = dic1;
                    [arrayM replaceObjectAtIndex:idx withObject:dic1];
                    
                    *stop = YES;
                }
            }];
            
            
            [weakself uploadAllTrendsContent:arrayM ByPhoneNumber:phoneNumber];
        }
        
    } failure:^(NSError *error) {
        
        _isAnswer = NO;
        
        [weakself.myTableView reloadRowsAtIndexPaths:@[weakself.commentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        NSDictionary *err = error.userInfo;
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
           
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败,请稍后重试"];
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
            
            [QYHProgressHUD showErrorHUD:nil message:@"未能找到对应的文件"];
        }else{
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
           
            [QYHProgressHUD showErrorHUD:nil message:@"未知错误"];
        }
        
    }];
}


/**
 *  上传个人所有的说说信息
 *
 */
- (void)uploadAllTrendsContent:(NSArray *)array  ByPhoneNumber:(NSString *)phoneNumber{
    
    
    NSString *fileName = @"trends.json";
    
    NSDictionary *dic = @{@"all":array};
    
    NSString *str = [NSString dictionaryToJson:dic];
    
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    __weak typeof(self) weakself = self;
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:phoneNumber data:data Success:^(id responseObject) {
        
        _isAnswer = NO;
        NSLog(@"赞、评论说说成功-responseObject==%@",responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            
            if (weakself.isDetail) {
                [weakself.dataArray replaceObjectAtIndex:weakself.commentIndexPath.row withObject:weakself.currentCommentDic];
                [weakself getCellHeight];
                
                QYHDiscoverViewController *discoverVC = [QYHDiscoverViewController shareIstance];
                discoverVC.isDetailRefresh = YES;
                
            }else{
                
                [weakself.dataArray replaceObjectAtIndex:weakself.commentIndexPath.row withObject:weakself.currentCommentDic];
                [weakself.allDataArray replaceObjectAtIndex:weakself.commentIndexPath.row withObject:weakself.currentCommentDic];
                [weakself getCellHeight];
                [weakself.myTableView reloadRowsAtIndexPaths:@[weakself.commentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
 
        });
        
    } failure:^(NSError *error) {
        
        _isAnswer = NO;
        
        [weakself.myTableView reloadRowsAtIndexPaths:@[weakself.commentIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
    
            
            NSDictionary *err = error.userInfo;
            
            if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
            {
               
                [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败,请稍后重试"];
                
            }else
            {
        
                [QYHProgressHUD showErrorHUD:nil message:@"赞、评论说说失败,请稍后重试"];
            }
        });
        
    } progress:^(CGFloat progress) {
        
    }];
}


/**
 *  展示图片
 *
 */
-(void)displayImagesByArrays:(NSArray *)photosUrl index:(NSInteger)index{
    
    [_displayPhotosArray removeAllObjects];
    
    NSInteger indexCount = 0;
    for (NSString *imageUrl in photosUrl) {
        indexCount ++;
        MWPhoto *photo = [MWPhoto photoWithURL:[NSURL URLWithString:imageUrl]];
        photo.caption = [NSString stringWithFormat:@"%ld/%ld",indexCount,photosUrl.count];
         [_displayPhotosArray addObject:photo];
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
        browser.enableSwipeToDismiss = YES;
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
    return _displayPhotosArray.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _displayPhotosArray.count) {
        return [_displayPhotosArray objectAtIndex:index];
    }
    return nil;
}

- (void)dealloc
{
    NSLog(@"QYHDiscoverViewController -- dealloc");
}

@end
