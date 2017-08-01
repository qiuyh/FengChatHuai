//
//  QYHOtherInformationViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/22.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHOtherInformationViewController.h"
#import "QYHContactModel.h"
#import "QYHCircleModel.h"
#import "QYHCircleCell.h"
#import "QYHDetailTableViewController.h"
#import "QYHDiscoverViewController.h"
#import "MJRefresh.h"
#import "UIImageView+WebCache.h"
#import "QYHUploadHeadImageTableViewController.h"

#define kHEIGHT 250
#define kRESPONSEDICKEY @"kRESPONSEDICKEY"

@interface QYHOtherInformationViewController ()<UITableViewDelegate,UITableViewDataSource,UIActionSheetDelegate>

@property (nonatomic,strong) UIImageView *imageView;
@property (nonatomic,strong) UIImageView *myHeadimageView;
@property (nonatomic,strong) UILabel *myNameLabel;
@property (nonatomic,strong) UILabel *personalSignatureLabel;//个人签名
@property (strong,nonatomic) UITableView *myTableView;
@property (nonatomic,strong) NSMutableArray *dataArray;
@property (nonatomic,strong) NSMutableArray *allDataArray;
@property (nonatomic,assign) NSUInteger indexCount;

@property (nonatomic,strong) NSMutableDictionary *responseDic;

@property (nonatomic,strong) NSMutableArray *detailDataArray;//传到详情页面的data

@property (strong,nonatomic) UIActivityIndicatorView *activity1;
@property (strong,nonatomic) UIActivityIndicatorView *activity2;

@end

@implementation QYHOtherInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self information];
}

-(NSMutableDictionary *)responseDic{
    if (!_responseDic) {
        _responseDic = [NSMutableDictionary dictionary];
    }
    return _responseDic;
}

-(NSMutableArray *)dataArray{
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

-(NSMutableArray *)allDataArray{
    if (!_allDataArray) {
        _allDataArray = [NSMutableArray array];
    }
    return _allDataArray;
}

-(NSMutableArray *)detailDataArray{
    if (!_detailDataArray) {
        _detailDataArray = [NSMutableArray array];
    }
    return _detailDataArray;
}


- (void)information{
    
    XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:_photoNumber];
    NSData   *imageData = vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    
    NSString *name = @"我";
    
    QYHContactModel *user = [[QYHChatDataStorage shareInstance].userDic objectForKey:_photoNumber];
    if (user) {
        name =  user.nickname ? [user.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:user.vCard.nickname ? [user.vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [user.displayName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    
    self.myTableView.tableFooterView = [[UIView alloc]init];
    
    UIView *hearerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 70)];
    hearerView.backgroundColor = [UIColor colorWithHexString:kDefaultBackgroundColor];
    
    self.myTableView.tableHeaderView = hearerView;
    
    [self.myTableView insertSubview:self.imageView atIndex:0];
    [self getFriendHeadImage];
    
    self.title = name;
    self.myHeadimageView.image = [UIImage imageWithData:imageData];
    self.myNameLabel.text = name;
    self.personalSignatureLabel.text = vCard.middleName ? [vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//个性签名
    
    NSDictionary *dicResponse = [[NSUserDefaults standardUserDefaults]objectForKey:[kRESPONSEDICKEY stringByAppendingString:_photoNumber]];
    [self sotrByTime:dicResponse];

    [self getAllTrendsByPhoneNumber:_photoNumber];
    
    
    /**
     返回
     */
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
    
    QYHDiscoverViewController *discoverVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    if (_isRefreshDisVC) {
        [discoverVC getFriendHeadImage];
    }
    [self.navigationController popToViewController:discoverVC animated:YES];
}

#pragma mark - 获取相册封面
- (void)getFriendHeadImage{
    NSString *path = [NSString stringWithFormat:@"%@%@friendHeadImage.jpeg",[QYHChatDataStorage shareInstance].homePath,_photoNumber];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    if (!image) {
        image = [UIImage imageNamed:@"tx.jpeg"];
    }
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval a=[dat timeIntervalSince1970]*1000;
    NSString *timeString = [NSString stringWithFormat:@"%f",a];
    
    NSString *imageUrl  = [NSString stringWithFormat:@"http://7xt8p0.com2.z0.glb.qiniucdn.com/%@friendHeadImage.jpeg?_=%@",_photoNumber,timeString];
    
    [self.activity2 startAnimating];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [self.activity2 stopAnimating];
        
        NSData *data = UIImageJPEGRepresentation(image, 1.0);
        NSString *path = [NSString stringWithFormat:@"%@%@friendHeadImage.jpeg",[QYHChatDataStorage shareInstance].homePath,_photoNumber];
        [data writeToFile:path atomically:YES];

    }];
}


#pragma mark - 获取所有的说说信息
/**
 *  获取之前所有的说说信息
 *
 */
- (void)getAllTrendsByPhoneNumber:(NSString *)phoneNumber{
    
     NSString *fileName = @"trends.json";
    
    __weak typeof(self) weakSelf = self;
    
    if (![[NSUserDefaults standardUserDefaults]objectForKey:[kRESPONSEDICKEY stringByAppendingString:_photoNumber]]) {
        [self.activity1 startAnimating];
    }
    
     [[QYHQiNiuRequestManarger shareInstance]getFile:fileName withphotoNumber:phoneNumber Success:^(id responseObject) {
         [weakSelf.activity1 stopAnimating];
         
        NSLog(@"获取全部发表说说信息-responseObject==%@",responseObject);
         
         if (![responseObject isKindOfClass:[NSDictionary class]]) {
             return ;
         }
         
         NSDictionary *dicResponse = [[NSUserDefaults standardUserDefaults]objectForKey:[kRESPONSEDICKEY stringByAppendingString:_photoNumber]];
         dicResponse = dicResponse?dicResponse:@{@"":@""};
         if ([@[responseObject] isEqualToArray:@[dicResponse]]) {
             return;
         }
         
         [[NSUserDefaults standardUserDefaults] setObject:responseObject forKey:[kRESPONSEDICKEY stringByAppendingString:_photoNumber]];
         
         [weakSelf sotrByTime:responseObject];
        
    } failure:^(NSError *error) {
     
        [weakSelf.activity1 stopAnimating];
        
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
- (void)sotrByTime:(NSDictionary *)responseDic{
    
    NSArray *arr = [responseDic objectForKey:@"all"];
    
    NSArray *dateStringArray = [arr mutableCopy];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    arr = [NSArray arrayWithArray:[dateStringArray sortedArrayUsingComparator:^NSComparisonResult(NSDictionary *dic1, NSDictionary *dic2) {
        
        NSDate *date1 = [dateFormatter dateFromString:[dic1 objectForKey:@"time"]];
        NSDate *date2 = [dateFormatter dateFromString:[dic2 objectForKey:@"time"]];
        
        return [date2 compare:date1];
    }]];

    __block NSMutableArray *sectionArray ;
    __block NSString *lastTime = @"";
    __block QYHCircleModel *model1;
    [self.dataArray removeAllObjects];
    [self.allDataArray removeAllObjects];
    [self.detailDataArray  removeAllObjects];
    
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dic = arr[idx];
        
        NSString *photoNumber = [dic objectForKey:@"photoNumber"];
        NSString *time        = [dic objectForKey:@"time"];
        NSString *content     = [dic objectForKey:@"content"];
        NSArray  *commentArray ;
        NSArray  *imagesUrl;
        if ([[dic objectForKey:@"comment"] isKindOfClass:[NSArray class]]) {
            commentArray   = [dic objectForKey:@"comment"];
        }
        
        if ([[dic objectForKey:@"imagesUrl"] isKindOfClass:[NSArray class]]) {
            imagesUrl   = [dic objectForKey:@"imagesUrl"];
        }
        
        NSMutableString *strM = [time mutableCopy];
        
        NSLog(@"strM==%@,lastTime==%@",[strM substringWithRange:NSMakeRange(0, 10)],lastTime);
        if (![lastTime isEqualToString:[strM substringWithRange:NSMakeRange(0, 10)]]) {
            model1 = [[QYHCircleModel alloc]init];
            model1.time = time;
            NSLog(@"model1==%@",model1);
//            [self.dataArray addObject:model1];
            [self.allDataArray addObject:model1];
            
            sectionArray  = [NSMutableArray array];
            [self.detailDataArray addObject:sectionArray];
        }
        
        lastTime = [strM substringWithRange:NSMakeRange(0, 10)];
        
        QYHCircleContentModel *model2 = [[QYHCircleContentModel alloc]init];
        model2.time = time;
        model2.imagesArrM = [imagesUrl mutableCopy];
        model2.content = content;
        
        [model1.contentArrM addObject:model2];
        [sectionArray addObject:obj];
        
    }];
    
    [self addDataAndReloadData];
}

-(void)addDataAndReloadData{
    
    if (self.allDataArray.count>20) {
        
        __weak typeof(self) weakSelf = self;
        self.myTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            
            weakSelf.indexCount = weakSelf.dataArray.count;
            if (weakSelf.allDataArray.count - weakSelf.indexCount < 20) {
                
                for (NSInteger i = weakSelf.indexCount; i<weakSelf.allDataArray.count; i++) {
                    [weakSelf.dataArray addObject:weakSelf.allDataArray[i]];
                }
                
                weakSelf.indexCount = weakSelf.allDataArray.count;
                
            }else{
                for (NSInteger i = weakSelf.indexCount;i<weakSelf.indexCount+20; i++) {
                    [weakSelf.dataArray addObject:weakSelf.allDataArray[i]];
                }
                weakSelf.indexCount += 20;
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 拿到当前的下拉刷新控件，结束刷新状态
                [weakSelf.myTableView.mj_footer endRefreshing];
                
                if (weakSelf.indexCount == weakSelf.allDataArray.count) {
                    [weakSelf.myTableView.mj_footer endRefreshingWithNoMoreData];
                }
                
                 [weakSelf.myTableView reloadData];
            });
            
        }];
        
        [self.allDataArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self.dataArray addObject:obj];
            if (idx==19) {
                *stop = YES;
            }
        }];
    
    }else{
        self.dataArray = [NSMutableArray arrayWithArray:self.allDataArray];
    }
    
    
    [self.myTableView reloadData];
    
}

#pragma mark - 懒加载
-(UIImageView *)imageView{
    if (!_imageView) {
        self.myTableView.contentInset = UIEdgeInsetsMake(kHEIGHT, 0, 50, 0);
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -kHEIGHT, SCREEN_WIDTH, kHEIGHT)];
        _imageView.backgroundColor =[UIColor colorWithHexString:kDefaultBackgroundColor];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        //        _imageView.tag = 101;
        _imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendHeadImage)];
        [_imageView addGestureRecognizer:tap];
        
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

-(UILabel *)personalSignatureLabel{
    if (!_personalSignatureLabel) {
        _personalSignatureLabel = [[UILabel alloc]initWithFrame:CGRectMake(0,20, SCREEN_WIDTH - 15, 21)];
        _personalSignatureLabel.textAlignment = NSTextAlignmentRight;
        _personalSignatureLabel.textColor     = [UIColor grayColor];
        _personalSignatureLabel.font = [UIFont systemFontOfSize:15.0f];
        
        [self.myTableView addSubview:_personalSignatureLabel];
    }
    
    return _personalSignatureLabel;
}

-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _myTableView.backgroundColor = [UIColor colorWithHexString:kDefaultBackgroundColor];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        
        [self.view addSubview:_myTableView];
    }
    
    return _myTableView;
}

-(UIActivityIndicatorView *)activity1{
    if (!_activity1) {
        _activity1 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity1.frame = CGRectMake(SCREEN_WIDTH/2.0 - 25, SCREEN_HEIGHT/2.0+30, 50, 50);
        _activity1.transform = CGAffineTransformMakeScale(2, 2);
        [self.view addSubview:_activity1];
    }
    return _activity1;
}

-(UIActivityIndicatorView *)activity2{
    if (!_activity2) {
        _activity2 = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _activity2.frame = CGRectMake(SCREEN_WIDTH/2.0 - 25, 120, 50, 50);
        _activity2.transform = CGAffineTransformMakeScale(2, 2);
        [self.view addSubview:_activity2];
    }
    return _activity2;
}



#pragma mark - Action

- (void)friendHeadImage{
    if (![_photoNumber isEqualToString:[QYHAccount shareAccount].loginUser]) {
        return;
    }
    
    UIActionSheet *sheet = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"更改相册封面", nil];
    [sheet showInView:self.view];
}

- (void)tapHeadImage{
    
    XMPPvCardTemp *vCard = [[QYHXMPPvCardTemp shareInstance] vCard:_photoNumber];
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
    
    NSData   *imageUrl = vCard.photo ?vCard.photo:UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    NSString *nickName = vCard.nickname ?[vCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *sex = vCard.formattedName ?[vCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *area = vCard.givenName ?[vCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *personalSignature = vCard.middleName ?[vCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";
    NSString *phone = _photoNumber;
    
    detailVC.dic = @{@"imageUrl":imageUrl,
                     @"nickName":nickName,
                     @"sex":sex,
                     @"area":area,
                     @"personalSignature":personalSignature,
                     @"phone":phone
                     };
    //    detailVC.index      = 0;
    
    [self.navigationController pushViewController:detailVC animated:YES];

}


#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex) {
        return;
    }
    
    QYHUploadHeadImageTableViewController *uploadImageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHUploadHeadImageTableViewController"];
    uploadImageVC.isFromDiscoverVC = NO;
    [self.navigationController pushViewController:uploadImageVC animated:YES];
    
}

#pragma mark- UITableViewDelegate,UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    QYHCircleModel *model = self.dataArray[section];
    return model.contentArrM.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"QYHCircleCell";
    QYHCircleCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[QYHCircleCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
   
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    BOOL isFirstRow = NO;
    
    if (indexPath.row==0) {
        isFirstRow = YES;
    }
    
    QYHCircleModel *model = self.dataArray[indexPath.section];
    QYHCircleContentModel *model2 = model.contentArrM[indexPath.row];
    
    [cell confitDataByQYHCircleContentModel:model2 firstRow:isFirstRow];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"QYHDiscoverTableViewCell");
    
    QYHCircleCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.contentBgView.backgroundColor = [UIColor colorWithRed:208.0/255 green:208.0/255 blue:208.0/255 alpha:0.6];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        cell.contentBgView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3];
    });
    
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QYHDiscoverViewController *discoverVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDiscoverViewController"];
    discoverVC.isDetail = YES;
    NSArray *section = self.detailDataArray[indexPath.section];
    discoverVC.dataArray = [NSMutableArray arrayWithObject:section[indexPath.row]] ;
    [self.navigationController pushViewController:discoverVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QYHCircleModel *model = self.dataArray[indexPath.section];
    QYHCircleContentModel *model2 = model.contentArrM[indexPath.row];

    if (model2.imagesArrM) {
        return 90;
    }else{
        CGSize size = [NSString getContentSize:model2.content fontOfSize:16.0f maxSizeMake:CGSizeMake(SCREEN_WIDTH-90, 60)];
        return size.height+10;
    }
    
    return 150;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    CGPoint point = scrollView.contentOffset;
    //    NSLog(@"point.y==%f",point.y);
    if (point.y < -kHEIGHT*0.5) {
        CGRect rect = self.imageView.frame;
        rect.origin.y = point.y;
        rect.size.height = -point.y;
        self.imageView.frame = rect;
    }
}


@end
