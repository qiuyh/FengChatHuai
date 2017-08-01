//
//  QYHUploadHeadImageTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/9/13.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHUploadHeadImageTableViewController.h"
#import "QYHDiscoverViewController.h"
#import "QYHOtherInformationViewController.h"

@interface QYHUploadHeadImageTableViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@end

@implementation QYHUploadHeadImageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

#pragma mark - 更改相册封面

- (void)uploadFriendHeadImage:(NSData *)data{
    
    __weak typeof (self) weakself = self;
    
    NSString *fileName = @"friendHeadImage.jpeg";
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:nil data:data Success:^(id responseObject) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            [QYHProgressHUD showSuccessHUD:nil message:@"更换相册封面成功"];
            
             NSString *path = [NSString stringWithFormat:@"%@%@friendHeadImage.jpeg",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
            [data writeToFile:path atomically:YES];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (weakself.isFromDiscoverVC) {
                    QYHDiscoverViewController *disVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
                    [disVC getFriendHeadImage];
                    [weakself.navigationController popToViewController:disVC animated:YES];
                }else{
                    QYHOtherInformationViewController *otherVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
                    [otherVC getFriendHeadImage];
                    otherVC.isRefreshDisVC = YES;
                    [weakself.navigationController popToViewController:otherVC animated:YES];
                }
            });
           
            NSLog(@"上传相册封面--上传成功");
        });
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:weakself.view animated:YES];
        [QYHProgressHUD showSuccessHUD:nil message:@"更换相册封面失败"];
        
        NSLog(@"上传相册封面--上传失败");
    } progress:^(CGFloat progress) {
        
    }];
}



#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取修改后的图片
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    
    //把图片转为二进制数据
    NSData *data = UIImageJPEGRepresentation(editedImg, 0.1);
    
    [self uploadFriendHeadImage:data];
    
    //移除图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // 图片选择器
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    
    //设置代理
    imgPC.delegate = self;
    
    //允许编辑图片
    imgPC.allowsEditing = YES;

    if (indexPath.row) {
        imgPC.sourceType =  UIImagePickerControllerSourceTypeCamera;
    }else{
        imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //显示控制器
    [self presentViewController:imgPC animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
