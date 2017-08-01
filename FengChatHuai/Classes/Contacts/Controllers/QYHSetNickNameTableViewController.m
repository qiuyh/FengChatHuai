//
//  QYHSetNickNameTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/7/7.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHSetNickNameTableViewController.h"

@interface QYHSetNickNameTableViewController ()
@property (weak, nonatomic) IBOutlet UITextField *remarkNameLabel;

@end

@implementation QYHSetNickNameTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor greenColor];
    
    self.remarkNameLabel.text = self.remarkName;
    
    //添加键盘掉落事件(针对UIScrollView或者继承UIScrollView的界面)
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
}
- (IBAction)finishAction:(id)sender {
    
    
    if (self.remarkNameLabel.text.length < 1) {
        [QYHProgressHUD showErrorHUD:nil message: @"备注不能为空"];
        return;
    }
    
    if (self.remarkNameLabel.text.length > 10) {
        [QYHProgressHUD showErrorHUD:nil message:@"备注不能超过10个字符"];
        return;
    }
    
    __weak typeof(self) weakself = self;
    
//    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    /**
     *  修改备注
     */
    
    if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [[QYHXMPPTool sharedQYHXMPPTool].roster setNickname:[self.remarkNameLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] forUser:[XMPPJID jidWithUser:_fromID domain:[QYHAccount shareAccount].domain resource:nil]];
        
        NSLog(@"设置备注成功");
        
        if (weakself.block) {
            weakself.block(weakself.remarkNameLabel.text);
        }
        
        [weakself.navigationController popViewControllerAnimated:YES];
    }else{
        [QYHProgressHUD showErrorHUD:nil message: @"设置备注失败"];
    }
    
    
//    NSString *fileName = @"remarkName.json";
//    
//    NSUserDefaults *userRemark     = [NSUserDefaults standardUserDefaults];
//    NSDictionary *remarkNameDic = [userRemark objectForKey:[ NSString stringWithFormat:@"%@remarkName",[QYHAccount shareAccount].loginUser]];
//    [remarkNameDic setValue:self.remarkNameLabel.text forKey:_fromID];
//    
//    NSString *str = [NSString dictionaryToJson:remarkNameDic];
//    
//    NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
//    
//    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:[QYHAccount shareAccount].loginUser data:data Success:^(id responseObject) {
//        
//        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//        
//        NSLog(@"设置备注成功");
//        
//        if (weakself.block) {
//            weakself.block(weakself.remarkNameLabel.text);
//        }
//        
//        [weakself.navigationController popViewControllerAnimated:YES];
//        
//    } failure:^(NSError *error) {
//        
//        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//        [QYHProgressHUD showErrorHUD:nil message: @"设置备注失败"];
//        NSLog(@"设置备注失败");
//    }];

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
   [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}




@end
