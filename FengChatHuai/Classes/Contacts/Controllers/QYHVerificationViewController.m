//
//  QYHVerificationViewController.m
//  SmartCommunity
//
//  Created by iMacQIU on 16/6/31.
//  Copyright © 2016年 Horizontal. All rights reserved.
//

#import "QYHVerificationViewController.h"
#import "NSString+Additions.h"
#import "QYHChatMssegeModel.h"

//typedef NS_ENUM(NSUInteger, AddFriendStatus)
//{
//    AddFriendNormer =0,
//    AddFriendAgreed =1,
//    AddFriendReject =2
//};

@interface QYHVerificationViewController ()<UITextViewDelegate,UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *friendNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *applyContentTextView;
@property (weak, nonatomic) IBOutlet UILabel *placeHolder;

@end

@implementation QYHVerificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.friendNameLabel.adjustsFontSizeToFitWidth = YES;
    self.friendNameLabel.text = _friendName;
    
    [self setUp];
    
}


#pragma mark set up

- (void)setUp
{
    self.title = @"信息验证";
    self.placeHolder.text  = @"我是...";
}


- (IBAction)cancelAction:(id)sender {
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}



- (IBAction)suerAction:(id)sender {
    
    NSString *comments = self.applyContentTextView.text.length ? self.applyContentTextView.text:@"我是...";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[QYHXMPPTool sharedQYHXMPPTool].roster subscribePresenceToUser:_userJid];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [self sendMessage:_userJid content:comments];
        
        UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"温馨提示" message:@"申请信息已发生，请等待对方同意" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        av.tag = 100;
        [av show];
        
    });
    
}

//发送信息
- (void)sendMessage:(XMPPJID *)jid content:(NSString *)content
{
    
    NSDictionary *bodyDic;
    
    NSString *curentTime = [NSString formatCurDate];
    
    bodyDic = @{@"type":@(SendAddFriend),
                @"messegeID":[NSString acodeId],
                @"time":curentTime,
                @"isRead":@(NO),
                @"status":@(AddFriendNormer),
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


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (alertView.tag == 100)
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
}


#pragma mark textView的代理方法
- (void)textViewDidBeginEditing:(UITextView *)textView{
    
   if (self.placeHolder.hidden == NO) {
        
        [self.placeHolder setHidden:YES];
        
    }else{
        
        return;
    }
    
    
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    
    if ([self.applyContentTextView.text isEqualToString:@""]) {
        
        [self.placeHolder setHidden:NO];
    }
    
    
}



-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
    
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
