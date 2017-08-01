//
//  QYHResultFromScanViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/8/8.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHResultFromScanViewController.h"
#import "MLEmojiLabel.h"
#import "QYHWebViewController.h"

@interface QYHResultFromScanViewController ()<MLEmojiLabelDelegate,UIAlertViewDelegate>

@end

@implementation QYHResultFromScanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    self.title = @"提示";
    
    NSLog(@"self.tipInformation==%@",self.tipInformation);
    
    CGFloat height = [NSString getContentSize:self.tipInformation fontOfSize:18 maxSizeMake:CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - 80)].height + 10;
    
    MLEmojiLabel *label = [MLEmojiLabel new];
    label.frame = CGRectMake(0, 80, SCREEN_WIDTH, height);
    label.font = [UIFont systemFontOfSize:18];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.text = self.tipInformation;
    label.delegate = self;
    label.numberOfLines = 0;
    
    [self.view addSubview:label];
}


- (void)popAction{
    
    [self.navigationController popToRootViewControllerAnimated:YES];
 
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
}

#pragma mark - MLEmojiLabelDelegate

- (void)mlEmojiLabel:(MLEmojiLabel*)emojiLabel didSelectLink:(NSString*)link withType:(MLEmojiLabelLinkType)type
{
    switch(type){
        case MLEmojiLabelLinkTypeURL:
            [self pushToWebViewControllerByUrl:link];
            NSLog(@"点击了链接%@",link);
            break;
        case MLEmojiLabelLinkTypePhoneNumber:
            
            //拨打电话
        {
            UIAlertView *alerView = [[UIAlertView alloc]initWithTitle:nil message:link delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"呼叫", nil];
            [alerView show];
            NSLog(@"点击了电话%@",link);
            break;
        }
        case MLEmojiLabelLinkTypeEmail:
            NSLog(@"点击了邮箱%@",link);
            break;
        case MLEmojiLabelLinkTypeAt:
            NSLog(@"点击了用户%@",link);
            break;
        case MLEmojiLabelLinkTypePoundSign:
            NSLog(@"点击了话题%@",link);
            break;
        default:
            NSLog(@"点击了不知道啥%@",link);
            break;
    }
    
}

- (void)pushToWebViewControllerByUrl:(NSString *)url{
    
    QYHWebViewController *webVC = [[QYHWebViewController alloc]init];
    webVC.url = url;
    [self.navigationController pushViewController:webVC animated:YES];
}



#pragma mark - alerViewDelegage

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        
        if ([[UIApplication sharedApplication]canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]]) {
            [[UIApplication sharedApplication]openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",alertView.message]]];
            
        }
    }
}


@end
