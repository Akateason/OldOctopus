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
    self.fd_prefersNavigationBarHidden = YES ;

    
    WEAK_SELF
    [self.btCancel xt_whenTapped:^{
        [weakSelf dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    [self.btSave xt_whenTapped:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            
//            [CommonFunc saveImageToLibrary:weakSelf.outpuImage complete:^(bool success) {
//                [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
//
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [weakSelf dismissViewControllerAnimated:YES completion:^{
//                    }] ;
//                });
//
//            }] ;
        }) ;
        
        
    }] ;
    
    
    CGRect rect = CGRectMake(0, 0, APP_WIDTH - 30, APP_HEIGHT - APP_STATUSBAR_HEIGHT - APP_NAVIGATIONBAR_HEIGHT - 40) ;
    XTZoomPicture *zoomPic = [[XTZoomPicture alloc] initWithFrame:CGRectMake(15, APP_NAVIGATIONBAR_HEIGHT + APP_STATUSBAR_HEIGHT + 20, rect.size.width, rect.size.height)];
    zoomPic.imageView.image = self.outpuImage;
    [self.view addSubview:zoomPic] ;
}

- (void)prepareUI {
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.btCancel.xt_theme_textColor = k_md_textColor ;
    self.btSave.xt_theme_textColor = k_md_themeColor ;
    

}



@end
