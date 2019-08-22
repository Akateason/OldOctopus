//
//  OcHomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC.h"
#import "MDNavVC.h"
#import "LaunchingEvents.h"
#import "OcHomeVC+UIPart.h"




@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource,XTStretchSegmentDelegate, XTStretchSegmentDataSource>

@end

@implementation OcHomeVC

+ (UIViewController *)getMe {
    OcHomeVC *topVC = [OcHomeVC getCtrllerFromStory:@"Home" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OcHomeVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:topVC] ;
    return navVC ;
}

#pragma mark - life

- (void)prepareUI {
    [self xt_prepareUI] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.bookList = @[] ;
    
    [self getAllBooks] ;
    
    [self setupNotifications] ;
    
    //    [[[RACSignal interval:6 onScheduler:[RACScheduler mainThreadScheduler]]
    //      takeUntil:self.rac_willDeallocSignal]
    //     subscribeNext:^(NSDate * _Nullable x) {
    //         @strongify(self)
    //         if (self.view.window) {
    //             LaunchingEvents *events = ((AppDelegate *)[UIApplication sharedApplication].delegate).launchingEvents ;
    //             [events icloudSync:^{}] ;
    //         }
    //     }] ;
    //
    //    [[[self rac_signalForSelector:@selector(viewDidAppear:)] throttle:1] subscribeNext:^(RACTuple * _Nullable x) {
    //        @strongify(self)
    //        // 内测验证码
    //        [UserTestCodeVC getMeFrom:self.slidingController] ;
    //    }] ;
}

- (void)setupNotifications {
    // BOOK RELATIVE NOTIFICATES
    @weakify(self)
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         [self refreshAll] ;
     }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIApplicationDidBecomeActiveNotification object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        @weakify(self)
        [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
            if (user != nil) {
                @strongify(self)
                [self refreshAll] ;
            }
        }] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_iap_purchased_done object:nil] takeUntil:self.rac_willDeallocSignal] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self refreshAll] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:1.]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         NSLog(@"go sync list") ;
//         if (self.isOnDeleting) return ;
         
         [self refreshAll] ;
     }] ;

//    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationImportFileIn object:nil]
//       takeUntil:self.rac_willDeallocSignal]
//      deliverOnMainThread]
//     subscribeNext:^(NSNotification * _Nullable x) {
//         @strongify(self)
//         NSString *path = x.object ;
//         NSString *md = [[NSString alloc] initWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:nil] ;
//         NSString *title = [Note getTitleWithContent:md] ;
//         Note *aNote = [[Note alloc] initWithBookID:self.leftVC.currentBook.icRecordName content:md title:title] ;
//         [Note createNewNote:aNote] ;
//
//         @weakify(self)
//         [self renderTable:^{
//             @strongify(self)
//             [self newNoteCombineFunc:aNote] ;
//         }] ;
//     }] ;
//



}

#pragma mark - Funcs

- (void)refreshAll {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.uiStatus_TopBar_turnSmall) {
            [self.segmentBooks reloadData] ;
        }
        else {
            [self.bookCollectionView reloadData] ;
        }
        
        [self.mainCollectionView reloadData] ;
    }) ;
}

- (void)getAllBooks {
    NoteBooks *bookRecent = [NoteBooks createOtherBookWithType:Notebook_Type_recent] ;
    NoteBooks *bookStage = [NoteBooks createOtherBookWithType:Notebook_Type_staging] ;
    NSMutableArray *tmplist = [@[bookRecent,bookStage] mutableCopy] ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        [tmplist addObjectsFromArray:array] ;
        self.bookList = tmplist ;
        
        if (self.currentBook == nil) {
            NoteBooks *book = [self nextUsefulBook] ;
            [self setCurrentBook:book] ;
        }
        else {
            [self setCurrentBook:self.currentBook] ;
        }
        
        [self refreshAll] ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
            [self.mainCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO] ;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath] ;
                [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
            }) ;
        }) ;
        
        [self moveBigBookCollection] ;
    }] ;
}

- (NoteBooks *)nextUsefulBook {
    NSString *value = XT_USERDEFAULT_GET_VAL(kUDCached_lastBook_RecID) ;
    NoteBooks *book ;
    if (value) {
        book = [NoteBooks xt_findFirstWhere:XT_STR_FORMAT(@"icRecordName == '%@'",value)] ;
        if (!book) book = [NoteBooks createOtherBookWithType:value.intValue] ;
    }
    else {
        book = [NoteBooks xt_findFirstWhere:@"icRecordName == 'book-default'"] ;
    }
    return book ;
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

#pragma mark - props

- (void)setCurrentBook:(NoteBooks *)currentBook {
    _currentBook = currentBook ;
    
    NSString *cachedValue ;
    if (currentBook.vType != Notebook_Type_notebook ) {
        cachedValue = @(currentBook.vType).stringValue ;
    }
    else {
        cachedValue = currentBook.icRecordName ;
    }
    if (currentBook.name) XT_USERDEFAULT_SET_VAL(cachedValue, kUDCached_lastBook_RecID) ;
    
    [self.bookList enumerateObjectsUsingBlock:^(NoteBooks *book, NSUInteger idx, BOOL * _Nonnull stop) {
        book.isOnSelect = NO ;
        
        if (currentBook.vType != Notebook_Type_notebook) {
            if (currentBook.vType == book.vType) {
                book.isOnSelect = YES ;
                self.bookCurrentIdx = idx ;
            }
        }
        else {
            if ([book.icRecordName isEqualToString:currentBook.icRecordName]) {
                book.isOnSelect = YES ;
                self.bookCurrentIdx = idx ;
            }
        }
    }] ;
}

- (void)setUiStatus_TopBar_turnSmall:(BOOL)uiStatus_TopBar_turnSmall {
    _uiStatus_TopBar_turnSmall = uiStatus_TopBar_turnSmall ;

    float newMidHeight = uiStatus_TopBar_turnSmall ? 51. : 134. ;
    
    [UIView animateWithDuration:.3 animations:^{
        
        // hidden or show
        self.height_midBar.constant = newMidHeight ;
        self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = uiStatus_TopBar_turnSmall ? 0 : 1 ;
        
        self.segmentBooks.hidden = !uiStatus_TopBar_turnSmall ;
        
        // collection flow
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
        layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - newMidHeight) ;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
        layout.minimumLineSpacing = 0 ;
        self.mainCollectionView.collectionViewLayout = layout ;
        
    } completion:^(BOOL finished) {
        
        if (uiStatus_TopBar_turnSmall) { // 静态刷新 segmentBooks 的选中状态
            [self.segmentBooks setValue:@(self.bookCurrentIdx) forKey:@"currentIndex"] ;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.segmentBooks reloadData] ;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.segmentBooks setOverLayUI] ;
                }) ;
            }) ;
        }
        else {
            [self.bookCollectionView reloadData] ;
        }
    }] ;
}

- (XTStretchSegment *)segmentBooks{
    if(!_segmentBooks){
        _segmentBooks = ({
            XTStretchSegment *object = [XTStretchSegment getNew] ;
            [object setupTitleColor:nil selectedColor:nil bigFontSize:17 normalFontSize:14 hasUserLine:YES lineSpace:20 sideMargin:20] ;
            [object setupCollections] ;
            object.xtSSDelegate    = self;
            object.xtSSDataSource  = self;
            object.hidden = YES ;
            if (!object.superview) {
                [self.midBar addSubview:object] ;
                [object mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.midBar) ;
                }] ;
            }
            object;
        });
    }
    return _segmentBooks;
}

- (HomeAddButton *)btAdd {
    if (!_btAdd) {
        _btAdd = [[HomeAddButton alloc] init] ;
        [self.view addSubview:_btAdd] ;
        [_btAdd mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(50, 50)) ;
            make.bottom.equalTo(self.view).offset(-45) ;
            make.right.equalTo(self.view).offset(-20) ;
        }] ;
    }
    return _btAdd ;
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
        [self refreshAll] ;
        [self moveMainCollection] ;
        [self.segmentBooks setOverLayUI] ;
    }
    else if (collectionView == self.mainCollectionView) {
        
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView != self.mainCollectionView) return ;
    [self scrollViewEndScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView != self.mainCollectionView) return ;
    if (!decelerate) [self scrollViewEndScroll:scrollView];
}

- (void)scrollViewEndScroll:(UIScrollView *)scrollView {
    NSLog(@"scrollViewEndScroll") ;
    NSInteger row = self.mainCollectionView.xt_currentIndexPath.row ;
    if (row == self.bookCurrentIdx) return ;
    
    self.currentBook = self.bookList[row] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
        [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
        
        if (self.uiStatus_TopBar_turnSmall) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.segmentBooks moveToIndex:self.bookCurrentIdx] ;
            }) ;
        }
        else {
            [self.bookCollectionView reloadData] ;
            [self moveBigBookCollection] ;
        }
        
        [self.segmentBooks setOverLayUI] ;
    }) ;
}



#pragma mark - OcContainerCell callback
// up - YES, down - NO.
- (void)containerCellDraggingDirection:(BOOL)directionUp {
    if (directionUp != self.uiStatus_TopBar_turnSmall) self.uiStatus_TopBar_turnSmall = directionUp ;
//    if (!directionUp) {NSLog(@"下")}
//    else {NSLog(@"上")} ;
}

#pragma mark - segmentBooks callback XTStretchSegmentDelegate

- (NSInteger)stretchSegment_CountsOfDatasource {
    return self.bookList.count;
}

- (NSString *)stretchSegment:(XTStretchSegment *)segment titleOfDataAtIndex:(NSInteger)index {
    NoteBooks *book = self.bookList[index] ;
    return book.name ;
}

- (UIView *)overlayView {
    UIView *clearBg = [UIView new] ;
    clearBg.backgroundColor = nil ;
    clearBg.frame = CGRectMake(0, 0, 22, 51) ;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"book_sel_mark"]] ;
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
    [self refreshAll] ;
    [self moveMainCollection] ;
}



@end
