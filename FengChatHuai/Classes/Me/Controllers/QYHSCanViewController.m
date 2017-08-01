//
//  QYHSCanViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/5.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHSCanViewController.h"
#import "QYHEditTableViewController.h"
#import "QYHDetailTableViewController.h"
#import "QYHResultFromScanViewController.h"

@interface QYHSCanViewController ()<AVCaptureMetadataOutputObjectsDelegate>

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;
@property (nonatomic,strong) UIImageView * QRCScanLineImageView;
@property (nonatomic,strong) NSTimer * scanerTimer;
@property (nonatomic,strong) UIView *bgView;
@property (nonatomic,strong)UIActivityIndicatorView *activity;
@property (nonatomic,assign)BOOL isFirst;

@end

@implementation QYHSCanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    
    self.title = @"扫一扫";
    
    _bgView = [[UIView alloc]initWithFrame:self.view.bounds];
    _bgView.backgroundColor = [UIColor blackColor];
    
    _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _activity.frame = CGRectMake(SCREEN_WIDTH/2.0-10, SCREEN_HEIGHT/2.0-10, 20, 20);
    [_activity startAnimating];
    
    UILabel* tiplabel = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT/2.0+30, SCREEN_WIDTH, 21)];
    tiplabel.text = @"正在加载...";
    tiplabel.font = [UIFont systemFontOfSize:15];
    [tiplabel setTextColor:[UIColor whiteColor]];
    [tiplabel setTextAlignment:NSTextAlignmentCenter];
    
    
    [_bgView addSubview:_activity];
    [_bgView addSubview:tiplabel];
    [self.view addSubview:_bgView];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    if (!_isFirst) {
        
        _isFirst = YES;
        [self getSCanView];
    }
}

- (void)getSCanView{
    
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
    
    //连接输入和输出
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    // 设置条码类型
    _output.metadataObjectTypes =@[AVMetadataObjectTypeQRCode];
    
    
    CGFloat ORX = (SCREEN_WIDTH - 280) * 0.5;
    CGFloat ORY = (SCREEN_HEIGHT - 280) * 0.5;
    
    //设置扫描区域
    CGFloat width = 280/self.view.bounds.size.width;
    CGFloat height = 280/self.view.bounds.size.height;
    CGFloat x = ((self.view.bounds.size.width - 280) * 0.5) / self.view.bounds.size.width;
    CGFloat y = ((self.view.bounds.size.height - 280) * 0.5) / self.view.bounds.size.height;
    
    
    
    _output.rectOfInterest = CGRectMake(y, x, height, width);
    
    //添加遮盖
    [self addOtherLay:CGRectMake(ORX, ORY, 280, 280)];
    
    
    //添加扫描框与动画
    UIImageView *QRCScanBoxImageView = [[UIImageView alloc] initWithFrame:CGRectMake(ORX, ORY, 280, 280)];
    
    [QRCScanBoxImageView setImage:[UIImage imageNamed:@"qrcode_scan_bg"]];
    
    [self.view addSubview:QRCScanBoxImageView];
    
    self.QRCScanLineImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 2)];
    
    [self.QRCScanLineImageView setCenter:CGPointMake(ORX + 140, ORY)];
    
    
    [self.QRCScanLineImageView setImage:[UIImage imageNamed:@"qrcode_scan_line"]];
    
    [self.view addSubview:self.QRCScanLineImageView];
    
    self.scanerTimer =[NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(scanLineScan) userInfo:nil repeats:YES];
    
    [self.scanerTimer fire];
    
    
    //    //添加准星
    //    UIImageView * QRCPointingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //    [QRCPointingImageView setImage:[UIImage imageNamed:@"扫描二维码准星"]];
    //    [QRCPointingImageView setCenter: CGPointMake(ORX + 140, ORY+140)];
    //    [self.view addSubview:QRCPointingImageView];
    //
    //    //运行
    //    [_QRCodeCaptureSession startRunning];
    
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT*0.8, SCREEN_WIDTH, 50)];
    label.text = @"将二维码放入框里，即可自动扫描";
    label.font = [UIFont systemFontOfSize:14];
    [label setTextColor:[UIColor whiteColor]];
    [label setTextAlignment:NSTextAlignmentCenter];
    
    
    [self.view addSubview:label];
    
    
    
    UIButton *myQRcodeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    myQRcodeButton.frame = CGRectMake(0, SCREEN_HEIGHT*0.9, SCREEN_WIDTH, 50);
    [myQRcodeButton setTitle:@"我的二维码" forState:UIControlStateNormal];
    [myQRcodeButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [myQRcodeButton addTarget:self action:@selector(gotoMyQRcodeVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:myQRcodeButton];
    
    // 添加扫描画面
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity =AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.view.layer.bounds;
    [self.view.layer insertSublayer:_preview atIndex:0];
    //开始扫描
    [_session startRunning];
    
    [_bgView removeFromSuperview];
}

-(void) scanLineScan{
    [self.QRCScanLineImageView setCenter:CGPointMake((SCREEN_WIDTH - 280) * 0.5 + 140, (SCREEN_HEIGHT -280) *0.5)];
    
    [UIView animateWithDuration:4.0 animations:^{
        [self.QRCScanLineImageView setCenter:CGPointMake((SCREEN_WIDTH - 280) * 0.5 + 140, (SCREEN_HEIGHT -280) *0.5 +280)];
        
    }];
    
}

- (void)addOtherLay:(CGRect)rect
{
    //Rect为保留的矩形frame值
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat leftWidth = (screenWidth - rect.size.width) * 0.5;
    
    CAShapeLayer *layerTop = [CAShapeLayer layer];
    layerTop.fillColor = [UIColor blackColor].CGColor;
    layerTop.opacity = 0.5;
    layerTop.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, screenWidth, rect.origin.y)].CGPath;
    [self.view.layer addSublayer:layerTop];
    
    CAShapeLayer *layerLeft = [CAShapeLayer layer];
    layerLeft.fillColor = [UIColor blackColor].CGColor;
    layerLeft.opacity = 0.5;
    layerLeft.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, rect.origin.y, leftWidth, rect.size.height)].CGPath;
    [self.view.layer addSublayer:layerLeft];
    
    CAShapeLayer *layerRight = [CAShapeLayer layer];
    layerRight.fillColor = [UIColor blackColor].CGColor;
    layerRight.opacity = 0.5;
    layerRight.path = [UIBezierPath bezierPathWithRect:CGRectMake(screenWidth - leftWidth, rect.origin.y, leftWidth, rect.size.height)].CGPath;
    [self.view.layer addSublayer:layerRight];
    
    CAShapeLayer *layerBottom = [CAShapeLayer layer];
    layerBottom.fillColor = [UIColor blackColor].CGColor;
    layerBottom.opacity = 0.5;
    layerBottom.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, CGRectGetMaxY(rect), screenWidth, screenHeight - CGRectGetMaxY(rect))].CGPath;
    [self.view.layer addSublayer:layerBottom];
    
}


#pragma mark - AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [QYHProgressHUD showErrorHUD:nil message:@"网络未连接！"];
        
    }else{
        
        
        NSString *stringValue;
        if ([metadataObjects count] >0){
            //停止扫描
            [_session stopRunning];
            
            AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
            stringValue = metadataObject.stringValue;
            
            NSDictionary *dic  = [NSDictionary dictionaryWithJsonString:stringValue];
            
            if (!dic) {
                
                QYHResultFromScanViewController *resultVC = [[QYHResultFromScanViewController alloc]init];
                resultVC.tipInformation = stringValue;
                [self.navigationController pushViewController:resultVC animated:YES];
                
//                [self.navigationController popViewControllerAnimated:YES];
//                
//                [QYHProgressHUD showErrorHUD:nil message:@"此二维码扫描只支持该软件的二维码！"];
                
                return;
            }
            
            NSString *nickName = [dic objectForKey:@"nickName"];
            NSString *sex      = [dic objectForKey:@"sex"];
            NSString *area     = [dic objectForKey:@"area"];
            NSString *phone    = [dic objectForKey:@"phone"];
            NSString *personalSignature = [dic objectForKey:@"personalSignature"];
            NSString *imageUrl = [dic objectForKey:@"imageUrl"];
          
            if (nickName&&sex&&area&&phone&&personalSignature&&imageUrl) {
                
                UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                QYHDetailTableViewController *detailVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHDetailTableViewController"];
                
                detailVC.dic = dic;
                detailVC.isFromSC = YES;
                //        detailVC.index    = 0;
                
                [self.navigationController pushViewController:detailVC animated:YES];
                
                
                NSLog(@"stringValue==%@,,,dic == %@",stringValue,dic);
                
            }else{
                
                QYHResultFromScanViewController *resultVC = [[QYHResultFromScanViewController alloc]init];
                resultVC.tipInformation = stringValue;
                [self.navigationController pushViewController:resultVC animated:YES];
                
//                [self.navigationController popViewControllerAnimated:YES];
//                
//                [QYHProgressHUD showErrorHUD:nil message:@"此二维码扫描只支持该软件的二维码！"];
                
                return;
            }
        }
        
    }
}

- (void)gotoMyQRcodeVC
{
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QYHEditTableViewController *editVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"QYHEditTableViewController"];
    
    editVC.tag = 2;
    
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
