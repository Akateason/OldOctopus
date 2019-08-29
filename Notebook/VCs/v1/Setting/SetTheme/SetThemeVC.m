//
//  SetThemeVC.m
//  Notebook
//
//  Created by teason23 on 2019/6/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetThemeVC.h"
#import "ThemeCollectCell.h"
#import "SettingNavBar.h"
#import "GuidingICloud.h"
#import "IapUtil.h"
#import "IAPSubscriptionVC.h"

@interface SetThemeVC () <UICollectionViewDelegate,UICollectionViewDataSource>
@property (copy, nonatomic) NSArray *themes ;
@end

@implementation SetThemeVC

+ (instancetype)getMe {
    SetThemeVC *vc = [SetThemeVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SetThemeVC"] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.themes = @[@"light",@"dark",@"sunshine",@"midnight"] ;
    
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    
    self.fd_prefersNavigationBarHidden = YES ;
    [SettingNavBar addInController:self] ;
    
    
    self.img.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    self.img.xt_borderWidth = .5 ;
    self.img.xt_cornerRadius = 6. ;
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .3) ;
    self.midBack.xt_theme_backgroundColor = k_md_backColor ;
    self.collectionView.xt_theme_backgroundColor = k_md_backColor ;
    
    self.backView.xt_theme_backgroundColor = k_md_backColor ;
    
    [ThemeCollectCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float scnWid = IS_IPAD ? 400 : APP_WIDTH ;
    float wid = ( scnWid - 40. - 12. * 3 ) / 4. ;
    float hei = wid / 5. * 4. ;
    layout.itemSize = CGSizeMake(wid, hei) ;
    layout.sectionInset = UIEdgeInsetsMake(0, 20, 0, 20) ;
    layout.minimumLineSpacing = 0 ;
    self.collectionView.collectionViewLayout = layout ;
    
    
    self.img.image = [UIImage imageNamed:XT_STR_FORMAT(@"theme_b_%@", [MDThemeConfiguration sharedInstance].currentThemeKey )] ;
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.themes.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ThemeCollectCell *cell = [ThemeCollectCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    [cell setThemeStr:self.themes[indexPath.row]] ;
    [cell setOnSelect:[[[MDThemeConfiguration sharedInstance] currentThemeKey]
                       isEqualToString:self.themes[indexPath.row]]] ;
    return cell ;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView
//                  layout:(UICollectionViewLayout *)collectionViewLayout
//  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
//    return [ThemeCollectCell xt_cellSizeForModel:@(self.view.width)] ;
//}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    if (row > 0) {
        if (![XTIcloudUser hasLogin]) {
            NSLog(@"未登录") ;
            [GuidingICloud show] ;
            
            return ;
        }
        
        if (![IapUtil isIapVipFromLocalAndRequestIfLocalNotExist]) {
            [IAPSubscriptionVC showMePresentedInFromCtrller:self fromSourceView:collectionView] ;
            
            return ;
        }        
    }
    
    [[MDThemeConfiguration sharedInstance] changeTheme:self.themes[indexPath.row]] ;
    [self.collectionView reloadData] ;
    
    self.img.image = [UIImage imageNamed:XT_STR_FORMAT(@"theme_b_%@",self.themes[indexPath.row])] ;
    self.img.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
}


@end
