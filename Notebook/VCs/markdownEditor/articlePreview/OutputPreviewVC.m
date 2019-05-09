//
//  OutputPreviewVC.m
//  Notebook
//
//  Created by teason23 on 2019/5/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OutputPreviewVC.h"
#import <XTlib/XTZoomPicture.h>


@interface OutputPreviewVC ()
@property (weak, nonatomic) IBOutlet UIButton *btSave;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIView *topBar; // h 55
@property (weak, nonatomic) IBOutlet UIView *container;

@property (strong, nonatomic) UIImage *outpuImage ;
@end

@implementation OutputPreviewVC

+ (void)showFromCtrller:(UIViewController *)ctrller imageOutput:(UIImage *)imageOutput {
    OutputPreviewVC *vc = [OutputPreviewVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OutputPreviewVC"] ;
    vc.outpuImage = imageOutput ;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc] ;
    [ctrller presentViewController:nav animated:YES completion:nil] ;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self.navigationController setNavigationBarHidden:YES animated:NO] ;
    self.fd_prefersNavigationBarHidden = YES ;

    
    WEAK_SELF
    [self.btCancel bk_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    [self.btSave bk_whenTapped:^{
        
        ALAssetsLibrary *lib = [[ALAssetsLibrary alloc] init] ;
        [lib saveImage:weakSelf.outpuImage toAlbum:@"小章鱼" completionBlock:^(NSError *error) {
            if (error) return ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
            }) ;
        }] ;
    }] ;
}

- (void)prepareUI {
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.btCancel.xt_theme_textColor = k_md_textColor ;
    self.btSave.xt_theme_textColor = k_md_themeColor ;
    
    [self.container setNeedsLayout] ;
    [self.container layoutIfNeeded] ;
    
    XTZoomPicture *zoomPic = [[XTZoomPicture alloc] initWithFrame:self.container.bounds backImage:self.outpuImage tapped:^{
        
    }] ;
    [self.container addSubview:zoomPic] ;
}



@end
