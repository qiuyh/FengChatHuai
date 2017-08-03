//
//  QYHGetCodeViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/6/30.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHGetCodeViewController.h"
#import "QYHRegisterViewController.h"
#import <SMS_SDK/SMSSDK.h>
#import "QYHKeyBoardManager.h"

@interface QYHGetCodeViewController ()
{
    NSTimer *_timer;
    
    int _i;
}

@property (weak, nonatomic) IBOutlet UITextField *phoneNunberTextField;
@property (weak, nonatomic) IBOutlet UITextField *acodeTextField;
@property (weak, nonatomic) IBOutlet UIButton *getAcodeButton;

@end

@implementation QYHGetCodeViewController

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    [QYHKeyBoardManager shareInstance].selfView = self.view;
}


-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [QYHKeyBoardManager shareInstance].selfView = nil;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.getAcodeButton setBackgroundColor:[UIColor redColor]];
}

- (IBAction)getAcode:(id)sender {
    
    if (self.phoneNunberTextField.text.length<1) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入手机号码！"];
        return;
    }
    
    if (![NSString justMobile:self.phoneNunberTextField.text]) {
        [QYHProgressHUD showErrorHUD:nil message:@"不合法的手机号码！"];
        return;
    }
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakself = self;
    
    NSString *fileName1 = @"login.json";
    
    [[QYHQiNiuRequestManarger shareInstance]getFile:fileName1 withphotoNumber:self.phoneNunberTextField.text Success:^(id responseObject) {
        
        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
        
        if (_isResetPassword) {
            [weakself getVerificationCode];
        }else{
            [QYHProgressHUD showErrorHUD:nil message:@"该手机已注册，请直接登录"];
        }
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
        
        NSDictionary *err = error.userInfo;
        
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"])
        {
            
            if (!_isResetPassword) {
                [weakself getVerificationCode];
            }else{
                [QYHProgressHUD showErrorHUD:nil message:@"该手机未注册，请注册再试"];
            }
            
        }else
        {
            
            //            [QYHProgressHUD showHUDInView:self.view onlyMessage:@"登陆失败"];
        }
        NSLog(@"验证手机是否注册失败error==%@",error);
        
    }];
}


- (IBAction)nextAction:(id)sender {
    
    if (self.phoneNunberTextField.text.length<1) {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入手机号码！"];
        return;
    }
    
    if (![NSString justMobile:self.phoneNunberTextField.text]) {
        [QYHProgressHUD showErrorHUD:nil message:@"不合法的手机号码！"];
        return;
    }

    
    
    if (self.acodeTextField.text.length < 1)
    {
        [QYHProgressHUD showErrorHUD:nil message:@"请输入验证码！"];
        
        return;
        
    }
    
    [SMSSDK commitVerificationCode:self.acodeTextField.text phoneNumber:self.phoneNunberTextField.text zone:@"86" result:^(NSError *error) {
        
        if (!error) {
            NSLog(@"验证成功");
            
            QYHRegisterViewController *registerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHRegisterViewController"];
            registerVC.phoneNumber = self.phoneNunberTextField.text;
            registerVC.isResetPassword = _isResetPassword;
            [self.navigationController pushViewController:registerVC animated:YES];
        }
        else
        {
            NSLog(@"错误信息:%@",error);
            
            [QYHProgressHUD showErrorHUD:nil message:@"验证码错误"];
            
            return;

        }
    }];
    
}


- (void)getVerificationCode
{
    
    /**
     *  @from                    v1.1.1
     *  @brief                   获取验证码(Get verification code)
     *
     *  @param method            获取验证码的方法(The method of getting verificationCode)
     *  @param phoneNumber       电话号码(The phone number)
     *  @param zone              区域号，不要加"+"号(Area code)
     *  @param customIdentifier  自定义短信模板标识 该标识需从官网http://www.mob.com上申请，审核通过后获得。(Custom model of SMS.  The identifier can get it  from http://www.mob.com  when the application had approved)
     *  @param result            请求结果回调(Results of the request)
     */
    
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:self.phoneNunberTextField.text zone:@"86" customIdentifier:nil result:^(NSError *error) {
        
        if (!error)
        {
            _timer=[NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(changeTime) userInfo:nil repeats:YES];
            
            [QYHProgressHUD showHUDInView:nil onlyMessage:@"验证码已经发送至您的手机,60s后可以重新获取验证码"];

            NSLog(@"获取验证码成功");
            
        } else
        {
            if ([error.userInfo[@"getVerificationCode"] integerValue] == 408) {
                [QYHProgressHUD showHUDInView:nil onlyMessage:@"未能获取验证码，请重新获取"];
            }else{
                [QYHProgressHUD showHUDInView:nil onlyMessage:error.userInfo[@"getVerificationCode"]];
            }
            
            
            NSLog(@"错误信息：%@",error.userInfo[@"getVerificationCode"]);
        }}
     ];

}

//不断刷新数据
- (void)changeTime
{
    [self.getAcodeButton setTitle:[NSString stringWithFormat:@"%dS",(59-_i)] forState:UIControlStateDisabled];
    [self.getAcodeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
    [self.getAcodeButton setBackgroundColor:[UIColor grayColor]];
    self.getAcodeButton.enabled = NO;
    
    _i++;
    if (_i>59)
    {
        [self.getAcodeButton setBackgroundColor:[UIColor redColor]];
        self.getAcodeButton.enabled = YES;
        [_timer invalidate];
        _timer=nil;
        _i=0;
    }
    
}



@end
