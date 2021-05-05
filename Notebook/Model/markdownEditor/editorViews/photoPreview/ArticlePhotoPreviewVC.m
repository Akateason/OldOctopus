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
    self.deleteButton.hidden = YES ;
    self.downloadButton.hidden = YES ;
    
    @weakify(self)
    
//    
//    self.zoomPic = [[XTZoomPicture alloc] initWithFrame:APPFRAME imageUrl:self.modelImage.imageUrl tapped:^{
//        @strongify(self)
//        [self dismissViewControllerAnimated:YES completion:nil] ;
//    } loadComplete:^{
//        @strongify(self)
//        self.downloadButton.hidden = NO ;
//        self.deleteButton.hidden = NO ;
//    }] ;
//    
//    [self.view addSubview:self.zoomPic] ;
    
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
            make.bottom.equalTo(self.view.mas_bottomMargin).offset(-18) ;
        }] ;
        bt ;
    }) ;
    [self.deleteButton xt_enlargeButtonsTouchArea] ;
    
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
            make.bottom.equalTo(self.view.mas_bottomMargin).offset(-18) ;
        }] ;
        bt ;
    }) ;
    [self.downloadButton xt_enlargeButtonsTouchArea] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    WEAK_SELF
    [self.deleteButton xt_whenTapped:^{
        weakSelf.blkDelete(weakSelf) ;
    }] ;
    
    [self.downloadButton xt_whenTapped:^{
        
        UIImage *imgSave = [weakSelf.zoomPic valueForKey:@"backImage"] ;
        dispatch_async(dispatch_get_main_queue(), ^{
//            [CommonFunc saveImageToLibrary:imgSave complete:^(bool success) {
//
//                    [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
//
//            }] ;
        }) ;
        
    }] ;
}



@end
