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
    
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbDesc.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .3) ;
    
    self.collectionView.xt_theme_backgroundColor = k_md_backColor ;
    
    [ThemeCollectCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float scnWid = IS_IPAD ? 400 : APP_WIDTH ;
    float wid = ( scnWid - 40. - 15. ) / 2. ;
    float hei = wid / 173. * 202. ;
    layout.itemSize = CGSizeMake(wid, hei) ;
    layout.sectionInset = UIEdgeInsetsMake(30, 20, 30, 20) ;
    layout.minimumLineSpacing = 15 ;
    self.collectionView.collectionViewLayout = layout ;
    
    

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
    
    
    
}


@end
