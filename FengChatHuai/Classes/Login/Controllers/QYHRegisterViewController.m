//
//  QYHRegisterViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHRegisterViewController.h"
#import "QYHKeyBoardManager.h"

@interface QYHRegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumberTextField;//手机号码

@property (weak, nonatomic) IBOutlet UITextField *accountTextField;//密码

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;//再次输的密码

@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@end

@implementation QYHRegisterViewController

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
    
    self.phoneNumberTextField.text = _phoneNumber;
    
    self.title = _isResetPassword ? @"重置密码":@"注册";

    [self.finishButton setTitle:_isResetPassword ? @"完成":@"注册" forState:UIControlStateNormal];
}


- (IBAction)registerAction:(id)sender {
    //注册
    
    // 1.判断有没有输入用户名和密码
    if (self.accountTextField.text.length == 0) {
        NSLog(@"请求输入用户名和密码");
        [QYHProgressHUD showErrorHUD:nil message:@"请输入密码！"];
        return;
    }
    
    if (![self.accountTextField.text isEqualToString:self.passwordTextField.text]) {
        [QYHProgressHUD showErrorHUD:nil message:@"两次输入的密码不正确！"];
        return;
    }

    
//    self.phoneNumberTextField.text = self.accountTextField.text;
    
    
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    if (_isResetPassword) {
        /**
         *  重置密码
         */
        
        [self resetPassword];
    }else{
        /**
         *  注册
         */
        
        // 保存注册的用户名和密码
        [QYHAccount shareAccount].registerUser = self.phoneNumberTextField.text;
        [QYHAccount shareAccount].registerPwd  = self.passwordTextField.text;
        
        [self handleXMPPResult];
        
    }
}


#pragma mark 处理注册的结果
-(void)handleXMPPResult{
    
    //在主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
        
        
        NSString *fileName = @"login.json";
        
//        NSString *imageUrl = [NSString stringWithFormat:@"http://7xt8p0.com2.z0.glb.qiniucdn.com/%@headImage.jpeg",self.phoneNumberTextField.text];
        
        NSString *passWord  = self.passwordTextField.text;
        
        NSDictionary *dic   = @{@"passWord"    : passWord,
                                @"xmppPassWord": passWord,
                                };
        
        NSString *str = [NSString dictionaryToJson:dic];
        
        NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
        
        __weak typeof (self) weakself = self;
        
        //        NSLog(@"fileName==%@,self.phoneNumberTextField.text ==%@,data==%@",fileName,self.phoneNumberTextField.text,data );
        [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:self.phoneNumberTextField.text data:data Success:^(id responseObject) {
            
            [QYHXMPPTool sharedQYHXMPPTool].registerOperation = YES;
            [[QYHXMPPTool sharedQYHXMPPTool] xmppRegister:^(XMPPResultType resultType) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [MBProgressHUD hideHUDForView:weakself.view animated:YES];
                    
                    if (resultType == XMPPResultTypeRegisterSucess) {
                        [QYHProgressHUD showSuccessHUD:nil message:@"注册成功！"];
                        
                        [QYHAccount shareAccount].loginUser = weakself.phoneNumberTextField.text;
                        [QYHAccount shareAccount].loginPwd  = weakself.passwordTextField.text;
                        
                        //                //保存xmpp登录的密码
                        //                NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                        //                [userDefault setObject:weakself.passwordTextField.text forKey:[NSString stringWithFormat:@"xmppPassWord%@",weakself.phoneNumberTextField.text]];
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            
                            [weakself.navigationController popToRootViewControllerAnimated:YES];
                        });
                    }else{
                        [QYHProgressHUD showErrorHUD:nil message:@"用户名重复"];
                    }
                    
                });
                
            }];
            
        } failure:^(NSError *error) {
            
            NSDictionary *err = error.userInfo;
            
            [MBProgressHUD hideAllHUDsForView:weakself.view animated:YES];
            
            
            if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
            {
                [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
                
            }else
            {
                
                [QYHProgressHUD showErrorHUD:nil message:@"注册失败"];
            }
            
            NSLog(@"注册失败error==%@",error);
            
        } progress:^(CGFloat progress) {
            
        }];
        
    });
}

- (void)resetPassword{
    
    
    if (![QYHAccount shareAccount].xmppLoginPwd) {
        [self getXmppPassWord];
    }else{
        [self uploadPassWord];
    }
    
    
}

- (void)getXmppPassWord{
    
    __weak typeof(self) weakself = self;
    
    NSString *fileName1 = @"login.json";
    
    [[QYHQiNiuRequestManarger shareInstance]getFile:fileName1 withphotoNumber:self.phoneNumberTextField.text Success:^(id responseObject) {
        
        NSString *xmppPwd = [responseObject objectForKey:@"xmppPassWord"];
        [QYHAccount shareAccount].xmppLoginPwd = xmppPwd;
        
        [weakself uploadPassWord];
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        
        NSDictionary *err = error.userInfo;
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
            
        }else   if ([err[@"NSLocalizedDescription"] isEqualToString:@"Request failed: not found (404)"]){
            [QYHProgressHUD showErrorHUD:nil message:@"该手机未注册，请注册再登录"];
        }else{
            [QYHProgressHUD showErrorHUD:nil message:@"未知错误"];
        }
    }];
}

- (void)uploadPassWord{
    
    NSString *fileName  = @"login.json";
    
    NSString *passWord  = self.passwordTextField.text;
    
    NSDictionary *dic   = @{@"passWord"    : passWord,
                            @"xmppPassWord": [QYHAccount shareAccount].xmppLoginPwd,
                            };
    
    NSString *str = [NSString dictionaryToJson:dic];
    
    NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    __weak typeof (self) weakself = self;
    
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:self.phoneNumberTextField.text data:data Success:^(id responseObject) {
        
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        
        [QYHProgressHUD showSuccessHUD:nil message:@"重置密码成功"];
        
        [QYHAccount shareAccount].loginPwd  = weakself.passwordTextField.text;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [weakself.navigationController popViewControllerAnimated:YES];
        });
        
    } failure:^(NSError *error) {
        
        NSDictionary *err = error.userInfo;
        
        [QYHProgressHUD hideAllHUDsForView:weakself.view animated:YES];
        
        
        if ([err[@"NSLocalizedDescription"] isEqualToString:@"The Internet connection appears to be offline."])
        {
            [QYHProgressHUD showErrorHUD:nil message:@"网络连接失败"];
            
        }else
        {
            
            [QYHProgressHUD showErrorHUD:nil message:@"重置密码失败!"];
        }
        
        NSLog(@"重置密码失败error==%@",error);
        
    } progress:^(CGFloat progress) {
        
    }];
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
