//
//  QYHSetTableViewController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/24.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHSetTableViewController.h"
#import "QYHContenViewController.h"
#import "QYHDiscoverViewController.h"

@interface QYHSetTableViewController ()

@end

@implementation QYHSetTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title  =@"设置";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    switch (section)
    {
        case 0:
            return 3;
            break;
            
        default:
            return 2;
            break;
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section ==0)
    {
        
    }else
    {
        switch (indexPath.row)
        {
            case 0:
                
                break;
                
            default:
                
                [self logoutBtnClick];
                break;
        }

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
   
}

- (void)logoutBtnClick{
    
    //注销
    [[QYHXMPPTool sharedQYHXMPPTool] xmppLogout];
    
    // 注销的时候，把沙盒的登录状态设置为NO
    [QYHAccount shareAccount].login = NO;
    [[QYHAccount shareAccount] saveToSandBox];
    
    [QYHContenViewController attemptDealloc];
    [QYHDiscoverViewController attemptDealloc];
    
    //回登录的控制器
    [UIStoryboard showInitialVCWithName:@"Login"];
    
}


/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
