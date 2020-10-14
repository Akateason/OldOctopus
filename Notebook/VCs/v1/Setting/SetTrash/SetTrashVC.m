//
//  SetTrashVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "SetTrashVC.h"
#import "OcNoteCell.h"
#import "OcHomeEmptyVC.h"

@interface SetTrashVC ()
@property (nonatomic, copy) NSArray *list ;
@end

@implementation SetTrashVC

+ (instancetype)showFromCtller:(UIViewController *)fromCtrller {
    SetTrashVC *vc = [SetTrashVC getCtrllerFromStory:@"Main" controllerIdentifier:@"SetTrashVC"] ;
    [fromCtrller.navigationController pushViewController:vc animated:YES] ;
    return vc ;
}

// 清空
- (void)clearAllTrash {
    [Note deleteTheseNotes:self.list fromICloudComplete:^(bool success) {
        
    }] ;
    
    for (Note *aNote in self.list) {
        [aNote xt_deleteModel] ;
    }
    
    self.list = @[] ;
    //[Note xt_findWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"] ;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.collectionView reloadData] ;
    }) ;
    
}

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    [[self.btBack rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        [self.navigationController popViewControllerAnimated:YES] ;
    }] ;
    
    [[self.btClear rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self)
        @weakify(self)
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"此操作将会清空垃圾桶内所有笔记，而且不可恢复。确认要清空吗？" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认清空" otherButtonTitles:nil fromWithView:self.btClear CallBackBlock:^(NSInteger btnIndex) {
            @strongify(self)
            if (btnIndex == 1) {
                [self clearAllTrash] ;
            }
        }] ;
    }] ;
    
    self.btBack.xt_theme_imageColor = k_md_iconColor ;
    self.lbTitle.xt_theme_textColor = XT_MAKE_theme_color(k_md_textColor, .9) ;
    self.btClear.xt_theme_textColor = k_md_themeColor ;
    self.sepLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_textColor, .1) ;
    
    self.view.xt_theme_backgroundColor = k_md_bgColor ;
    self.topBar.xt_theme_backgroundColor = k_md_bgColor ;
    self.collectionView.xt_theme_backgroundColor = k_md_backColor ;
    
    
    [OcNoteCell xt_registerNibFromCollection:self.collectionView] ;
    self.collectionView.dataSource = (id<UICollectionViewDataSource>)self ;
    self.collectionView.delegate = (id<UICollectionViewDelegate>)self ;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float wid = ( ( IS_IPAD ? 400. : APP_WIDTH ) - 10. * 3 ) / 2. ;
    float height = wid  / 345. * 432. ;
    layout.itemSize = CGSizeMake(wid, height) ;
    layout.minimumLineSpacing = 10 ;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
    self.collectionView.collectionViewLayout = layout ;
    
    OcHomeEmptyVC *emptyVc = [OcHomeEmptyVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
    self.collectionView.customNoDataView = emptyVc.view ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    // Do any additional setup after loading the view.
    self.list = [Note xt_findWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"] ;
    
    @weakify(self)
    [[RACObserve(self, list) map:^id _Nullable(NSArray *list) {
        return @(list.count > 0) ;
    }] subscribeNext:^(NSNumber *x) {
        @strongify(self)
        BOOL enable = [x intValue] ;
        self.btClear.enabled = enable ;
        self.btClear.alpha = enable ? 1 : .3 ;
    }] ;
}

#pragma mark - UICollectionViewDataSource <NSObject>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.list.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    OcNoteCell *cell = [OcNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    [cell xt_configure:self.list[indexPath.row] indexPath:indexPath] ;
    cell.trashState = YES ;
    return cell ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // Completely Delete Note
    Note *aNote = self.list[indexPath.row] ;
    __block OcNoteCell *cell = (OcNoteCell *)[collectionView cellForItemAtIndexPath:indexPath] ;
    NSString *title = XT_STR_FORMAT(@"对《%@》完成以下操作", [Note filterTitle:aNote.title]) ;
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:title cancelButtonTitle:@"取消" destructiveButtonTitle:@"彻底删除" otherButtonTitles:@[@"恢复"] fromWithView:self.collectionView CallBackBlock:^(NSInteger btnIndex) {
        @strongify(self)
        if (btnIndex == 2) {
            [self completelyDeleteNote:aNote fromCell:cell didSelectItemAtIndexPath:indexPath] ;
        }
        else if (btnIndex == 1) {
            [self recoverNotee:aNote] ;
        }
        
    }] ;

}

- (void)completelyDeleteNote:(Note *)aNote fromCell:(OcNoteCell *)cell didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *title = XT_STR_FORMAT(@"确认要彻底删除《%@》吗?", [Note filterTitle:aNote.title]) ;
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:title message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            NSMutableArray *tmplist = [self.list mutableCopy] ;
            [tmplist removeObjectAtIndex:indexPath.row] ;
            self.list = tmplist ;
            [self.collectionView deleteItemsAtIndexPaths:@[indexPath]] ;
            
            [Note deleteThisNoteFromICloud:aNote complete:^(bool success) {
                
            }] ;
        }
    }] ;
}

- (void)recoverNotee:(Note *)aNote {
    NSString *title = XT_STR_FORMAT(@"确认要恢复《%@》吗?",aNote.title) ;
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:title message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            aNote.isDeleted = NO ;
            [aNote xt_update] ;
            [Note updateMyNote:aNote] ;
            
            NoteBooks *book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",aNote.noteBookId)] ;
            book.isDeleted = NO ;
            [book xt_update] ;
            [NoteBooks updateMyBook:book] ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.list = [Note xt_findWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"] ;
                [self.collectionView reloadData] ;
            }) ;
        }
    }] ;
}


@end
