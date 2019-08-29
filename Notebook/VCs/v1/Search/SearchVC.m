//
//  SearchVC.m
//  Notebook
//
//  Created by teason23 on 2019/4/16.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SearchVC.h"
#import <UINavigationController+FDFullscreenPopGesture.h>
#import "MarkdownVC.h"
#import "MDNavVC.h"
#import "SearchEmptyVC.h"
#import "SchBarPositiveTransition.h"
#import "OcNoteCell.h"


@interface SearchVC () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (copy, nonatomic) NSArray *listResult ;
@end

@implementation SearchVC

+ (void)showSearchVCFrom:(UIViewController *)fromCtrller {
    SearchVC *vc = [SearchVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"SearchVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:vc] ;
    fromCtrller.definesPresentationContext = YES;
    navVC.transitioningDelegate = (id<UIViewControllerTransitioningDelegate>)fromCtrller ; // !!
    navVC.modalPresentationStyle = UIModalPresentationOverCurrentContext ;
    [fromCtrller presentViewController:navVC animated:YES completion:^{}] ;
}


- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.topFlex.constant = APP_STATUSBAR_HEIGHT ;
    [self.tf becomeFirstResponder] ;
    
    @weakify(self)
    [self.btCancel bk_addEventHandler:^(id sender) {
        @strongify(self)
        [self.tf resignFirstResponder] ;
        [self dismissViewControllerAnimated:YES completion:nil] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    [[[self.tf.rac_textSignal throttle:.3]
      deliverOnMainThread]
     subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
         [self render] ;
    }] ;
    
    UISwipeGestureRecognizer *recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)] ;
    [self.view addGestureRecognizer:recognizer] ;
}

- (void)handleSwipeFrom:(id)gest {
    [self.tf resignFirstResponder] ;
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.topArea.xt_theme_backgroundColor = k_md_bgColor ;
    self.searchBar.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, 0.03) ;
    self.tf.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.8)  ;
    self.tf.placeholder = @"搜索笔记" ;
    UIColor *color = [[MDThemeConfiguration sharedInstance] themeColor:XT_MAKE_theme_color(k_md_textColor, 0.3)] ;
    [self.tf setValue:color forKeyPath:@"_placeholderLabel.textColor"] ;
    [self.tf setValue:[UIFont systemFontOfSize:16] forKeyPath:@"_placeholderLabel.font"] ;
    
    self.btCancel.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, 0.6)  ;
    self.imgSearch.xt_theme_imageColor = XT_MAKE_theme_color(k_md_iconColor, .6) ;
    
    [OcNoteCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = self ;
    self.collectionView.delegate = self ;
    self.collectionView.xt_theme_backgroundColor = k_md_bgColor ;
    
    SearchEmptyVC *phVC = [SearchEmptyVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
    self.collectionView.customNoDataView = phVC.view ;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float wid = ( APP_WIDTH - 10. * 3 ) / 2. ;
    float height = wid  / 345. * 432. ;
    layout.itemSize = CGSizeMake(wid, height) ;
    layout.minimumLineSpacing = 10 ;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
    self.collectionView.collectionViewLayout = layout ;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated] ;
    
    self.collectionView.scrollEnabled = YES ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_SearchVC_On_Window object:@1] ;
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_SearchVC_On_Window object:@0] ;
}

#pragma mark - table

- (void)render {
    NSString *searchForText = self.tf.text ;
    if (searchForText.length) {
        NSString *sql = XT_STR_FORMAT(@"searchContent like '%%%@%%' and isDeleted == 0",searchForText) ;
        NSArray *list = [Note xt_findWhere:sql] ;
        self.listResult = list ;
    }
    else
        self.listResult = @[] ;
    
    [self.collectionView reloadData] ;
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.listResult.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OcNoteCell *cell = [OcNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    cell.btMore.hidden = YES ;
    [cell xt_configure:self.listResult[indexPath.row] indexPath:indexPath] ;
    cell.textForSearching = self.tf.text ;
    return cell ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row ;
    Note *aNote = self.listResult[row] ;
    [MarkdownVC newWithNote:aNote bookID:aNote.noteBookId fromCtrller:self] ;
    [self.tf resignFirstResponder] ;
}

//#pragma mark - OcNoteCell call back  self.xt_viewcontroller
///**
// OcNoteCell call back
// */
//- (void)noteCellDidSelectedBtMore:(Note *)aNote fromView:(UIView *)fromView {
//
//}

@end
