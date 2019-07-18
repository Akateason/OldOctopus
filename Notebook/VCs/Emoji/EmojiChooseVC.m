//
//  EmojiChooseVC.m
//  Notebook
//
//  Created by teason23 on 2019/7/4.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "EmojiChooseVC.h"
#import "EmojiCell.h"
#import "EmojiCollectHeader.h"
#import "UIViewController+SlidingController.h"
#import "NHSlidingController.h"

@interface EmojiChooseVC ()
@property (copy, nonatomic) NSDictionary *datasource ;
@property (copy, nonatomic) NSArray *dataCate ;
@property (copy, nonatomic) NSArray *history ;
@property (strong, nonatomic) UIView *sectionSelectedUnderLine ;

@property (copy, nonatomic) NSArray *searchData ;
@property (copy, nonatomic) NSArray *searchResult ;
@end

@implementation EmojiChooseVC

+ (void)showMeFrom:(UIViewController *)contentController
          fromView:(UIView *)fromView {
    
    EmojiChooseVC *vc = [EmojiChooseVC getCtrllerFromStory:@"Main" controllerIdentifier:@"EmojiChooseVC"] ;
    vc.delegate = fromView.xt_viewController ;
    
    vc.modalPresentationStyle = UIModalPresentationPopover ;
    [contentController presentViewController:vc animated:YES completion:nil] ;
    UIPopoverPresentationController *popVC = vc.popoverPresentationController ;
    popVC.sourceView = fromView ;
    popVC.sourceRect = fromView.bounds ;
    popVC.permittedArrowDirections = UIPopoverArrowDirectionAny ;
    popVC.xt_theme_backgroundColor = k_md_bgColor ;

    vc.view.xt_borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_iconColor, .2) ;
    vc.view.xt_borderWidth = 1 ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    NSMutableArray *tmpCate = [@[@"最近使用"] mutableCopy] ;
    [tmpCate addObjectsFromArray:[EmojiJsonManager sharedInstance].arrayCategory] ;
    self.dataCate = tmpCate ;
    self.datasource = [EmojiJsonManager sharedInstance].getWholeDatasource ;
    
    self.history = [EmojiJsonManager sharedInstance].history ;
    self.searchData = [EmojiJsonManager sharedInstance].allList ;
    
    WEAK_SELF
    [self.btClose bk_addEventHandler:^(id sender) {
        [weakSelf dismissViewControllerAnimated:YES completion:^{}] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    [self.lbHistory bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbHistory] ;
    }] ;
    [self.lbPeople bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbPeople] ;
    }] ;
    [self.lbAnimal bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbAnimal] ;
    }] ;
    [self.lbFood bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbFood] ;
    }] ;
    [self.lbActive bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:4] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbActive] ;
    }] ;
    [self.lbPlace bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:5] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbPlace] ;
    }] ;
    [self.lbObject bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:6] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbObject] ;
    }] ;
    [self.lbSymbol bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:7] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbSymbol] ;
    }] ;
    [self.lbFlag bk_whenTapped:^{
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:8] ;
        [weakSelf.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionTop)
                                            animated:YES] ;
        [weakSelf moveSelectedUnderLine:weakSelf.lbFlag] ;
    }] ;
    
    @weakify(self)
    [[[self.tfSearch.rac_textSignal throttle:.5] deliverOnMainThread] subscribeNext:^(NSString * _Nullable x) {
        @strongify(self)
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [self.searchData enumerateObjectsUsingBlock:^(EmojiJson *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.desc containsString:x]) {
                [tmplist addObject:obj] ;
            }
        }] ;
        self.searchResult = tmplist ;
        [self.collectionView reloadData] ;
    }] ;
}

- (void)moveSelectedUnderLine:(UIView *)view {
    [UIView animateWithDuration:.1 animations:^{
        self.sectionSelectedUnderLine.centerX = view.centerX ;
    }] ;
}

- (void)prepareUI {
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.searchBarBg.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    self.lbTitle.xt_theme_textColor = k_md_textColor ;
    self.tfSearch.xt_theme_backgroundColor = k_md_midDrawerPadColor ;
    self.tfSearch.xt_theme_textColor = k_md_textColor ;
    UIColor *color = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .5) ;
    [self.tfSearch setValue:color forKeyPath:@"_placeholderLabel.textColor"] ;
    
    [self.btClose xt_enlargeButtonsTouchArea] ;
    
    self.collectionView.xt_theme_backgroundColor = k_md_bgColor ;
    [self.collectionView registerNib:[UINib nibWithNibName:@"EmojiCollectHeader" bundle:[NSBundle mainBundle]] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmojiCollectHeader"] ;
    [EmojiCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = (id<UICollectionViewDataSource> )self ;
    self.collectionView.delegate = (id<UICollectionViewDelegate> )self ;
    
    [self sectionSelectedUnderLine] ;
}

#pragma mark - UICollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.searchResult.count ? 1 : self.dataCate.count ;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.searchResult.count) {
        return self.searchResult.count ;
    }
    else {
        if (section == 0) {
            return self.history.count ; // 最近
        }
        return [self.datasource[self.dataCate[section]] count] ;
    }
    return 0 ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    EmojiCell *cell = [EmojiCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    if (self.searchResult.count) {
        [cell xt_configure:self.searchResult[row]] ;
    }
    else {
        if (section == 0) {
            [cell xt_configure:self.history[row]] ;
        }
        else {
            [cell xt_configure:self.datasource[self.dataCate[section]][row]] ;
        }
    }
    return cell ;
}

// UICollectionViewFlowLayout

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        EmojiCollectHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"EmojiCollectHeader" forIndexPath:indexPath] ;
        if (self.searchResult.count) {
            header.lbTitle.text = @"" ;
        }
        else {
            if (indexPath.section == 0) {
                header.lbTitle.text = self.dataCate[indexPath.section] ;
            }
            else {
                header.lbTitle.text = [EmojiJsonManager sharedInstance].chineseCategory[indexPath.section - 1] ;
            }
        }
        return header ;
    }
    return nil ;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayou referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(collectionView.width, 36) ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger section = indexPath.section ;
    NSInteger row = indexPath.row ;
    EmojiJson *resultEmoji ;
    if (self.searchResult.count) {
        resultEmoji = self.searchResult[row] ;
    }
    else {
        if (section == 0) {
            resultEmoji = self.history[row] ;
        }
        else {
            resultEmoji = self.datasource[self.dataCate[section]][row] ;
        }
    }
    
    [self.delegate selectedEmoji:resultEmoji] ;
    
    [[EmojiJsonManager sharedInstance] iUseEmoji:resultEmoji] ;
    self.history = [EmojiJsonManager sharedInstance].history ;
    [collectionView reloadData] ;
    
    [self dismissViewControllerAnimated:YES completion:nil] ;
}

#pragma mark - acitons

- (UIView *)sectionSelectedUnderLine{
    if(!_sectionSelectedUnderLine){
        [self.topBar setNeedsLayout] ;
        [self.topBar layoutIfNeeded] ;
        
        _sectionSelectedUnderLine = ({
            float wid = self.view.width / 9 - 20 ;
            UIView *object = [[UIView alloc] initWithFrame:CGRectMake(0, 0, wid, 1.5)];
            object.xt_theme_backgroundColor = k_md_textColor ;
            object.bottom = self.topBar.height - 1.5 ;
            object.centerX = self.lbHistory.centerX ;
            [self.topBar addSubview:object] ;
            object;
       });
    }
    return _sectionSelectedUnderLine;
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews] ;
    
    self.sectionSelectedUnderLine.width = self.view.width / 9 - 20 ;
}

@end
