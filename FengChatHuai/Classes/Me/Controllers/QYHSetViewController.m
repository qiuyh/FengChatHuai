//
//  QYHSetViewController.m
//  FengChatHuai
//
//  Created by 邱永槐 on 16/7/3.
//  Copyright © 2016年 iMacQIU. All rights reserved.
//

#import "QYHSetViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface QYHSetViewController ()<UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate>

{
    CLLocationManager* _locationManager;
}

@property (nonatomic,strong)UITableView *myTableView;
@property (nonatomic,strong)UIActivityIndicatorView *activity;
@property (nonatomic,strong)UIImageView *imgView ;
@property (nonatomic,strong)UILabel *label;
@property (nonatomic,assign) BOOL isLocationSuccess;
@property (nonatomic,copy) NSString *locationName;



@end

@implementation QYHSetViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataArray  = [NSMutableArray array];
        _citysArray = [NSMutableArray array];
        _areasArray = [NSMutableArray array];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //设置标题
    self.title = @"地区";
    
    self.myTableView.backgroundColor = [UIColor  colorWithHexString:@"EFEFF4"];
    
    if (_isSecondPage) {
        
        [_myTableView reloadData];
        
    }else{
        [self startLocation];
        [self getData];
    }
}

//获取省市区
- (void)getData
{
    //获取json的路径
    NSString *path=[[NSBundle mainBundle]pathForResource:@"省市区.json" ofType:nil];
    NSData *data=[NSData dataWithContentsOfFile:path];
    //获取json的数据
    NSArray *array=[NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    for (NSDictionary *dic in array)
    {//json解析后储存数据
        
        [_dataArray  addObject:[dic objectForKey:@"name"]];
        
        _areasArray = [NSMutableArray array];
        
        for (NSDictionary *dic1 in dic[@"city"])
        {
            
            if ([[dic objectForKey:@"city"] count]>1) {
                [_areasArray addObject:[dic1 objectForKey:@"name"]];
            }else{
                
                for (NSString *str in dic1[@"area"])
                {
                    [_areasArray addObject:[str removeAllSpace]];
                }
                
            }
        }
        
        [_citysArray addObject:_areasArray];
    }
    
    
    
    [_myTableView reloadData];
}


//开始定位
-(void)startLocation
{
    _locationManager=[[CLLocationManager alloc] init];
    _locationManager.delegate=self;
    _locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    _locationManager.distanceFilter=10;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0)
    {
        //支持永久定位
        [_locationManager requestAlwaysAuthorization];
        
    }
    
    [_locationManager startUpdatingLocation];//开启定位
    
    
    
}

//定位代理经纬度回调
// 6.0 以上调用这个函数
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    //此处locations存储了持续更新的位置坐标值，取最后一个值为最新位置，如果不想让其持续更新位置，则在此方法中获取到一个值之后让locationManager stopUpdatingLocation
    CLLocation *currentLocation = [locations lastObject];
    // 获取当前所在的城市名
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    //根据经纬度反向地理编译出地址信息
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *array, NSError *error)
     {
         if (array.count > 0)
         {
             CLPlacemark *placemark = [array objectAtIndex:0];
             NSLog(@"placemark.name===%@",placemark.name);//具体位置
             
             _locationName = [placemark.administrativeArea stringByAppendingString:[NSString stringWithFormat:@" %@",placemark.locality ? placemark.locality:placemark.subLocality]];
             
             _locationName = [_locationName stringByReplacingOccurrencesOfString:@"市" withString:@""];
             _locationName = [_locationName stringByReplacingOccurrencesOfString:@"省" withString:@""];
             _locationName = [_locationName stringByReplacingOccurrencesOfString:@"区" withString:@""];
             
             _isLocationSuccess = YES;
             
             _activity.hidden = YES;
             _imgView.hidden  = NO;
             _label.text = _locationName;
             
             NSLog(@"locationName==%@",_locationName);
//             //获取城市
//             NSString *city = placemark.locality;
//             city = placemark.administrativeArea;
//              NSLog(@"city==%@",city);
//             
//             if (!city) {
//                 //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
//                 city = placemark.administrativeArea;
//             }
//             
//             city=[city substringToIndex:2];
//             
//             NSLog(@"city==%@",city);
             
             //系统会一直更新数据，直到选择停止更新，因为我们只需要获得一次经纬度即可，所以获取之后就停止更新
             [manager stopUpdatingLocation];
         }else if (error == nil && [array count] == 0)
         {
             NSLog(@"No results were returned.");
         }else if (error != nil)
         {
             NSLog(@"An error occurred = %@", error);
         }
     }];
}


- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    if (error.code ==kCLErrorDenied)
    {
        // 提示用户出错原因，可按住Option键点击 KCLErrorDenied的查看更多出错信息，可打印error.code值查找原因所在
        NSLog(@"%ld",(long)error.code);
    }
}




-(UITableView *)myTableView{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _myTableView.delegate   = self;
        _myTableView.dataSource = self;
        [self.view addSubview:_myTableView];
        
    }
    
    return _myTableView;
}


#pragma mark - uitableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_isSecondPage) {
        
        return 1;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section) {
        return _dataArray.count;
    }else{
        if (_isSecondPage) {
            
            return _dataArray.count;
        }else{
            return 1;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"areaCell";
    UITableViewCell *cell = nil;
    
    if (_isSecondPage) {
        
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
    }else{
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (!indexPath.section) {
        
        if (_isSecondPage) {
            
            cell.textLabel.text = _dataArray[indexPath.row];
        }else{
            if (1) {
                
                _activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                _activity.frame = CGRectMake(15, 12, 20, 20);
                
                _imgView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 10, 20, 25)];
                _imgView.image = [UIImage imageNamed:@"city"];
                
                [cell.contentView addSubview:_activity];
                [cell.contentView addSubview:_imgView];
                
                _label = [[UILabel alloc]initWithFrame:CGRectMake(50, 12.5, 100, 21)];
                
                [cell.contentView addSubview:_label];
                
                if (_isLocationSuccess) {
                    _activity.hidden = YES;
                    _imgView.hidden  = NO;
                    _label.text = _locationName;
                }else{
                    _activity.hidden = NO;
                    _imgView.hidden  = YES;
                    _label.text = @"定位中...";
                }
            }
        }
        
    }else{
        cell.textLabel.text = _dataArray[indexPath.row];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    headerView.backgroundColor = [UIColor colorWithHexString:@"EFEFF4"];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 25, 100, 21)];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor grayColor];
    
    if (section) {
        titleLabel.text = @"全部";
    }else{
        if (_isSecondPage) {
            
            titleLabel.text = @"全部";
        }else{
             titleLabel.text = @"定位到的位置";
        }
    }
    
    [headerView addSubview:titleLabel];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 45.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.00001f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section) {
        
         UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        QYHSetViewController *setVC = [[QYHSetViewController alloc]init];
        setVC.dataArray = _citysArray[indexPath.row];
        setVC.isSecondPage = YES;
        setVC.provinceName = cell.textLabel.text;
        setVC.cell = self.cell;
        setVC.delegate = self.delegate;
        
        [self.navigationController pushViewController:setVC animated:YES];
        
    }else{
        
        if (_isSecondPage) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            self.cell.detailTextLabel.text = [_provinceName stringByAppendingString:[NSString stringWithFormat:@" %@",cell.textLabel.text]];
        }else{
            self.cell.detailTextLabel.text = _label.text;
        }
        [self.cell layoutSubviews];
        
        
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        
        if ([[QYHXMPPTool sharedQYHXMPPTool].xmppStream isConnected]) {
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            
            NSLog(@"上传我的信息成功");
            
           [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
            
            if ([self.delegate respondsToSelector:@selector(didFinishedSave)]) {
                [self.delegate didFinishedSave];
            }
            
        }else{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            [QYHProgressHUD showErrorHUD:nil message: @"更改我的信息失败"];
        }

//        __weak typeof(self) weakself = self;
//        
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//        
//        NSString *fileName = @"information.json";
//        
//        NSUserDefaults *userinfo     = [NSUserDefaults standardUserDefaults];
//        NSDictionary *informationDic = [[userinfo objectForKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]] mutableCopy];
//        [informationDic setValue:self.cell.detailTextLabel.text forKey:@"area"];
//        
//        NSString *str = [NSString dictionaryToJson:informationDic];
//        
//        NSData *data  = [str dataUsingEncoding:NSUTF8StringEncoding];
//        
//        [[QYHQiNiuRequestManarger shareInstance]updateFile:fileName photoNumber:[QYHAccount shareAccount].loginUser data:data Success:^(id responseObject) {
//            
//            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//            
//            NSDictionary *informationDic = [userinfo objectForKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]];
//            [informationDic setValue:self.cell.detailTextLabel.text forKey:@"area"];
//            
//             NSLog(@"上传我的信息成功");
//            //成功就能保存
//            NSUserDefaults *userinfo = [NSUserDefaults standardUserDefaults];
//            [userinfo setObject:informationDic forKey:[ NSString stringWithFormat:@"%@information",[QYHAccount shareAccount].loginUser]];
//            
//            [weakself.navigationController popToViewController:weakself.navigationController.viewControllers[1] animated:YES];
//            
//            if ([weakself.delegate respondsToSelector:@selector(didFinishedSave)]) {
//                [weakself.delegate didFinishedSave];
//            }
//
//        } failure:^(NSError *error) {
//            
//            [MBProgressHUD hideHUDForView:weakself.view animated:YES];
//            [QYHProgressHUD showErrorHUD:nil message:@"更改地址失败"];
//            NSLog(@"上传我的信息失败");
//        }];

    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(void)dealloc{
    NSLog(@"8888dealloc");
}

@end
