//
//  OcHomeVC+UIPart.m
//  Notebook
//
//  Created by teason23 on 2019/8/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC+UIPart.h"
#import "UIView+OctupusExtension.h"
#import "SettingVC.h"
#import "SearchVC.h"
#import "OcAllBookVC.h"

@implementation OcHomeVC (UIPart)

- (void)xt_prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    // collections
    [OcBookCell      xt_registerNibFromCollection:self.bookCollectionView] ;
    [OcContainerCell xt_registerNibFromCollection:self.mainCollectionView] ;
    
    self.bookCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.bookCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.delegate    = (id<UICollectionViewDelegate>)self ;
    self.mainCollectionView.dataSource  = (id<UICollectionViewDataSource>)self ;
    self.mainCollectionView.pagingEnabled = YES ;
    self.mainCollectionView.showsHorizontalScrollIndicator = NO ;
    
    [self setupStructCollectionLayout] ;
    
    self.bookCollectionView.xt_theme_backgroundColor = k_md_bgColor ;
    self.mainCollectionView.xt_theme_backgroundColor = k_md_backColor ;
//    self.mainCollectionView.backgroundColor = [UIColor redColor] ;
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    // ..
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.midBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .9) ;
    self.lbMyNotes.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .8) ;
    self.lbAll.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .4) ;
    self.img_lbAllRight.xt_theme_imageColor = k_md_textColor ;
    
    // 加号
    self.btSearch.touchExtendInset  = UIEdgeInsetsMake(-15, -15, -15, -15) ;
    self.btSearch.xt_theme_imageColor = k_md_iconColor ;    

    self.btAdd.touchExtendInset     = UIEdgeInsetsMake(-15, -15, -15, -15) ;
    self.btAdd.xt_theme_imageColor = k_md_iconColor ;
    
    // 按钮
    [self.btUser setImage:[UIImage imageNamed:XT_STR_FORMAT(@"uhead_%@",[MDThemeConfiguration sharedInstance].currentThemeKey)] forState:0] ;
    
    WEAK_SELF
    [self.btUser bk_addEventHandler:^(id sender) {
        
        [weakSelf.btUser oct_buttonClickAnimationComplete:^{
            
            [SettingVC getMeFromCtrller:weakSelf fromView:weakSelf.btUser] ;
        }] ;
        
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    
    [self.btSearch bk_addEventHandler:^(id sender) {
        
        [weakSelf.btSearch oct_buttonClickAnimationComplete:^{
            
            [SearchVC showSearchVCFrom:weakSelf] ;
        }] ;
        
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [self.btAdd bk_whenTapped:^{
        
        [weakSelf.btAdd oct_buttonClickAnimationComplete:^{
            
            [weakSelf addBtOnClick:weakSelf.btAdd] ;
        }] ;
    }] ;
    
    
    
    // 短topbar  全部 按钮
    self.btBooksSmall_All = ({
        UIView *obj = [UIView new] ;
        obj.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor, .95) ;
        
        UIImageView *btImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bt_s_t_all"]] ;
        [obj addSubview:btImageView] ;
        [btImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(obj) ;
            make.size.mas_equalTo(CGSizeMake(32, 32)) ;
        }] ;

        UIImageView *shadowImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smallTopbar_shadow"]] ;
        [obj addSubview:shadowImage] ;
        [shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(obj) ;
            make.width.equalTo(@4) ;
        }] ;
        
        obj.alpha = 0 ;
        [self.view addSubview:obj] ;
        [obj mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.top.bottom.equalTo(self.midBar) ;
            make.width.equalTo(@46) ;
        }] ;

        [obj bk_whenTapped:^{
            [weakSelf goToAllBookVC] ;
        }] ;
        
        obj ;
    }) ;
    
    [self.btAllNote bk_addEventHandler:^(id sender) {
        [weakSelf goToAllBookVC] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    
    UIView *sepLine = [UIView new] ;
    sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .1) ;
    [self.view addSubview:sepLine] ;
    [sepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.left.equalTo(self.view) ;
        make.height.equalTo(@.5) ;
        make.top.equalTo(self.mainCollectionView) ;
    }] ;
    

    

//    @weakify(self)
//    [[[RACObserve(self.mainCollectionView, contentOffset) map:^id _Nullable(id  _Nullable value) {
//        return @([value CGPointValue].x) ;
//    }]
//       throttle:.2]
//     subscribeNext:^(id  _Nullable x) {
//        @strongify(self)
//        NSLog(@"x : %@",x) ;
//        [self scrollViewEndScroll:self.mainCollectionView] ;
//    }] ;
    
}

- (void)goToAllBookVC {
    [OcAllBookVC getMeFrom:self] ;
}

- (void)addBtOnClick:(id)sender {
    [self btAddOnClick] ;
}


- (void)moveMainCollection {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.mainCollectionView.xt_currentIndexPath.row == self.bookCurrentIdx) return ;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
        [self.mainCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO] ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath] ;
            [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
        }) ;
    }) ;
}

- (void)moveBigBookCollection {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.bookCollectionView.xt_currentIndexPath.row == self.bookCurrentIdx) return ;
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
        
        [self.bookCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:YES] ;
    }) ;
}




#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.bookCollectionView) {
        return self.bookList.count ;
    }
    else if (collectionView == self.mainCollectionView) {
        return self.bookList.count ;
    }
    return 0 ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteBooks *book = self.bookList[indexPath.row] ;
    
    if (collectionView == self.bookCollectionView) {
        OcBookCell *cell = [OcBookCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        [cell xt_configure:book indexPath:indexPath] ;
        return cell ;
    }
    else if (collectionView == self.mainCollectionView) {
        OcContainerCell *cell = [OcContainerCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        [cell xt_configure:book indexPath:indexPath] ;
        return cell ;
    }
    return nil ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.bookCollectionView) {
        self.currentBook = self.bookList[indexPath.row] ;
        [self refreshBars] ;
        [self moveMainCollection] ;
    }
    else if (collectionView == self.mainCollectionView) {
        
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.mainCollectionView) {
        return CGSizeMake([GlobalDisplaySt sharedInstance].containerSize.width ,
                          [GlobalDisplaySt sharedInstance].containerSize.height - (APP_STATUSBAR_HEIGHT) - 49. - self.newMidHeight) ;
    }
    else if (collectionView == self.bookCollectionView) {
        return CGSizeMake(72, 77) ;
    }
    return CGSizeZero ;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView != self.mainCollectionView) return ;
    
    // 滚动开始时, 刷新mainCollection 的 container
    [((OcContainerCell *)cell).contentCollection xt_loadNewInfoInBackGround:YES] ;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.mainCollectionView) return ;
    [self scrollViewEndScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.mainCollectionView) return ;
    if (!decelerate) [self scrollViewEndScroll:scrollView];
}

// 滚动停止时, 刷新topbar
- (void)scrollViewEndScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewEndScroll") ;
    
    NSInteger row = self.mainCollectionView.xt_currentIndexPath.row ;
    if (row == self.bookCurrentIdx) return ;
    
    self.currentBook = self.bookList[row] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        if (self.uiStatus_TopBar_turnSmall) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.segmentBooks moveToIndex:self.bookCurrentIdx] ;
            }) ;
        }
        else {
            [self.bookCollectionView reloadData] ;
            [self moveBigBookCollection] ;
        }
    }) ;
}





#pragma mark - segmentBooks callback XTStretchSegmentDelegate

- (NSInteger)stretchSegment_CountsOfDatasource {
    return self.bookList.count;
}

- (NSString *)stretchSegment:(XTStretchSegment *)segment titleOfDataAtIndex:(NSInteger)index {
    NoteBooks *book = self.bookList[index] ;
    NSString *nameBook = book.name ;
    if (nameBook.length > 15) nameBook = [[nameBook substringToIndex:15] stringByAppendingString:@"..."] ;    
    return nameBook ;
}

- (UIView *)overlayView {
    UIView *clearBg = [UIView new] ;
    clearBg.backgroundColor = nil ;
    clearBg.frame = CGRectMake(0, 0, 22, 51) ;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_sel_mark"]] ;
    imageView.xt_theme_imageColor = k_md_themeColor ;
    [clearBg addSubview:imageView] ;
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(clearBg) ;
        make.bottom.equalTo(clearBg) ;
        make.size.mas_equalTo(CGSizeMake(22, 3)) ;
    }] ;
    return clearBg ;
}

- (void)stretchSegment:(XTStretchSegment *)segment didSelectedIdx:(NSInteger)idx {
    NSLog(@"did select : %@", @(idx)) ;
    self.currentBook = self.bookList[idx] ;
    [self refreshBars] ;
    [self moveMainCollection] ;
}


@end
