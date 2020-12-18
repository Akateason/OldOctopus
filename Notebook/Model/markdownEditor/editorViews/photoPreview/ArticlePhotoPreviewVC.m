//
//  ArticlePhotoPreviewVC.m
//  Notebook
//
//  Created by teason23 on 2019/5/7.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "ArticlePhotoPreviewVC.h"
#import "MdInlineModel.h"
#import <XTlib/XTZoomPicture.h>

typedef void(^BlkDeleteOnClick)(ArticlePhotoPreviewVC *vc);

@interface ArticlePhotoPreviewVC ()
@property (strong, nonatomic) UIButton *deleteButton ;
@property (strong, nonatomic) UIButton *downloadButton ;
@property (strong, nonatomic) XTZoomPicture *zoomPic ;
@property (copy, nonatomic) BlkDeleteOnClick blkDelete ;

@property (copy, nonatomic) NSString *src ;

@end

@implementation ArticlePhotoPreviewVC

+ (instancetype)showFromView:(UIView *)fromView
                           json:(NSString *)json
                  deleteOnClick:(void(^)(ArticlePhotoPreviewVC *vc))deleteOnClick
{
    CGRect rect = CGRectMake(0, 0, [GlobalDisplaySt sharedInstance].containerSize.width, [GlobalDisplaySt sharedInstance].containerSize.height) ;
    ArticlePhotoPreviewVC *view = [[ArticlePhotoPreviewVC alloc] initWithFrame:rect] ;
    NSDictionary *dic = [WebModel convertjsonStringToJsonObj:json] ;
    view.src = dic[@"token"][@"src"] ;
    
    [view prepareUI] ;
    
    [fromView addSubview:view] ;
    view.blkDelete = deleteOnClick ;
    return view ;
}





- (void)prepareUI {
    self.deleteButton.hidden = YES ;
    self.downloadButton.hidden = YES ;
            
    @weakify(self)
    XTZoomPicture *zp = [[XTZoomPicture alloc] initWithFrame:self.bounds];
    zp.backgroundColor = [UIColor blackColor];
    @weakify(zp)
    [zp.imageView sd_setImageWithURL:[NSURL URLWithString:self.src] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        @strongify(self)
        @strongify(zp)
        self.downloadButton.hidden = NO ;
        self.deleteButton.hidden = NO ;
        [zp reset];
    }];
        
    [zp onTapped:^{
        [self removeFromSuperview] ;
    }];
        
    self.zoomPic = zp;
    
    if (![self.src hasPrefix:@"http"]) {
        NSData *data = [NSData dataWithContentsOfFile:self.src] ;
        UIImage *image = [UIImage imageWithData:data] ;
        self.zoomPic.imageView.image = image ;
    }
    
    [self addSubview:self.zoomPic] ;
    [self.zoomPic mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
    self.deleteButton = ({
        UIButton *bt = [UIButton new] ;
        bt.xt_borderColor = [UIColor colorWithWhite:1 alpha:.3] ;
        bt.xt_borderWidth = 1 ;
        bt.xt_cornerRadius = 4 ;
        [bt setImage:[UIImage imageNamed:@"photo_preview_bt_delete"] forState:0] ;
        [self addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32)) ;
            make.left.equalTo(self).offset(18) ;
            make.bottom.equalTo(self.mas_bottomMargin).offset(-18) ;
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
        [self addSubview:bt] ;
        [bt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(32, 32)) ;
            make.right.equalTo(self).offset(-18) ;
            make.bottom.equalTo(self.mas_bottomMargin).offset(-18) ;
        }] ;
        bt ;
    }) ;
    [self.downloadButton xt_enlargeButtonsTouchArea] ;
    
    
    WEAK_SELF
    [self.deleteButton xt_whenTapped:^{
        weakSelf.blkDelete(weakSelf) ;
    }] ;
    
    [self.downloadButton xt_whenTapped:^{
        
        UIImage *imgSave = weakSelf.zoomPic.imageView.image;
        dispatch_async(dispatch_get_main_queue(), ^{
            [XTPhotoSaver saveImage:imgSave inAlbum:@"小章鱼" complete:^(BOOL bSave) {
                [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
            }];
        }) ;
        
    }] ;
}







@end
