//
//  QYHTrendsViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/17.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHTrendsViewController.h"
#import "PictureViewController.h"
#import "QYHQiNiuRequestManarger.h"
#import "QYHDiscoverViewController.h"

@interface QYHTrendsViewController ()<UITextViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (weak, nonatomic) IBOutlet UILabel *plocerLabel;

@property (nonatomic,strong) NSArray *photosArray;

@property (nonatomic,assign) NSInteger index;

@property (nonatomic,strong) PictureViewController *pictureVC;

@property (nonatomic,strong) UIProgressView *allProgressView ;

@property (nonatomic,strong) UIView *grayView;

@property (nonatomic,assign) BOOL isUploadImage;

@end

@implementation QYHTrendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor greenColor];
    
    [self selectedPhotos];
    
    //添加键盘掉落事件(针对UIScrollView或者继承UIScrollView的界面)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
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
    
    if (_isUploadImage) {
        UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"取消之后发表说说将被取消" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alerView show];
    }else{
//        [self.navigationController popViewControllerAnimated:YES];
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

- (void)selectedPhotos{
    _pictureVC = [[PictureViewController alloc] init];
    
    _pictureVC.maxNum  = 9;
    _pictureVC.itemSize = CGSizeMake(60, 60);
    _pictureVC.minimumInteritemSpacing = 5;
    _pictureVC.minimumLineSpacing = 5;
    _pictureVC.sectionInset = UIEdgeInsetsMake(5, 5, 0, 5);
    _pictureVC.pictureCollectonViewFrame = CGRectMake(0,164, self.view.frame.size.width, 70);
    _pictureVC.addImage = [UIImage imageNamed:@"添加.png"];
    
    [self addChildViewController:_pictureVC];
    self.view.frame = _pictureVC.view.frame;
    [self.view addSubview:_pictureVC.pictureCollectonView];
    
    _pictureVC.pictureCollectonView.backgroundColor = [UIColor whiteColor];
    
    __weak typeof(self) weakself = self;
    
    [_pictureVC setSelectedPhotosArrayBlock:^(NSArray *blockArray) {
        NSLog(@"photosArray.count==%lu",blockArray.count);
        
        weakself.photosArray = blockArray;
    }];
}

- (void)initProgressView{
    
    _index = 0;
    for (int i = 0; i<self.photosArray.count; i++) {
        
        CGFloat x = 5 + i%_pictureVC.count*((SCREEN_WIDTH - _pictureVC.minimumInteritemSpacing*2 - 60*_pictureVC.count)/(_pictureVC.count -1)+ 60);
        CGFloat y =  200 + 65*(i/_pictureVC.count);
        
        UIProgressView *progressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
        progressView.frame = CGRectMake(x,y, 60, 30);
        progressView.progress = 0.0;
        progressView.trackTintColor = [UIColor whiteColor];
        progressView.transform = CGAffineTransformMakeScale(1.0f,2.0f);
        progressView.progressTintColor = [UIColor greenColor];
        progressView.tag = 100+i;
        [self.view addSubview:progressView];
    }
    
    _isUploadImage = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self initAllProgressView];
}

- (void)removeProgressView{
     for (int i = 0; i<self.photosArray.count; i++) {
         id view = [self.view viewWithTag:(100 + i)];
         if ([view isKindOfClass:[UIProgressView class]]) {
             UIProgressView *progressView = view;
             [progressView removeFromSuperview];
         }
     }
    
    [_allProgressView removeFromSuperview];
    [_grayView removeFromSuperview];
}

-(void)initAllProgressView{
    
    _allProgressView = [[UIProgressView alloc]initWithProgressViewStyle:UIProgressViewStyleDefault];
    _allProgressView.frame = CGRectMake(30,SCREEN_HEIGHT/1.5, SCREEN_WIDTH - 60, 30);
    _allProgressView.progress = 0.0;
    _allProgressView.trackTintColor = [UIColor whiteColor];
    _allProgressView.transform = CGAffineTransformMakeScale(1.0f,4.0f);
    _allProgressView.progressTintColor = [UIColor greenColor];
    
    _grayView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT)];
    _grayView.backgroundColor = [UIColor grayColor];
    _grayView.alpha = 0.3;
    
    [[UIApplication sharedApplication].keyWindow addSubview:_grayView];
    [[UIApplication sharedApplication].keyWindow addSubview:_allProgressView];
}

/**
 *  发表说说
 *
 *
 */
- (IBAction)issueButton:(UIBarButtonItem *)sender {
    
    [self.view endEditing:YES];
    
    if (self.photosArray.count) {
        
        [self initProgressView];
        
        NSString *fileName1 = @"trendsImage.jpeg";
        
        __weak typeof(self) weakself = self;
        /**
         *  上传图片
         */
        [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName1 photoNumber:nil photosArray:self.photosArray Success:^(id responseObject) {
            
            NSLog(@"上传多张图片-responseObject==%@",responseObject);
            
            [weakself getAllTrends:responseObject];
            
        } failure:^(NSError *error) {
            [weakself removeProgressView];
            weakself.isUploadImage = NO;
            weakself.navigationItem.rightBarButtonItem.enabled = YES;
            [QYHProgressHUD showErrorHUD:nil message:@"发表说说失败,请稍后重试"];
            
        } partProgress:^(CGFloat progress) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                id view = [self.view viewWithTag:(100 + weakself.index)];
                if ([view isKindOfClass:[UIProgressView class]]) {
                    UIProgressView *progressView = view;
                    [progressView setProgress:progress animated:YES];
                    
                    [weakself.allProgressView setProgress:(weakself.index+progress)/weakself.photosArray.count animated:YES];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if (weakself.allProgressView.progress == 1.0) {
                            [weakself removeProgressView];
                        }
                        if (progressView.progress == 1.0) {
                            [progressView removeFromSuperview];
                        }
                        
                    });
                }
                
            });
            
            
        } totalProgress:^(CGFloat progress) {
            weakself.index = weakself.photosArray.count*progress;
        }];
        
    }else{
        [self getAllTrends:nil];
    }
}

/**
 *  获取之前个人所有的说说信息
 *
 */
- (void)getAllTrends:(NSArray *)array{
    
    [self uploadLastThreePhotos:array];
    
    NSString *fileName2 = @"trends.json";
    
    NSString *photoNumber = [QYHAccount shareAccount].loginUser;
    NSString *time        = [NSString formatCurDate];
    NSString *content     = self.textView.text;
    NSArray  *imagesUrl   = array;
    NSString *imageUrl    = @"";
    
    NSDictionary *dic;
    
    if (self.photosArray.count == 1) {
        UIImage *image = [self.photosArray lastObject];
        
        dic   = @{@"photoNumber" : photoNumber,
                  @"time"        : time,
                  @"content"     : content,
                  @"imagesUrl"   : array ? imagesUrl:imageUrl,
                  @"imageWith"   : @(image.size.width),
                  @"imageHeight" : @(image.size.height)
                  };
        
    }else{
        
        dic   = @{@"photoNumber" : photoNumber,
                  @"time"        : time,
                  @"content"     : content,
                  @"imagesUrl"   : array ? imagesUrl:imageUrl
                  };
    }
    
    __weak typeof(self) weakself = self;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    _isUploadImage = YES;
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    [[QYHQiNiuRequestManarger shareInstance]getFile:fileName2 withphotoNumber:nil Success:^(id responseObject) {
        
        NSLog(@"获取发表说说信息-responseObject==%@",responseObject);
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSArray *array = [responseObject objectForKey:@"all"];
            NSMutableArray *arrM = [NSMutableArray arrayWithArray:array];
            [arrM addObject:dic];
            
            [weakself uploadAllTrends:arrM];
        }
        
    } failure:^(NSError *error) {
        
        NSDictionary *err = error.userInfo;
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            weakself.isUploadImage = NO;
            weakself.navigationItem.rightBarButtonItem.enabled = YES;
            
            [weakself removeProgressView];
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败,请稍后重试"];
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
            
            NSMutableArray *arrM = [NSMutableArray array];
            [arrM addObject:dic];
            
            [weakself uploadAllTrends:arrM];
            
        }else{
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            weakself.isUploadImage = NO;
            weakself.navigationItem.rightBarButtonItem.enabled = YES;
            
            [weakself removeProgressView];
            [QYHProgressHUD showErrorHUD:nil message:@"未知错误"];
        }
        
    }];
}


/**
 *  上传个人三张图片信息
 *
 */
- (void)uploadLastThreePhotos:(NSArray *)array{
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    if (!array) {
        for (int i = 0; i<3; i++) {
            [arrM addObject:@""];
        }
    }else{
        switch (array.count) {
            case 1:
            {
                [arrM addObject:[array lastObject]];
                
                for (int i = 1; i<3; i++) {
                    [arrM addObject:@""];
                }
                break;
            }
            case 2:
            {
                for (int i = 0; i<2; i++) {
                    [arrM addObject:array[i]];
                    
                }
                [arrM addObject:@""];
                break;
            }
                
            default:
            {
                for (int i = 0; i<3; i++) {
                    [arrM addObject:array[i]];
                    
                }
                break;
            }
        }
    }
    
    
    NSString *fileName = @"personalThreePhotos.json";
    
    NSDictionary *dic = @{@"all":arrM};
    
    NSString *str = [NSString dictionaryToJson:dic];
    
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:nil data:data Success:^(id responseObject) {
        NSLog(@"上传个人三张图片信息成功-responseObject==%@",responseObject);
//        http://7xt8p0.com2.z0.glb.qiniucdn.com/15817188552personalThreePhotos.json?_=1473820149530.104004
        
    } failure:^(NSError *error) {
        
    } progress:^(CGFloat progress) {
        
    }];

}

/**
 *  上传个人所有的说说信息
 *
 */
- (void)uploadAllTrends:(NSArray *)array{
    
    NSString *fileName = @"trends.json";
    
    NSDictionary *dic = @{@"all":array};
    
    NSString *str = [NSString dictionaryToJson:dic];
    
    NSData *data =[str dataUsingEncoding:NSUTF8StringEncoding];
    
    __weak typeof(self) weakself = self;
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:nil data:data Success:^(id responseObject) {
        NSLog(@"发表说说成功-responseObject==%@",responseObject);
        //http://7xt8p0.com2.z0.glb.qiniucdn.com/15817188551trends.json
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            weakself.isUploadImage = NO;
            weakself.navigationItem.rightBarButtonItem.enabled = YES;
            
            QYHDiscoverViewController *discoverVC = [QYHDiscoverViewController shareIstance];
            [discoverVC.dataArray insertObject:[array lastObject] atIndex:0];
            discoverVC.isInsertObject  = YES;
            
            [weakself.navigationController dismissViewControllerAnimated:YES completion:^{
                
            }];
            
        });
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            weakself.isUploadImage = NO;
            weakself.navigationItem.rightBarButtonItem.enabled = YES;
            
            NSDictionary *err = error.userInfo;
            
            if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
            {
                [weakself removeProgressView];
                [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败,请稍后重试"];
                
            }else
            {
                [weakself removeProgressView];
                [QYHProgressHUD showErrorHUD:nil message:@"发表说说失败,请稍后重试"];
            }
        });
        
    } progress:^(CGFloat progress) {
        
    }];
}

- (void)keyboardHide{
    [self.view endEditing:YES];
}

#pragma mark - textViewDelagete

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    
    if (!_isUploadImage) {
        if (text.length>0) {
            self.plocerLabel.hidden = YES;
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }else{
            if (textView.text.length<=1) {
                self.plocerLabel.hidden = NO;
                self.navigationItem.rightBarButtonItem.enabled = NO;
            }else{
                self.plocerLabel.hidden = YES;
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
        }
    }
    
    return YES;
}


#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self removeProgressView];
        [self.view endEditing:YES];
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}


-(void)dealloc{
    NSLog(@"QYHTrendsViewController--dealloc");
}

@end
