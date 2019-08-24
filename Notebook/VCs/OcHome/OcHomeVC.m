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
#import "MarkdownVC.h"



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
        [self.segmentBooks moveToIndex:self.bookCurrentIdx] ;
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

- (void)btAddOnClick {
    @weakify(self)
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"🖋 新建笔记",@"📒 新建笔记本"] fromWithView:self.btAdd CallBackBlock:^(NSInteger btnIndex) {
        
        @strongify(self)
        if (btnIndex == 1) { // new note
            [self addNoteOnClick] ;
        }
        else if (btnIndex == 2) { // new book
            [self addBookOnClick] ;
        }
    }] ;
}

- (void)addNoteOnClick {
    [MarkdownVC newWithNote:nil bookID:self.currentBook.icRecordName fromCtrller:self] ;
}

- (void)addBookOnClick {
    @weakify(self)
    [NewBookVC showMeFromCtrller:self
                        fromView:self.btAdd
                         changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                             @strongify(self)
                             // create new book
                             NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
                             [NoteBooks createNewBook:aBook] ;
                             
                             // save curent book in UD .
                             [self addedABook:aBook] ;
                             
                         } cancel:^{

                         }] ;
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
    
    [UIView animateWithDuration:.2 animations:^{
        
        // hidden or show
        self.height_midBar.constant = newMidHeight ;
        self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = uiStatus_TopBar_turnSmall ? 0 : 1 ;
        
        self.segmentBooks.alpha = self.btBooksSmall_All.alpha = uiStatus_TopBar_turnSmall ? 1 : 0 ;
        
        // collection flow
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
        layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - newMidHeight) ;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
        layout.minimumLineSpacing = 0 ;
        self.mainCollectionView.collectionViewLayout = layout ;
        
    } completion:^(BOOL finished) {
        
    }] ;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.segmentBooks setValue:@(self.bookCurrentIdx) forKey:@"currentIndex"] ;
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
        [self.segmentBooks scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO] ;
        [self.segmentBooks reloadData] ;
        
        [self.bookCollectionView reloadData] ;
    }) ;
    
}

- (XTStretchSegment *)segmentBooks{
    if(!_segmentBooks){
        _segmentBooks = ({
            XTStretchSegment *object = [XTStretchSegment getNew] ;
            [object setupTitleColor:nil selectedColor:nil bigFontSize:17 normalFontSize:14 hasUserLine:YES lineSpace:20 sideMarginLeft:20 sideMarginRight:56] ;
            [object setupCollections] ;
            object.xtSSDelegate    = self;
            object.xtSSDataSource  = self;
            object.alpha = 0 ;
            if (!object.superview) {
                [self.midBar addSubview:object] ;
                [object mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.equalTo(self.midBar) ;
                }] ;
            }
            object ;
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

#pragma mark - OcContainerCell callback
// up - YES, down - NO.
- (void)containerCellDraggingDirection:(BOOL)directionUp {
    if (directionUp != self.uiStatus_TopBar_turnSmall) self.uiStatus_TopBar_turnSmall = directionUp ;
    //    if (!directionUp) {NSLog(@"下")}
    //    else {NSLog(@"上")} ;
}

#pragma mark - OcAllBookVCDelegate <NSObject>

- (void)clickABook:(NoteBooks *)book {
    self.currentBook = book ;
    [self refreshAll] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self moveMainCollection] ;
        [self moveBigBookCollection] ;
        [self.segmentBooks moveToIndex:self.bookCurrentIdx] ;
    }) ;
}

- (void)addedABook:(NoteBooks *)book {
    self.currentBook = book ;
    
    [self getAllBooks] ;
}

- (void)renameBook:(NoteBooks *)book {
    self.currentBook = book ;
    
    [self getAllBooks] ;
}

- (void)deleteBook:(NoteBooks *)book {
    self.bookList = @[] ;
    [self refreshAll] ;
    
    [self getAllBooks] ;
}

- (void)ocAllBookVCDidClose {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath] ;
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
}

@end
