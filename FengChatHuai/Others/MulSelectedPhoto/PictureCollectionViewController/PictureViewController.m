//
//  ViewController.m
//  类似QQ图片添加、图片浏览
//
//  Created by seven on 16/3/30.
//  Copyright © 2016年 QQpicture. All rights reserved.
//

#import "PictureViewController.h"
#import "MJPhotoBrowser.h"
#import "MJPhoto.h"
#import "PictureCollectionViewCell.h"
#import "DNImagePickerController.h"
#import "DNAsset.h"
#import "MWPhoto.h"
#import "UIImage+AssetImage.h"


@interface PictureViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,MJPhotoBrowserDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate,UICollectionViewDelegateFlowLayout,DNImagePickerControllerDelegate>

{
    NSData *data;
    
    NSMutableArray *_imageURLTempArray; //网络图片url
    
    NSMutableArray *_imageWebArray; //来自网络的图片 image格式
    
    NSMutableArray *_imageBrowserArray; //保存到图片浏览器中的图片 MWPhoto格式
    
}


@property(nonatomic,strong)NSMutableArray *picArray;


@end

@implementation PictureViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _imageWebArray = [[NSMutableArray alloc]init];

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    

    //每行多少张照片
    _count =  (_pictureCollectonViewFrame.size.width - _sectionInset.left - _sectionInset.right +_minimumInteritemSpacing) /(_itemSize.width+_minimumInteritemSpacing);
    
    _picArray = [[NSMutableArray alloc]initWithObjects:_addImage,nil];
    
    layout.itemSize = _itemSize;
    layout.minimumInteritemSpacing = _minimumInteritemSpacing;
    layout.minimumLineSpacing = _minimumLineSpacing; //上下的间距 可以设置0看下效果
    layout.sectionInset = _sectionInset;

    
    self.pictureCollectonView = [[UICollectionView alloc] initWithFrame:_pictureCollectonViewFrame collectionViewLayout:layout];

    
    [self.pictureCollectonView registerClass:[PictureCollectionViewCell class]forCellWithReuseIdentifier:@"cell"];
    
//    [self.pictureCollectonView registerClass:[PictureAddCell class] forCellWithReuseIdentifier:@"addItemCell"];
    
//    self.pictureCollectonView.backgroundColor = [UIColor grayColor];
    self.pictureCollectonView.delegate = self;
    self.pictureCollectonView.dataSource = self;
    
    [self.view addSubview:self.pictureCollectonView];
    
}


#pragma mark - collectionView 调用方法
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    NSUInteger hangCount = 0;
    
    if (self.picArray.count > _maxNum) {
        hangCount     = (self.picArray.count - 1)/_count + ((self.picArray.count - 1)%_count > 0 ? 1:0 );
    }else{
        hangCount     = self.picArray.count/_count + (self.picArray.count%_count > 0 ? 1:0 );
    }
    
    CGRect rect     = _pictureCollectonViewFrame;
    
    rect.size.height = rect.size.height+(rect.size.height - _sectionInset.bottom - _sectionInset.top)*(hangCount - 1)  ;
    
    self.pictureCollectonView.frame = rect;
    
    
    return _picArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identify = @"cell";
    PictureCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identify forIndexPath:indexPath];
    if (indexPath.row == self.picArray.count-1) {
        
        if (self.SelectedPhotosArrayBlock) {
            NSMutableArray *mutArray = [NSMutableArray array];
            mutArray = [self.picArray mutableCopy];
            [mutArray removeLastObject];
            self.SelectedPhotosArrayBlock(mutArray);
        }
        
        if (self.picArray.count > _maxNum) {
            cell.imageView.hidden = YES;
        }else{
            cell.imageView.hidden = NO;
        }
    }else{
        cell.imageView.hidden = NO;
    }
    cell.imageView.image = self.picArray[indexPath.row];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    return cell;
}

//用代理
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.picArray.count-1) {
        if (self.picArray.count > _maxNum) {
            return;
        }
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机选择", @"拍照", nil];
        sheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [sheet showInView:self.view];
    }else
    {
        NSMutableArray *photoArray = [[NSMutableArray alloc] init];
        for (int i = 0;i< self.picArray.count-1; i ++) {
            UIImage *image = self.picArray[i];
            
            MJPhoto *photo = [MJPhoto new];
            photo.image = image;
            PictureCollectionViewCell *cell = (PictureCollectionViewCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            photo.srcImageView = cell.imageView;
            [photoArray addObject:photo];
        }
        
        MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
        browser.photoBrowserdelegate = self;
        browser.currentPhotoIndex = indexPath.row;
        browser.photos = photoArray;
        [browser show];
        
    }
}

-(void)deletedPictures:(NSSet *)set
{
    NSMutableArray *cellArray = [NSMutableArray array];
    
    for (NSString *index1 in set) {
        [cellArray addObject:index1];
    }
    
    if (cellArray.count == 0) {
        
    }else if (cellArray.count == 1 && self.picArray.count == 2) {
        NSIndexPath *indexPathTwo = [NSIndexPath indexPathForRow:0 inSection:0];
        
        [self.picArray removeObjectAtIndex:indexPathTwo.row];
        [self.pictureCollectonView deleteItemsAtIndexPaths:@[indexPathTwo]];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.picArray.count-1 inSection:0];
        PictureCollectionViewCell *cell = (PictureCollectionViewCell *)[self.pictureCollectonView cellForItemAtIndexPath:indexPath];
        cell.imageView.hidden = NO;
        
        if (self.SelectedPhotosArrayBlock) {
            NSMutableArray *mutArray = [NSMutableArray array];
            mutArray = [self.picArray mutableCopy];
            [mutArray removeLastObject];
            self.SelectedPhotosArrayBlock(mutArray);
        }
        
    }else{
        
        for (int i = 0; i<cellArray.count-1; i++) {
            for (int j = 0; j<cellArray.count-1-i; j++) {
                if ([cellArray[j] intValue]<[cellArray[j+1] intValue]) {
                    NSString *temp = cellArray[j];
                    cellArray[j] = cellArray[j+1];
                    cellArray[j+1] = temp;
                }
            }
        }
        
        for (int b = 0; b<cellArray.count; b++) {
            int idexx = [cellArray[b] intValue]-1;
            
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idexx inSection:0];
            
            
            [UIView performWithoutAnimation:^{
                
                [self.picArray removeObjectAtIndex:indexPath.row];
                [self.pictureCollectonView deleteItemsAtIndexPaths:@[indexPath]];
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.picArray.count-1 inSection:0];
                PictureCollectionViewCell *cell = (PictureCollectionViewCell *)[self.pictureCollectonView cellForItemAtIndexPath:indexPath];
                cell.imageView.hidden = NO;
                
                if (self.SelectedPhotosArrayBlock) {
                    NSMutableArray *mutArray = [NSMutableArray array];
                    mutArray = [self.picArray mutableCopy];
                    [mutArray removeLastObject];
                    self.SelectedPhotosArrayBlock(mutArray);
                }

            }];
            
        }
    }
}

#pragma mark - 相册、相机调用方法
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        
        DNImagePickerController *imagePicker = [[DNImagePickerController alloc] init];
        
        NSMutableArray *tempArray =  _picArray;
//
        [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:_maxNum - tempArray.count + 1] forKey:@"kPicAddCount"];
        
//        imagePicker.maxSeletedNumber = 8;
        imagePicker.filterType = DNImagePickerFilterTypePhotos;
        imagePicker.imagePickerDelegate = self;
        imagePicker.navigationController.navigationBar.backgroundColor = [UIColor redColor];
        [self presentViewController:imagePicker animated:YES completion:nil];

        NSLog(@"点击了从手机选择");
        
    }else if (buttonIndex == 1)
    {
        NSLog(@"点击了拍照");
        
        UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
        if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            //设置拍照后的图片可被编辑
            picker.allowsEditing = YES;
            picker.sourceType = sourceType;
            
            picker.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self presentViewController:picker animated:YES completion:nil];
        }else{
            NSLog(@"模拟无效,请真机测试");
        }
    }
}


//当拍照一张图片后进入这里
-(void)imagePickerController:(UIImagePickerController*)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    //关闭相册界面
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSMutableArray *tempArray =  _picArray;
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        __weak PictureViewController *weakSelf = self;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            //先把图片转成NSData
            UIImage* image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
            
            data = UIImageJPEGRepresentation(image,0.8);
            
            if(_imageWebArray.count > 1){
                
                [_imageBrowserArray insertObject:[MWPhoto photoWithImage:image] atIndex:[tempArray count] - 2];
                
            }else{
                
                [_imageBrowserArray insertObject:[MWPhoto photoWithImage:image] atIndex:[tempArray count] - 1];
                
            }
            
            [tempArray insertObject:image atIndex:[tempArray count] - 1];
            
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView performWithoutAnimation:^{
                    
                     [weakSelf.pictureCollectonView reloadData];
                }];

                
                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:_maxNum - tempArray.count + 1] forKey:@"kPicAddCount"];
            });
            
            
        });
        
    }
    
}



- (void)dnImagePickerController:(DNImagePickerController *)imagePickerController sendImages:(NSArray *)imageAssets isFullImage:(BOOL)fullImage
{
    NSMutableArray *tempArray =  _picArray;
    
    for (NSInteger i = 0; i<imageAssets.count; i++) {
        
        DNAsset *asset = imageAssets[i];
        
        NSURL *url =asset.url;
        
         __weak PictureViewController *weakSelf = self;
        
        [UIImage fullResolutionImageFromALAsset:url result:^(UIImage *image) {
            
            data = UIImageJPEGRepresentation(image,0.5);
            
            if(_imageWebArray.count > 1){
                
                [_imageBrowserArray insertObject:[MWPhoto photoWithImage:image] atIndex:[tempArray count] - 2];
                
                NSLog(@"[tempArray count] = %ld",(long)[tempArray count] - _imageURLTempArray.count);
                
            }else{
                
                [_imageBrowserArray insertObject:[MWPhoto photoWithImage:image] atIndex:[tempArray count] - 1];
                
            }
            
            [tempArray insertObject:image atIndex:[tempArray count] - 1];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [UIView performWithoutAnimation:^{
                    
                     [weakSelf.pictureCollectonView reloadData];
                }];

                
                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInteger:_maxNum - tempArray.count + 1] forKey:@"kPicAddCount"];
            });
            
            
        }];
    }
    
  
}



- (void)dnImagePickerControllerDidCancel:(DNImagePickerController *)imagePicker
{
    [imagePicker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com