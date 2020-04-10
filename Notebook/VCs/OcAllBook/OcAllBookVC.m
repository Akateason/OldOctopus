//
//  OcAllBookVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/23.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcAllBookVC.h"
#import "OcBookCell.h"
#import "NewBookVC.h"
#import "OcHomeVC.h"

@interface OcAllBookVC ()
@property (copy, nonatomic) NSArray *bookList ;

@end

@implementation OcAllBookVC

+ (instancetype)getMeFrom:(UIViewController *)fromCtrller {
    OcAllBookVC *vc = [OcAllBookVC getCtrllerFromStory:@"Home" controllerIdentifier:@"OcAllBookVC"] ;
    vc.delegate = (id<OcAllBookVCDelegate>)fromCtrller ;
    vc.modalPresentationStyle = UIModalPresentationFullScreen ;
    
    [fromCtrller presentViewController:vc animated:YES completion:^{}] ;
    return vc ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.bookList = @[] ;
    
    [self getAllBooks] ;
}

- (void)prepareUI {
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .9) ;
    self.btClose.xt_theme_imageColor = k_md_iconColor ;
    self.collectionView.xt_theme_backgroundColor = k_md_bgColor ;
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.collectionView.dataSource      = (id<UICollectionViewDataSource>)self ;
    self.collectionView.delegate        = (id<UICollectionViewDelegate>)self ;
    [OcBookCell xt_registerNibFromCollection:self.collectionView] ;
    
    if (!IS_IPAD) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
        layout.itemSize = CGSizeMake(72., 77.) ;
        layout.minimumLineSpacing = 30 ;
        layout.minimumInteritemSpacing = 0 ;
        layout.sectionInset = UIEdgeInsetsMake(30, 20, 100, 20) ;
        self.collectionView.collectionViewLayout = layout ;
    }
    
    
    WEAK_SELF
    [self.btClose xt_enlargeButtonsTouchArea] ;
    [self.btClose xt_addEventHandler:^(id sender) {
        
        [weakSelf.btClose oct_buttonClickAnimationComplete:^{
            [weakSelf dismissViewControllerAnimated:YES completion:^{
                [weakSelf.delegate ocAllBookVCDidClose] ;
            }] ;
        }] ;
                
    } forControlEvents:(UIControlEventTouchUpInside)] ;
}

- (void)getAllBooks {
    NoteBooks *bookRecent = [NoteBooks createOtherBookWithType:Notebook_Type_recent] ;
    NoteBooks *bookStage = [NoteBooks createOtherBookWithType:Notebook_Type_staging] ;
    NSMutableArray *tmplist = [@[bookRecent,bookStage] mutableCopy] ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        [tmplist addObjectsFromArray:array] ;
        
        NoteBooks *bookAdd = [NoteBooks createOtherBookWithType:Notebook_Type_add] ;
        [tmplist addObject:bookAdd] ;
        
        self.bookList = tmplist ;
        [self.collectionView reloadData] ;
    }] ;
}



#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.bookList.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteBooks *book = self.bookList[indexPath.row] ;
    OcBookCell *cell = [OcBookCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    [cell xt_configure:book indexPath:indexPath] ;
    cell.delegate = (id<OcBookCellDelegate>)self ;
    return cell ;
}

- (void)funcCollectionViewDidSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteBooks *book = self.bookList[indexPath.row] ;
    if (book.vType == Notebook_Type_add) {
        @weakify(self)
        [NewBookVC showMeFromCtrller:self
                            fromView:self.view
                             changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                                 @strongify(self)
                                 // create new book
                                 NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
                                 [NoteBooks createNewBook:aBook] ;
                                 [self getAllBooks] ;
                                 
                                 dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                     [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] atScrollPosition:(UICollectionViewScrollPositionCenteredVertically) animated:YES] ;
                                     [self.delegate addedABook:aBook] ;
                                 }) ;
                                 
                             } cancel:^{
                                 
                             }] ;
    }
    else {
        [self.delegate clickABook:book] ;
        [self dismissViewControllerAnimated:YES completion:^{
        }] ;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    OcBookCell *cell = (OcBookCell *)[collectionView cellForItemAtIndexPath:indexPath] ;
    WEAK_SELF
    [cell.viewForBookIcon oct_buttonClickAnimationComplete:^{
        
        [weakSelf funcCollectionViewDidSelectItemAtIndexPath:indexPath] ;
    }] ;
}


- (void)longPressed:(NSIndexPath *)indexPath {
    NoteBooks *book = self.bookList[indexPath.row] ;
    if (book.vType == Notebook_Type_add ||
        book.vType == Notebook_Type_recent ||
        book.vType == Notebook_Type_staging) return ;
    
    OcBookCell *cell = (OcBookCell *)[self.collectionView cellForItemAtIndexPath:indexPath] ;
    
    NSString *title = XT_STR_FORMAT(@"对“%@”进行以下操作",book.name) ;
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:title cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除笔记本" otherButtonTitles:@[@"重命名"] fromWithView:cell CallBackBlock:^(NSInteger btnIndex) {
        @strongify(self)
        if (btnIndex == 1) {
            @weakify(self)
            [NewBookVC showMeFromCtrller:self
                                fromView:self.view
                                editBook:book changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                                    @strongify(self)
                                    book.name = bookName ;
                                    book.emoji = [@{@"native":emoji} yy_modelToJSONString] ;
                                    [NoteBooks updateMyBook:book] ;
                                    [self getAllBooks] ;
                                    
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self.delegate renameBook:book] ;
                                    }) ;
                                } cancel:^{
                                    
                                }] ;
            
        }
        else if (btnIndex == 2) {
            @weakify(self)
            [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex1) {
                @strongify(self)
                if (btnIndex1 == 1) {
                    @weakify(self)
                    if ([book.icRecordName isEqualToString:@"book-default"]) {
                        // 默认笔记本 id
                        [SVProgressHUD showInfoWithStatus:@"不要删除[小章鱼🐙]的默认笔记本哦~"] ;
                        return ;
                    }
                                        
                    [NoteBooks deleteBook:book done:^{
                        @strongify(self)
                        NSMutableArray *tmplist = [self.bookList mutableCopy] ;
                        [tmplist removeObjectAtIndex:indexPath.row] ;
                        self.bookList = tmplist ;
                        [self.collectionView reloadData] ;
                        
                        [self.delegate deleteBook:book] ;
                    }] ;
                }
            }] ;
        }
        
    }] ;
}


@end
