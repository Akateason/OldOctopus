//
//  OutputPreviewVC.m
//  Notebook
//
//  Created by teason23 on 2019/5/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OutputPreviewVC.h"
#import "OctMBPHud.h"
#import <XTlib/XTZoomPicture.h>


@interface OutputPreviewVC ()
@property (weak, nonatomic) IBOutlet UIButton *btSave;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIView *topBar; // h 55
@property (weak, nonatomic) IBOutlet UIView *container;

@property (strong, nonatomic) UIImage *outpuImage ;

@property (strong, nonatomic) XTZoomPicture *zp ;
@end

@implementation OutputPreviewVC

+ (void)showFromCtrller:(UIViewController *)ctrller imageOutput:(UIImage *)imageOutput {
    OutputPreviewVC *vc = [OutputPreviewVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OutputPreviewVC"] ;
    
    
    vc.outpuImage = imageOutput ;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc] ;
    nav.modalPresentationStyle = UIModalPresentationFullScreen ;
    [ctrller presentViewController:nav animated:YES completion:nil] ;
}



- (void)viewDidLoad {
    [super viewDidLoad] ;

    self.fd_prefersNavigationBarHidden = YES ;
    self.topBar.backgroundColor = [UIColor whiteColor] ;
    
    [self.btCancel setTitleColor:[UIColor colorWithWhite:0 alpha:.6] forState:0] ;
    [self.btSave setTitleColor:UIColorHex(@"FF6969") forState:0] ;

    @weakify(self)
    [self.btCancel xt_whenTapped:^{
        [[OctMBPHud sharedInstance] hide] ;
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    [self.btSave xt_whenTapped:^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @weakify(self)
            [XTPhotoSaver saveImage:self.outpuImage inAlbum:@"小章鱼" complete:^(BOOL success) {
                              
                [SVProgressHUD showSuccessWithStatus:@"已经保存到本地相册"] ;
                @strongify(self)
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil] ;
                });

            }];
        });
    }] ;
    
    
    CGRect rect = CGRectMake(0, 0, APP_WIDTH - 30, APP_HEIGHT - APP_STATUSBAR_HEIGHT - APP_NAVIGATIONBAR_HEIGHT - 40) ;
    
    
    XTZoomPicture *zp = [XTZoomPicture new];
    zp.frame = CGRectMake(15, APP_NAVIGATIONBAR_HEIGHT + APP_STATUSBAR_HEIGHT + 20, rect.size.width, rect.size.height) ;
    zp.imageView.image = self.outpuImage;
    [self.view addSubview:zp] ;
    self.zp = zp;
        
    self.view.backgroundColor = [UIColor whiteColor] ;
    self.container.backgroundColor = UIColorHex(@"F5F5F5") ;
    self.zp.backgroundColor = UIColorHex(@"F5F5F5") ;
}

@end
