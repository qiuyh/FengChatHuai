//
//  QYHEditTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHEditTableViewController.h"
#import "QYHKeyBoardManagerViewController.h"
#import <CoreImage/CoreImage.h>
#import "UIImage+Additions.h"
#import "QYHKMQRCode.h"
#import "XMPPvCardTemp.h"

@interface QYHEditTableViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;

@property (nonatomic,strong) UITextView *textView;

@property (nonatomic,strong)UITableView *myTableView;


@property (nonatomic,strong)UIImageView *coreImageView;

// @property (strong, nonatomic) IBOutlet UIImageView *imgVQRCode;

@end

@implementation QYHEditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [QYHKeyBoardManagerViewController shareInstance].selfView = self.view;
    
    //设置标题
    self.title = self.cell.textLabel.text;
    
    if (self.cell) {
        self.tag = self.cell.tag;
    }
    
    switch (self.tag) {
        case 1:
            //名字
            self.textField.text = self.cell.detailTextLabel.text;
            break;
        case 2:
            //二维码
            [self getQRcode];
            break;

        case 3:
            
            break;

        case 4:
            //性别
            [self setSex];
            break;

        case 5:
            //地址
            [self setArea];
            break;

        case 6:
            //个性签名
            [self setSignature];
            break;
            
        default:
            break;
    }
    
}

-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        
        [self.view addSubview:_myTableView];
        
    }
    
    return _myTableView;
}

#pragma mark - 我的二维码
- (void)getQRcode{
    
    self.title = @"我的二维码";
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    
    UIView *view1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 60, SCREEN_HEIGHT - 200)];
    view1.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.7];
    view1.layer.cornerRadius = 5;
    view1.clipsToBounds = YES;
    view1.centerY  = self.view.centerY - 40;
    view1.centerX  = self.view.centerX;
    
    
//    XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
    XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
    NSData *data   = myvCard.photo ? myvCard.photo : UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    
    NSString *account  = [QYHAccount shareAccount].loginUser;
    NSString *nickName = myvCard.nickname ? [myvCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//名字
    NSString *sex      = myvCard.formattedName ? [myvCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//性别
    NSString *area     = myvCard.givenName ?[myvCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//地区
    NSString *personalSignature = myvCard.middleName ? [myvCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//个性签名

    
    UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 60, 60)];
    imgView.layer.cornerRadius = 5;
    imgView.layer.masksToBounds = YES;
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    imgView.layer.borderWidth = 1.0;
    
    imgView.image = [UIImage imageWithData:data];
    
    UILabel *nickNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 25, [NSString getContentSize:nickName fontOfSize:20 maxSizeMake:CGSizeMake(150, 30)].width, 30)];
    nickNameLabel.text = nickName;
    nickNameLabel.textColor = [UIColor blackColor];
    nickNameLabel.font = [UIFont systemFontOfSize:18];

    UIImageView *sexImageView = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(nickNameLabel.frame)+2, 30, 20, 20)];
    
    if ([sex isEqualToString:@""]) {
        sexImageView.image = [UIImage imageNamed:@"noSex"];
    }else{
        sexImageView.image = [UIImage imageNamed:[sex isEqualToString:@"男"]? @"man" : @"woman"];
    }
    
    
    UILabel *areaLabel = [[UILabel alloc]initWithFrame:CGRectMake(90, 56, 100, 20)];
    areaLabel.text = area;
    areaLabel.textColor = [UIColor whiteColor];
    areaLabel.font = [UIFont systemFontOfSize:13];

    
    
    _coreImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    _coreImageView.center  = view1.center;
    _coreImageView.centerY = view1.centerY +20;
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, view1.frame.size.height - 40, view1.frame.size.width, 21)];
    tipLabel.text = @"扫一扫上面的二维码图案，加我为好友";
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    
    //二维码
    [self layoutUIbyNickName:nickName sex:sex area:area personalSignature:personalSignature headImage:data];
    
//    // 1.实例化二维码滤镜
//    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
//    
//    // 2.恢复滤镜的默认属性 (因为滤镜有可能保存上一次的属性)
//    [filter setDefaults];
//    
//    // 3.将字符串转换成NSdata
//    NSDictionary *dic = @{@"nickName":nickName,@"sex":sex,@"area":area};
//    NSString *str = [NSString dictionaryToJson:dic];
//    
//    NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    NSMutableData *mulData = [NSMutableData dataWithData:data];
//    [mulData appendData:UIImageJPEGRepresentation(imgView.image, 1.0)];
//    
//    
//    // 4.通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
//    [filter setValue:data forKey:@"inputMessage"];
//    
//    // 5.生成二维码
//    CIImage *outputImage = [filter outputImage];
//    
//    UIImage *image = [UIImage  imageWithCIImage:outputImage];
//    
//    // 6.设置生成好得二维码到imageview上
//    self.coreImageView.image = image;
    
//    self.coreImageView.layer.shadowOffset=CGSizeMake(0, 0.5);//设置阴影的偏移量
//    
//    self.coreImageView.layer.shadowRadius=1;//设置阴影的半径
//    
//    self.coreImageView.layer.shadowColor=[UIColor blackColor].CGColor;//设置阴影的颜色为黑色
//    
//    self.coreImageView.layer.shadowOpacity=0.3;
    

    
    [view1 addSubview:imgView];
    [view1 addSubview:nickNameLabel];
    [view1 addSubview:areaLabel];
    [view1 addSubview:sexImageView];
    [view1 addSubview:tipLabel];
    [view addSubview:view1];
    [view addSubview:_coreImageView];
    
    [self.view addSubview:view];
    
}

#pragma mark - 生成二维码
- (void)layoutUIbyNickName:(NSString *)nickName sex:(NSString *)sex area:(NSString *)area personalSignature:(NSString *)personalSignature headImage:(NSData *)data {
    
    //用于生成二维码的字符串source
    
     NSString *imageUrl  = [NSString stringWithFormat:@"http://7xt8p0.com2.z0.glb.qiniucdn.com/%@headImage.jpeg",[QYHAccount shareAccount].loginUser];
    
    NSDictionary *dic = @{@"imageUrl":imageUrl,@"nickName":nickName,@"sex":sex,@"area":area,@"personalSignature":personalSignature,@"phone":[QYHAccount shareAccount].loginUser};
    
    NSLog(@"dic=%@",dic);
    
    NSString *str = [NSString dictionaryToJson:dic];
    
    //使用iOS 7后的CIFilter对象操作，生成二维码图片imgQRCode（会拉伸图片，比较模糊，效果不佳）
    CIImage *imgQRCode = [QYHKMQRCode createQRCodeImage:str];
    
    //使用核心绘图框架CG（Core Graphics）对象操作，进一步针对大小生成二维码图片imgAdaptiveQRCode（图片大小适合，清晰，效果好）
    UIImage *imgAdaptiveQRCode = [QYHKMQRCode resizeQRCodeImage:imgQRCode
                                                    withSize:_coreImageView.frame.size.width];
    
    //默认产生的黑白色的二维码图片；我们可以让它产生其它颜色的二维码图片，例如：蓝白色的二维码图片
//    imgAdaptiveQRCode = [QYHKMQRCode specialColorImage:imgAdaptiveQRCode
//                                            withRed:33.0
//                                              green:114.0
//                                               blue:237.0]; //0~255
    
    UIImage *image = [UIImage imageWithData:data];
    
    //使用核心绘图框架CG（Core Graphics）对象操作，创建带圆角效果的图片
    UIImage *imgIcon = [UIImage createRoundedRectImage:image
                                              withSize:CGSizeMake(50.0, 50.0)
                                            withRadius:5];
    //使用核心绘图框架CG（Core Graphics）对象操作，合并二维码图片和用于中间显示的图标图片
    imgAdaptiveQRCode = [QYHKMQRCode addIconToQRCodeImage:imgAdaptiveQRCode
                                              withIcon:imgIcon
                                          withIconSize:imgIcon.size];
    
    //    imgAdaptiveQRCode = [KMQRCode addIconToQRCodeImage:imgAdaptiveQRCode
    //                                              withIcon:imgIcon
    //                                             withScale:3];
    
    _coreImageView.image = imgAdaptiveQRCode;
    //设置图片视图的圆角边框效果
    _coreImageView.layer.masksToBounds = YES;
    _coreImageView.layer.cornerRadius = 5.0;
    _coreImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    _coreImageView.layer.borderWidth = 2.0;
}

#pragma mark - 性别
- (void)setSex{
    
    self.navigationItem.rightBarButtonItem = nil;
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 15, SCREEN_WIDTH, 101)];
    view.backgroundColor = [UIColor whiteColor];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 50, SCREEN_WIDTH, 0.6)];
    lineView.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:0.6];
    lineView.alpha = 6.0;
    
    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.6)];
    lineView1.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:0.5];
    lineView1.alpha = 2.0;
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 100.4, SCREEN_WIDTH, 0.6)];
    lineView2.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:0.5];
    lineView2.alpha = 2.0;
    
    UILabel *label1 = [[UILabel alloc]initWithFrame:CGRectMake(15, 5, 30, 40)];
    label1.text = @"男";
    
    UILabel *label2 = [[UILabel alloc]initWithFrame:CGRectMake(15, 55, 30, 40)];
    label2.text = @"女";
    
    UIButton *button1 = [UIButton buttonWithType:UIButtonTypeSystem];
    button1.frame = CGRectMake(0, 0, SCREEN_WIDTH, 50);
    button1.tag   = 100;
    button1.backgroundColor = [UIColor clearColor];
    [button1 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    button2.frame = CGRectMake(0, 50, SCREEN_WIDTH, 50);
    button2.tag   = 200;
    button2.backgroundColor = [UIColor clearColor];
    [button2 addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    button3.frame = CGRectMake(SCREEN_WIDTH - 50, 15, 25, 25);
    [button3 setBackgroundImage:[UIImage imageNamed:@"check_phoneNum"] forState:UIControlStateNormal];
    
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeSystem];
    button4.frame = CGRectMake(SCREEN_WIDTH - 50, 65, 25, 25);
    [button4 setBackgroundImage:[UIImage imageNamed:@"check_phoneNum"] forState:UIControlStateNormal];
    
    if ([self.cell.detailTextLabel.text isEqualToString:@"男"]) {
        button3.hidden = NO;
        button4.hidden = YES;

    }else if ([self.cell.detailTextLabel.text isEqualToString:@"女"]) {
        button3.hidden = YES;
        button4.hidden = NO;

    }else{
        button3.hidden = YES;
        button4.hidden = YES;
    }
    
    [view addSubview:label1];
    [view addSubview:label2];
    [view addSubview:lineView];
    [view addSubview:lineView1];
    [view addSubview:lineView2];
    [view addSubview:button1];
    [view addSubview:button2];
    [view addSubview:button3];
    [view addSubview:button4];
    [self.view addSubview:view];
    
}

#pragma mark - 地区

- (void)setArea{
    self.navigationItem.rightBarButtonItem = nil;
    
    self.myTableView.backgroundColor = [UIColor  colorWithHexString:@"EFEFF4"];
}

#pragma mark - 个性签名

- (void)setSignature{
    
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, 80)];
    view.backgroundColor = [UIColor whiteColor];

    UIView *lineView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.6)];
    lineView1.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:0.5];
    lineView1.alpha = 2.0;
    
    UIView *lineView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 79.4, SCREEN_WIDTH, 0.6)];
    lineView2.backgroundColor = [UIColor colorWithRed:165.0/255 green:165.0/255 blue:165.0/255 alpha:0.5];
    lineView2.alpha = 2.0;
    
    _textView = [[UITextView alloc]initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30, 80)];
    [_textView becomeFirstResponder];
    _textView.font = [UIFont systemFontOfSize:17];
    _textView.text = self.cell.detailTextLabel.text;
    
    [view addSubview:_textView];
    [view addSubview:lineView1];
    [view addSubview:lineView2];
   
    [self.view addSubview:view];
}

#pragma mark - action

- (void)click:(UIButton *)button{
    
    switch (button.tag) {
        case 100:
            self.cell.detailTextLabel.text = @"男";
            break;
        case 200:
            self.cell.detailTextLabel.text = @"女";
            break;
            
        default:
            break;
    }
    
    
    [self.cell layoutSubviews];
    
    [self didFinish];
    
//    [self updateInformation:self.cell.detailTextLabel.text forKey:@"sex"];
   
}

- (IBAction)saveAction:(id)sender {
    
    if (self.cell.tag == 1) {
        if (self.textField.text.length < 1)
        {
            [QYHProgressHUD showErrorHUD:nil message:@"昵称不能为空"];
            return;
        }
        
        if (self.textField.text.length > 10) {
            [QYHProgressHUD showErrorHUD:nil message:@"昵称不能超过10个字符"];
            return;
        }
        
        self.cell.detailTextLabel.text = self.textField.text;
        
    }else{
        if (self.textView.text.length < 1)
        {
            [QYHProgressHUD showErrorHUD:nil message:@"个性签名不能为空"];
            return;
        }
    
        self.cell.detailTextLabel.text = self.textView.text;
    }
    
    
    [self.cell layoutSubviews];
    
    [self didFinish];
}

- (void)didFinish{
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        NSLog(@"上传我的信息成功");
        
        [self.navigationController popViewControllerAnimated:YES];
        
        if ([self.delegate respondsToSelector:@selector(didFinishedSave)]) {
            [self.delegate didFinishedSave];
        }
        
    }else{
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [QYHProgressHUD showErrorHUD:nil message: @"更改我的信息失败"];
    }

}
    
//    [self updateInformation:self.cell.tag == 1 ? self.textField.text:self.textView.text forKey:self.cell.tag == 1 ? @"nickName":@"personalSignature"];
//    
//}
//
//#pragma mark - 保存到服务器
//
//- (void)updateInformation:(NSString *)value forKey:(NSString *)key{
//    
//    __weak typeof(self) weakself = self;
//    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    
//    NSString *fileName = @"information.json";
//    
//    NSUserDefaults *userinfo     = [NSUserDefaults standardUserDefaults];
//    NSDictionary *informationDic = [[userinfo objectForKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]] mutableCopy];
//    [informationDic setValue:value forKey:key];
//    
//    NSString *str = [NSString dictionaryToJson:informationDic];
//    
//    NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:[QYHAccount shareAccount].loginUser data:data Success:^(id responseObject) {
//        
//        if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
//            
//            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//            
//            NSDictionary *informationDic = [userinfo objectForKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]];
//            [informationDic setValue:value forKey:key];
//
//            self.cell.detailTextLabel.text = value;
//            
//            NSLog(@"上传我的信息成功");
//            //成功就能保存
//            NSUserDefaults *userinfo = [NSUserDefaults standardUserDefaults];
//            [userinfo setObject:informationDic forKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]];
//            
//            [weakself.navigationController popViewControllerAnimated:YES];
//            
//            if ([weakself.delegate respondsToSelector:@selector(didFinishedSave)]) {
//                [weakself.delegate didFinishedSave];
//            }
//            
//        }else{
//            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//            [QYHProgressHUD showErrorHUD:nil message: @"更改我的信息失败"];
//        }
//        
//    } failure:^(NSError *error) {
//        
//        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//        [QYHProgressHUD showErrorHUD:nil message: @"更改我的信息失败"];
//        NSLog(@"上传我的信息失败");
//    }];
//
//}

-(void)dealloc{
    NSLog(@"QYHEditTableViewController-dealloc");
}

@end
