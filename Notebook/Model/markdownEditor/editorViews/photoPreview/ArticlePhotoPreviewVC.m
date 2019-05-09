//
//  ArticlePhotoPreviewVC.m
//  Notebook
//
//  Created by teason23 on 2019/5/7.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticlePhotoPreviewVC.h"
#import <XTlib/XTZoomPicture.h>
#import "MdInlineModel.h"

typedef void(^BlkDeleteOnClick)(ArticlePhotoPreviewVC *vc);

@interface ArticlePhotoPreviewVC ()
@property (strong, nonatomic) UIButton *deleteButton ;
@property (strong, nonatomic) UIButton *downloadButton ;
@property (strong, nonatomic) XTZoomPicture *zoomPic ;
@property (copy, nonatomic) BlkDeleteOnClick blkDelete ;

@end

@implementation ArticlePhotoPreviewVC

+ (instancetype)showFromCtrller:(UIViewController *)fromCtrller
                  model:(MdInlineModel *)model
          deleteOnClick:(void(^)(ArticlePhotoPreviewVC *vc))deleteOnClick
{
    ArticlePhotoPreviewVC *vc = [[ArticlePhotoPreviewVC alloc] init] ;
    vc.modelImage = (MdInlineModel *)model ;
    [vc setModalTransitionStyle:UIModalTransitionStyleCrossDissolve];
    [fromCtrller presentViewController:vc animated:YES completion:^{}] ;
    vc.blkDelete = deleteOnClick ;
    return vc ;
}

- (void)prepareUI {
    WEAK_SELF
    self.zoomPic = [[XTZoomPicture alloc] initWithFrame:APPFRAME backImage:nil max:2 min:.5 flex:0 tapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    [self.view addSubview:self.zoomPic] ;
    
    self.deleteButton = ({
        UIButton *bt = [UIButton new] ;
        bt.xt_borderColor = [UIColor colorWithWhite:1 alpha:.3] ;
        bt.xt_borderWidth = 1 ;
        bt.xt_cornerRadius = 4 ;
        [bt setImage:[UIImage imageNamed:@"photo_preview_bt_delete"] forState:0] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32)) ;
            make.left.equalTo(self.view).offset(18) ;
            make.bottom.equalTo(self.view.mas_bottomMargin).offset(18) ;
        }] ;
        bt ;
    }) ;
    
    self.downloadButton = ({
        UIButton *bt = [UIButton new] ;
        bt.xt_borderColor = [UIColor colorWithWhite:1 alpha:.3] ;
        bt.xt_borderWidth = 1 ;
        bt.xt_cornerRadius = 4 ;
        [bt setImage:[UIImage imageNamed:@"photo_preview_bt_download"] forState:0] ;
        [self.view addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32)) ;
            make.right.equalTo(self.view).offset(-18) ;
            make.bottom.equalTo(self.view.mas_bottomMargin).offset(18) ;
        }] ;
        bt ;
    }) ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.deleteButton.hidden = YES ;
    self.downloadButton.hidden = YES ;
    
    
    
    [self.zoomPic.imageView sd_setImageWithURL:[NSURL URLWithString:self.modelImage.imageUrl] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
        
        
        self.downloadButton.hidden = NO ;
        self.deleteButton.hidden = NO ;
    }] ;
    
    WEAK_SELF
    [self.deleteButton bk_whenTapped:^{
        weakSelf.blkDelete(weakSelf) ;
    }] ;
    
    [self.downloadButton bk_whenTapped:^{
        
        __block UIImage *imgSave = weakSelf.zoomPic.imageView.image;
        dispatch_queue_t queue = dispatch_queue_create("pictureSaveInAlbum", NULL);
        dispatch_async(queue, ^{
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            [library saveImage:imgSave
                       toAlbum:@"小章鱼"
               completionBlock:^(NSError *error) {
                   if (!error) {
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [SVProgressHUD showSuccessWithStatus:@"图片已保存"] ;
                       });
                   }
               }];
        });
        
    }] ;
}



@end
