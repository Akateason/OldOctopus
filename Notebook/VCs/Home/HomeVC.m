//
//  HomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <UIViewController+CWLateralSlide.h>
#import "LeftDrawerVC.h"



@interface HomeVC ()
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;
@property (weak, nonatomic) IBOutlet UIButton *btLeftDrawer;
@property (weak, nonatomic) IBOutlet UIView *vSearchBar;
@property (weak, nonatomic) IBOutlet UIImageView *imgSearch;
@property (weak, nonatomic) IBOutlet UITextField *tfSearch;
@property (weak, nonatomic) IBOutlet UILabel *lbUserName;
@property (strong, nonatomic) UIView *btAdd ;

@property (strong, nonatomic) LeftDrawerVC *leftVC ;
@end

@implementation HomeVC

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    // 第一个参数为是否开启边缘手势，开启则默认从边缘50距离内有效，第二个block为手势过程中我们希望做的操作
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @strongify(self)
        //NSLog(@"direction = %ld", direction);
        if (direction == CWDrawerTransitionFromLeft) { // 左侧滑出
            [self openDrawer] ;
        }
    }] ;
    
}

- (CGFloat)movingDistance {
    return  265. / 375. * APP_WIDTH ;
}

- (void)openDrawer {
    [self.leftVC render] ;
    // 0.01
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.3 scaleY:1 direction:CWDrawerTransitionFromLeft backImage:nil];
    [self cw_showDrawerViewController:self.leftVC animationType:0 configuration:conf];
}

- (void)prepareUI {
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    self.nameOfNoteBook.textColor = UIColorHex(@"222222") ;
    self.topArea.backgroundColor = [UIColor whiteColor] ;
    self.vSearchBar.xt_borderColor = UIColorRGBA(20, 20, 20, .1) ;
    
    self.lbUserName.backgroundColor = [MDThemeConfiguration sharedInstance].themeColor ;
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        self.lbUserName.text = [user.givenName substringToIndex:1] ;
    }] ;
    
    self.btAdd.userInteractionEnabled = YES ;
    @weakify(self)
    [self.btAdd bk_whenTapped:^{
        NSLog(@"bt add") ;
        
    }] ;
    
    [self.btLeftDrawer bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self openDrawer] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [self.navigationController setNavigationBarHidden:YES animated:NO] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
//    [self.navigationController setNavigationBarHidden:NO animated:NO] ;
}



#pragma mark - prop

- (UIView *)btAdd{
    if(!_btAdd){
        _btAdd = ({
            UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 49, 49)];
            view.xt_gradientPt0 = CGPointMake(0,.5) ;
            view.xt_gradientPt1 = CGPointMake(0, 1) ;
            view.xt_gradientColor0 = UIColorHex(@"fe4241") ;
            view.xt_gradientColor1 = UIColorHex(@"fe8c68") ;
            
            UIImage *img = [UIImage image:[UIImage getImageFromView:view] rotation:(UIImageOrientationUp)] ;
            view = [[UIImageView alloc] initWithImage:img] ;
            view.xt_completeRound = YES ;
            if (!view.superview) {
                [self.view addSubview:view] ;
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.size.mas_equalTo(CGSizeMake(49, 49)) ;
                    make.right.equalTo(@-12) ;
                    make.bottom.equalTo(@-28) ;
                }] ;
            }
            
            img = [img boxblurImageWithBlur:.2] ;
            UIView *shadow = [[UIImageView alloc] initWithImage:img] ;
            [self.view insertSubview:shadow belowSubview:view] ;
            shadow.alpha = .1 ;
            shadow.xt_completeRound = YES ;
            [shadow mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(49, 49)) ;
                make.centerY.equalTo(view).offset(15) ;
                make.centerX.equalTo(view) ;
            }] ;
            
            UIImageView *btIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bt_home_add"]] ;
            [view addSubview:btIcon] ;
            [btIcon mas_makeConstraints:^(MASConstraintMaker *make) {
                make.size.mas_equalTo(CGSizeMake(28, 28)) ;
                make.center.equalTo(view) ;
            }] ;
            view;
       });
    }
    return _btAdd;
}

- (LeftDrawerVC *)leftVC{
    if(!_leftVC){
        _leftVC = ({
            LeftDrawerVC * object = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"] ;
            object.distance = self.movingDistance ;
            object;
       });
    }
    return _leftVC;
}


@end
