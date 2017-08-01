//
//  QYHMeTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/23.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHMeTableViewController.h"
#import "UIImageView+WebCache.h"
#import "QYHSetTableViewController.h"
#import "QYHProfileTableViewController.h"
#import "XMPPvCardTemp.h"
#import "QYHSCanViewController.h"
#import "QYHDiscoverViewController.h"

@interface QYHMeTableViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageVeiw;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end

@implementation QYHMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    /**
     *  如果没有上传过头像就要上传
     */
//    XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
    XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
    NSData *data   = myvCard.photo ? myvCard.photo : UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    
    if (!myvCard.photo) {
        
        NSString *fileName = @"headImage.jpeg";
        
        [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:nil data:data Success:^(id responseObject) {
            
            //获取当前电子名片
//            XMPPvCardTemp *myVCard = [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
            XMPPvCardTemp *myVCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
            
            //重新设置头像
            myVCard.photo = data;
            
            // 内部实现数据上传是把整个电子名片数据都从新上传了一次，包括图片
            [[QYHXMPPTool sharedQYHXMPPTool].vCard updateMyvCardTemp:myVCard];
            
            NSLog(@"如果没有上传过头像就要上传--上传成功");
            
        } failure:^(NSError *error) {
            
            NSLog(@"如果没有上传过头像就要上传--上传失败");
        } progress:^(CGFloat progress) {
            
        }];
        
    }else{
        NSString *path = [NSString stringWithFormat:@"%@%@headImage.jpeg",[QYHChatDataStorage shareInstance].homePath,[QYHAccount shareAccount].loginUser];
        [data writeToFile:path atomically:YES];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self getUserInfo];
    
}

- (void)getUserInfo
{
    
//    XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
    XMPPvCardTemp *myvCard = [[QYHXMPPvCardTemp shareInstance] vCard:nil];
    NSData *data   = myvCard.photo ? myvCard.photo : UIImageJPEGRepresentation([UIImage imageNamed:@"placeholder"], 1.0);
    
    self.headImageVeiw.layer.cornerRadius = 5;
    self.headImageVeiw.layer.masksToBounds = YES;
    self.headImageVeiw.layer.borderColor = [UIColor grayColor].CGColor;
    self.headImageVeiw.layer.borderWidth = 1.0;

    self.headImageVeiw.image = [UIImage imageWithData:data];
   
    
    self.nameLabel.text = myvCard.nickname ? [myvCard.nickname stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]: [QYHAccount shareAccount].loginUser;
    
    
    
//    //从数据库里取用户信息
//    
//    //获取登录用户信息的，使用电子名片模块
//    
//    // 登录用户的电子名片信息
//    // 1.它内部会去数据查找
//    XMPPvCardTemp *myvCard =  [QYHXMPPTool sharedQYHXMPPTool].vCard.myvCardTemp;
//    
//    // 获取头像
//    self.headImageVeiw.image = myvCard.photo ? [UIImage imageWithData:myvCard.photo] : [UIImage imageNamed:@"placeholder"];
//    self.headImageVeiw.layer.cornerRadius = 8;
//    self.headImageVeiw.clipsToBounds = YES;
//    // 为什么jid是空，原因是服务器返回的电子名片xmp数据没有JABBERJID的节点
//    //self.wechatNumLabel.text = myvCard.jid.user;
//    
//    NSLog(@"myvCard.nickname==%@",myvCard.nickname);
//    self.nameLabel.text = myvCard.nickname? myvCard.nickname:[QYHAccount shareAccount].loginUser;
//
}



#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0)
    {
        [self gotoProfileTableView];
        
    }else if (indexPath.section == 1)
    {
        [self gotoDiscoverVC];
    
    }else if (indexPath.section == 2)
    {
        [self gotoSCanVC];
        
    }else
    {
        switch (indexPath.row)
        {
            case 0:
                [self gotoSetTableView];
                break;
                
            default:
                break;
        }
        
    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)gotoProfileTableView
{
    QYHProfileTableViewController *profileVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHProfileTableViewController"];
    [self.navigationController pushViewController:profileVC animated:YES];
}

- (void)gotoDiscoverVC{
    
    QYHDiscoverViewController *discoverVC = [QYHDiscoverViewController shareIstance];
    [self.navigationController pushViewController:discoverVC animated:YES];
}

- (void)gotoSCanVC{
    
    QYHSCanViewController *scanVC = [[QYHSCanViewController alloc]init];
    [self.navigationController pushViewController:scanVC animated:YES];
}

- (void)gotoSetTableView
{
    QYHSetTableViewController *setVC = [self.storyboard instantiateViewControllerWithIdentifier:@"QYHSetTableViewController"];
    [self.navigationController pushViewController:setVC animated:YES];
}


//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}

 
@end
