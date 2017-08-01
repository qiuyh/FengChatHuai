//
//  QYHMainTabbarController.m
//  FengChatHuai
//
//  Created by iMacQIU on 16/5/20.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHMainTabbarController.h"
#import "QYHBaseNavigationController.h"
#import "QYHDiscoverViewController.h"

#define KNormalColor   [UIColor grayColor]
#define KSelectedColor [UIColor colorWithRed:0 green:(190 / 255.0) blue:(12 / 255.0) alpha:1]

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"

#define KItemButtonWith   49
#define KItemButtonHeight KItemButtonWith
#define KIdex        3


@interface QYHMainTabbarController ()<UITabBarDelegate>

{
    UIButton* _button;
    UIButton* _button1;
    
    BOOL _isFirst;
}

@property (nonatomic,strong) UIView *notReachableTipView;
@end

@implementation QYHMainTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isFirst = YES;
    
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(netWorkingChange:) name:KNetWorkingChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(logout) name:KReceiveErrorConflictNotification object:nil];
    
    
    //换tabbar的背景图
//        [self changeTabbarBackgroundImage];
    
    NSArray *childItemsArray = @[
                                 @{kClassKey  : @"QYHChatViewController",
                                   kTitleKey  : @"消息",
                                   kImgKey    : @"tabbar_mainframe",
                                   kSelImgKey : @"tabbar_mainframeHL"},
                                 
                                 @{kClassKey  : @"QYHContactsViewController",
                                   kTitleKey  : @"通讯录",
                                   kImgKey    : @"tabbar_contacts",
                                   kSelImgKey : @"tabbar_contactsHL"},
                                 
                                 @{kClassKey  : @"QYHMeTableViewController",
                                   kTitleKey  : @"我的",
                                   kImgKey    : @"tabbar_me",
                                   kSelImgKey : @"tabbar_meHL"} ];
    
    
    
    [childItemsArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        
        //纯代码
//        QYHBaseNavigationController *nav = (QYHBaseNavigationController *)[self getCodeBydict:dict];
        //storyboard
        QYHBaseNavigationController *nav = (QYHBaseNavigationController *)[self getStoryboardByIndex:idx dict:dict];
        
        UITabBarItem *item = nav.tabBarItem;
        
        if (idx == KIdex)
        {
            item.enabled = NO;
            
            //添加tabbar 凸出的按钮
            [self getItemButtonByIndex:idx dict:dict itemArray:childItemsArray];
            
        }else
        {
            item.title = dict[kTitleKey];
            item.image = [UIImage imageNamed:dict[kImgKey]];
            item.selectedImage = [[UIImage imageNamed:dict[kSelImgKey]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            [item setTitleTextAttributes:@{NSForegroundColorAttributeName : KNormalColor  } forState:UIControlStateNormal];
            [item setTitleTextAttributes:@{NSForegroundColorAttributeName : KSelectedColor} forState:UIControlStateSelected];
        }
        
    }];
  
}

- (void)logout{
    
    //注销
    [[QYHXMPPTool sharedQYHXMPPTool] xmppLogout];
    
    // 注销的时候，把沙盒的登录状态设置为NO
    [QYHAccount shareAccount].login = NO;
    [[QYHAccount shareAccount] saveToSandBox];
    
    //回登录的控制器
    [UIStoryboard showInitialVCWithName:@"Login"];

}

- (void)netWorkingChange:(NSNotification *)noti{
    
    BOOL isConeneting = [[noti object] boolValue];
    self.notReachableTipView.hidden = isConeneting;
    
    // 判断用户是否登录
    if([QYHAccount shareAccount].isLogin){
    //自动登录
        if (isConeneting) {
            
            if (_isFirst) {
                [[QYHXMPPTool sharedQYHXMPPTool] xmppLogin:^(XMPPResultType loginType) {
                    if (loginType == XMPPResultTypeLoginSucess) {
                        /**
                         *  朋友圈刷新
                         */
                        QYHDiscoverViewController *discoverVC = [QYHDiscoverViewController shareIstance];
                        discoverVC.isNeedRefresh = YES;
                        
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                             [[NSNotificationCenter defaultCenter] postNotificationName:KLoginSuccessNotification object:nil];
                        });
                       
                    }
                    
                }];
                _isFirst = NO;
            }
        }
    }
    
}

-(UIView *)notReachableTipView
{
    if (!_notReachableTipView) {
        _notReachableTipView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, 25)];
        _notReachableTipView.backgroundColor = [UIColor redColor];
        
        UILabel *tipLabel = [[UILabel alloc]initWithFrame:_notReachableTipView.bounds];
        tipLabel.text      = @"当前网络不可用，请检查你的网络设置";
        tipLabel.textColor = [UIColor whiteColor];
        tipLabel.font      = [UIFont systemFontOfSize:18];
        tipLabel.textAlignment = NSTextAlignmentCenter;
        [_notReachableTipView addSubview:tipLabel];
        
        [self.view addSubview:_notReachableTipView];
        
    }
    
    return _notReachableTipView;
}


//纯代码
- (UINavigationController *)getCodeBydict:(NSDictionary *)dict
{
    UIViewController *vc = [NSClassFromString(dict[kClassKey]) new];
    vc.navigationItem.title = dict[kTitleKey];
    
    QYHBaseNavigationController *nav = [[QYHBaseNavigationController alloc] initWithRootViewController:vc];

    [self addChildViewController:nav];
    
    return nav;
}

//storyboard
- (UINavigationController *)getStoryboardByIndex:(NSInteger)idx dict:(NSDictionary *)dict
{
    QYHBaseNavigationController *nav = (QYHBaseNavigationController *)self.childViewControllers[idx];
    
    [nav.viewControllers lastObject].navigationItem.title = dict[kTitleKey];
    
    return nav;

}
//换tabbar的背景图
- (void)changeTabbarBackgroundImage
{
    //去掉黑边和原来的背景
    [self.tabBar setShadowImage:[UIImage new]];
    [self.tabBar setBackgroundImage:[[UIImage alloc]init]];
    
    //添加tabbarde 背景图
    UIImageView *bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 49 - KItemButtonHeight, self.tabBar.frame.size.width, KItemButtonHeight)];
    bgView.image = [UIImage imageNamed:@"chat_bottom_textfield"];
    [self.tabBar insertSubview:bgView atIndex:0];
    
}

#pragma mark - tabbar 凸出的按钮
- (void)getItemButtonByIndex:(NSInteger)idx dict:(NSDictionary *)dict itemArray:(NSArray *)childItemsArray
{
    
    CGFloat itemWith = self.tabBar.bounds.size.width*1.0/childItemsArray.count ;
    CGFloat itemX    = itemWith * idx;
    CGFloat pointX   = itemX + (itemWith - KItemButtonWith)/2.0;
    
    _button     = [[UIButton alloc]initWithFrame:CGRectMake(pointX, 49 - KItemButtonHeight, KItemButtonWith, KItemButtonHeight)];
    _button.tag = idx;
    
    [_button addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.tabBar addSubview:_button];
    
    //不带有title的
    //    [self withNoTitleByDict:dict];
    
    //带有title的
    [self withTitleByDict:dict index:idx];
    
}

//不带有title的
- (void)withNoTitleByDict:(NSDictionary *)dict
{
    [_button setBackgroundImage:[UIImage imageNamed:dict[kImgKey]] forState:UIControlStateNormal];
    [_button setBackgroundImage:[UIImage imageNamed:dict[kSelImgKey]] forState:UIControlStateSelected];
}

//带有title的
- (void)withTitleByDict:(NSDictionary *)dict index:(NSInteger)idx
{
    CGFloat buttonW  = 26;
    
    _button.titleLabel.font = [UIFont systemFontOfSize:10];
    [_button setTitle:dict[kTitleKey]     forState:UIControlStateNormal];
    [_button setTitle:dict[kTitleKey]     forState:UIControlStateSelected];
    [_button setTitleColor:KSelectedColor forState:UIControlStateSelected];
    [_button setTitleColor:KNormalColor   forState:UIControlStateNormal];
    [_button setTitleEdgeInsets:UIEdgeInsetsMake(KItemButtonHeight-14, 0, 0, 0)];
    
    
    _button1 = [[UIButton alloc]initWithFrame:CGRectMake(buttonW/2.0, 7, KItemButtonWith - buttonW, KItemButtonHeight - buttonW)];
    [_button1 setBackgroundImage:[UIImage imageNamed:dict[kImgKey]] forState:UIControlStateNormal];
    [_button1 setBackgroundImage:[UIImage imageNamed:dict[kSelImgKey]] forState:UIControlStateSelected];
    _button1.tag  = idx;
    
    [_button1 addTarget:self action:@selector(add:) forControlEvents:UIControlEventTouchUpInside];
    
    [_button addSubview:_button1];
    
}

//点击事件
- (void)add:(UIButton *)button
{
    
    _button.selected   = YES;
    _button1.selected  = YES;
    
    self.selectedIndex  = button.tag;
}

//tabbar代理
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item
{
    _button1.selected  = NO;
    _button.selected   = NO;
}


-(void)dealloc{
    NSLog(@"QYHMainTabbarController--dealloc");
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KNetWorkingChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:KReceiveErrorConflictNotification object:nil];
}

@end
