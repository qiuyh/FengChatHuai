//
//  QYHProfileTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHProfileTableViewController.h"
#import "QYHEditTableViewController.h"
#import "XMPPvCardTemp.h"
#import "QYHSetViewController.h"

@interface QYHProfileTableViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,QYHEditTableViewControllerDelegate,QYHSetViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;//头像
@property (weak, nonatomic) IBOutlet UILabel *nicknameLabel;//名称
@property (weak, nonatomic) IBOutlet UILabel *myQRcodeLabel;//二维码
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;//账号
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;//性别
@property (weak, nonatomic) IBOutlet UILabel *areaLabel;//地址
@property (weak, nonatomic) IBOutlet UILabel *personalSignatureLabel;//个人签名

@end

@implementation QYHProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.avatarImgView.layer.cornerRadius = 5;
    self.avatarImgView.layer.masksToBounds = YES;
    self.avatarImgView.layer.borderColor = [UIColor grayColor].CGColor;
    self.avatarImgView.layer.borderWidth = 1.0;
    
}

    
    // 1.它内部会去数据查找
    //
//    // 获取头像
//   self.avatarImgView.image = myvCard.photo ? [UIImage imageWithData:myvCard.photo] : [UIImage imageNamed:@"placeholder"];
//    self.avatarImgView.layer.cornerRadius = 8;
//    self.avatarImgView.clipsToBounds = YES;
//    // 账号
//    self.accountLabel.text =[QYHAccount shareAccount].loginUser;
//    
//    self.nicknameLabel.text = myvCard.nickname;
//    
//    //公司
//    self.orgNameLabel.text = myvCard.orgName;
//    
//    //部门
//    if (myvCard.orgUnits.count > 0) {
//        self.departmentLabel.text = myvCard.orgUnits[0];
//    }
//    
//    //职位
//    self.titleLabel.text = myvCard.title;
//    
//    //电话
//    NSArray *tels = myvCard.telecomsAddresses;
//    if (tels.count > 0) {
//        self.telLabel.text = tels[0];;
//    }
//    
//    //邮箱
//    NSArray *emails = myvCard.emailAddresses;
//    if (emails.count > 0) {
//        self.emailLabel.text = emails[0];;
//    }


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    
//    XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
    XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
    
    NSData *data   = myvCard.photo ? myvCard.photo : UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);

    self.avatarImgView.image = [UIImage imageWithData:data];
    
    
    NSString *account  = [QYHAccount shareAccount].loginUser;
    NSString *nickName = myvCard.nickname ? [myvCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//名字
    NSString *sex      = myvCard.formattedName ? [myvCard.formattedName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//性别
    NSString *area     = myvCard.givenName ? [myvCard.givenName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//地区
    NSString *personalSignature = myvCard.middleName ? [myvCard.middleName stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]:@"";//个性签名
    
    
    self.nicknameLabel.text  =  nickName;
    self.accountLabel.text   =  account;
    self.sexLabel.text       =  sex;
    self.areaLabel.text      =  area;
    self.personalSignatureLabel.text  =  personalSignature;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //获取cell
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    switch (cell.tag) {
        case 0:
            [self updateAvatarImage];
            break;
        case 1:
        case 2:
        case 4:
        case 6:
            [self gotoEditeView:cell];
            break;
        case 5:
            [self gotoSetArea:cell];
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)updateAvatarImage
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相",@"图片库", nil];
    [sheet showInView:self.view];
}


- (void)gotoEditeView:(UITableViewCell *)cell
{
    QYHEditTableViewController *editVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHEditTableViewController"];
    
    editVC.cell = cell;
    editVC.delegate = self;
    
    [self.navigationController pushViewController:editVC animated:YES];
}

- (void)gotoSetArea:(UITableViewCell *)cell{
    QYHSetViewController *areaVC = [[QYHSetViewController alloc]init];
    
    areaVC.cell = cell;
    areaVC.delegate = self;
    
    [self.navigationController pushViewController:areaVC animated:YES];
}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 2) return;
    
    // 图片选择器
    UIImagePickerController *imgPC = [[UIImagePickerController alloc] init];
    
    //设置代理
    imgPC.delegate = self;
    
    //允许编辑图片
    imgPC.allowsEditing = YES;
    
    if (buttonIndex == 0) {//照相
        imgPC.sourceType =  UIImagePickerControllerSourceTypeCamera;
    }else{//图片库
        imgPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    //显示控制器
    [self presentViewController:imgPC animated:YES completion:nil];
}


#pragma mark 图片选择器的代理
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //获取修改后的图片
    UIImage *editedImg = info[UIImagePickerControllerEditedImage];
    
    //把图片转为二进制数据
    NSData *data = UIImageJPEGRepresentation(editedImg, 0.1);
    
    [self uploadfile:data];
    
    //移除图片选择的控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

/**
 *  上传照片
 */
- (void)uploadfile:(NSData *)data{
    
    __weak typeof (self) weakself = self;
    
    NSString *fileName = @"headImage.jpeg";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:nil data:data Success:^(id responseObject) {
        
        if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            
            weakself.avatarImgView.image = [UIImage imageWithData:data];
            //
            NSString *path = [NSString stringWithFormat:@"%@%@headImage.jpeg",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
            [data writeToFile:path atomically:YES];
            
            [weakself didFinishedSave];
            
            [QYHProgressHUD showSuccessHUD:nil message:@"上传成功"];
            
        }else{
            
            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
            
            [QYHProgressHUD showErrorHUD:nil message:@"上传失败"];
        }
        
    } failure:^(NSError *error) {
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        [QYHProgressHUD showErrorHUD:nil message:@"上传失败"];
    } progress:^(CGFloat progress) {
        
    }];
    
}


#pragma mark 编辑电子名片控制器的代理
-(void)didFinishedSave{
    
    if (![[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
        
        [QYHProgressHUD showErrorHUD:nil message:@"网络未连接！"];
        return;
    }
    //获取当前电子名片
    XMPPvCardTemp *myVCard = [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
    
    //重新设置头像
    myVCard.photo = UIImageJPEGRepresentation(self.avatarImgView.image, 0.75);
    
    //重新设置myVCard里的属性
    myVCard.nickname       = [self.nicknameLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//名字
    myVCard.formattedName  = [self.sexLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//性别
    myVCard.givenName      = [self.areaLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//地区
    myVCard.middleName     = [self.personalSignatureLabel.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];//个性签名
    
    //        myVCard.familyName     = self.orgNameLabel.text;
    //        myVCard.prefix         = self.orgNameLabel.text;
    //        myVCard.suffix         = self.orgNameLabel.text;
    
    
    //把数据保存到服务器
    // 内部实现数据上传是把整个电子名片数据都从新上传了一次，包括图片
    [[QYHXMPPTool sharedQYHXMPPTool].vCard updateMyvCardTemp:myVCard];
    
    
    //归档保存
    [QYHXMPPvCardTemp shareInstance].vCard = myVCard;
    
    [[QYHXMPPvCardTemp shareInstance] setVCard:[QYHXMPPvCardTemp shareInstance] byUser:nil];
}


@end
