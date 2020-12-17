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
#import <FTPopOverMenu/FTPopOverMenu.h>
#import "MoveNoteToBookVC.h"
#import "UserTestCodeVC.h"
#import "OcHomeVC+Notifications.h"
#import "SchBarPositiveTransition.h"
#import "SettingSave.h"
#import "OcHomeVC+Keycommand.h"

@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource,XTStretchSegmentDelegate, XTStretchSegmentDataSource>
@property (strong, nonatomic) SchBarPositiveTransition  *transition ;
@property (strong, nonatomic) MoveNoteToBookVC *moveVC ;
@property (strong, nonatomic) RACSubject *subjectTraitCollectionDidChange ; // 解决TraitCollectionDidChange多次触发.
@end

@implementation OcHomeVC

+ (UIViewController *)getMe {
    OcHomeVC *topVC = [OcHomeVC getCtrllerFromStory:@"Home" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OcHomeVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:topVC] ;
    return navVC ;
}

#pragma mark - life

- (void)prepareUI {
    AppDelegate *appDelegate = (AppDelegate *)([UIApplication sharedApplication].delegate) ;
    [GlobalDisplaySt sharedInstance].containerSize = appDelegate.window.size ;
    [[GlobalDisplaySt sharedInstance] correctCurrentCondition:self] ;
    
    [self xt_prepareUI] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.subjectTraitCollectionDidChange = [RACSubject subject] ;
    self.bookList = @[] ;
    [self getAllBooks] ;
    [self xt_setupNotifications] ;
    
    

    
    

    
    @weakify(self)
    [[[RACSignal interval:6 onScheduler:[RACScheduler mainThreadScheduler]]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSDate * _Nullable x) {
         @strongify(self)
         if (self.view.window) {
             LaunchingEvents *events = ((AppDelegate *)[UIApplication sharedApplication].delegate).launchingEvents ;
             [events icloudSync:^{}] ;
         }
     }] ;
    
    [[[self rac_signalForSelector:@selector(viewDidAppear:)] throttle:1] subscribeNext:^(RACTuple * _Nullable x) {
        @strongify(self)
        // 内测验证码
        [UserTestCodeVC getMeFrom:self] ;
    }] ;
    
    [[[[self.subjectKeycommand throttle:.6] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        [self keycommandCallback:x] ;
    }] ;
    
    [[[[self.subjectTraitCollectionDidChange throttle:.4] deliverOnMainThread] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        @strongify(self)

        if (@available(iOS 12.0, *)) {
            SettingSave *sSave = [SettingSave fetch] ;
            if (sSave.theme_isChangeWithSystemDarkmode) {
                if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark
                    &&
                    ![GlobalDisplaySt sharedInstance].currentSystemIsDarkMode) { // dark
                    
                    [[MDThemeConfiguration sharedInstance] setThemeDayOrNight:YES] ;
                    [GlobalDisplaySt sharedInstance].currentSystemIsDarkMode = YES ;
                }
                else if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight
                         &&
                         [GlobalDisplaySt sharedInstance].currentSystemIsDarkMode) { // light
                    
                    [[MDThemeConfiguration sharedInstance] setThemeDayOrNight:NO] ;
                    [GlobalDisplaySt sharedInstance].currentSystemIsDarkMode = NO ;
                }
            }
        }
        else {
            // Fallback on earlier versnions
        }
    }] ;
    
    if (@available(iOS 12.0, *)) [GlobalDisplaySt sharedInstance].currentSystemIsDarkMode = self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark ;
    else [GlobalDisplaySt sharedInstance].currentSystemIsDarkMode = NO ;
}




#pragma mark - Funcs

- (void)refreshAll {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshBars] ;
        
        [self refreshContents] ;
    }) ;
}

- (void)refreshBars {
    [self.segmentBooks reloadData] ;
    
    [self.bookCollectionView reloadData] ;
}

- (void)refreshContents {
    [self.mainCollectionView reloadData] ;
}

static NSString *const kCache_Last_Update_Note_Info_Time = @"kCache_Last_Update_Note_Info_Time" ;
- (void)getAllBooks {
    NoteBooks *bookRecent = [NoteBooks createOtherBookWithType:Notebook_Type_recent] ;
    NoteBooks *bookStage = [NoteBooks createOtherBookWithType:Notebook_Type_staging] ;
    NSMutableArray *tmplist = [@[bookRecent,bookStage] mutableCopy] ;
    
    [NoteBooks fetchAllNoteBook:^(NSArray<NoteBooks *> * _Nonnull array) {
        if (array.count > 0) {
            XT_USERDEFAULT_SET_VAL(@([[NSDate date] xt_getTick]), kCache_Last_Update_Note_Info_Time) ;
        }
        
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
            
            [self.mainCollectionView setContentOffset:CGPointMake(self.bookCurrentIdx * CGRectGetWidth(self.view.bounds), 0)];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath] ;
                [cell refresh] ;
            }) ;
        }) ;
        
        [self moveBigBookCollection] ;
        [self.segmentBooks moveToIndex:self.bookCurrentIdx] ;
    }] ;
}

- (void)getAllBooksIfNeeded {
    NSNumber *lastTick = XT_USERDEFAULT_GET_VAL(kCache_Last_Update_Note_Info_Time) ;
    NSDate *lastUpdateTime = [NSDate xt_getDateWithTick:lastTick.longLongValue] ;
    NSTimeInterval time = [[NSDate date] timeIntervalSinceDate:lastUpdateTime] ;
    if (time < 5) {
        NSLog(@"未超过时间, 不刷新book, %@s之内刷新过了",@(time)) ;
        return ;
    }
    
    [self getAllBooks] ;
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
    [self addNoteOnClick] ;
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


- (void)moveNote:(Note *)aNote {
    @weakify(self)
    self.moveVC =
    [MoveNoteToBookVC showFromCtrller:self
                           moveToBook:^(NoteBooks * _Nonnull book) {
                               @strongify(self)
                               aNote.noteBookId = book.icRecordName ;
                               [Note updateMyNote:aNote] ;
                               self.currentBook = book ;
                               [self getAllBooks] ;
                           }] ;
}

- (void)changeNoteTopState:(Note *)aNote {
    aNote.isTop = !aNote.isTop ;
    aNote.modifyDateOnServer = [[NSDate date] xt_getTick] ;
    [Note updateMyNote:aNote] ;
    
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0]] ;
    [cell refresh] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell.contentCollection setContentOffset:CGPointZero animated:YES] ;
    }) ;
}

- (void)deleteNote:(Note *)aNote {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"确认要将此文章放入垃圾桶?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        if (btnIndex == 1) {
            aNote.isDeleted = YES ;
            [Note updateMyNote:aNote] ;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self getAllBooks] ;
            }) ;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Delete_Note_In_Pad object:nil] ;
        }
    }] ;
}

- (float)newMidHeight {
    return self.uiStatus_TopBar_turnSmall ? 51. : 134. ;
}

- (void)setupStructCollectionLayout {
    [self.mainCollectionView setNeedsLayout] ;
    [self.mainCollectionView setNeedsDisplay] ;
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake([GlobalDisplaySt sharedInstance].containerSize.width ,
                                 [GlobalDisplaySt sharedInstance].containerSize.height - (APP_STATUSBAR_HEIGHT) - 49. - self.newMidHeight) ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    layout.minimumLineSpacing = 0. ;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0) ;
    self.mainCollectionView.collectionViewLayout = layout ;
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
        
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:.2 animations:^{
            
            // hidden or show
            self.height_midBar.constant = newMidHeight ;

            self.segmentBooks.alpha = self.btBooksSmall_All.alpha = uiStatus_TopBar_turnSmall ? 1 : 0 ;
            
        } completion:^(BOOL finished) {
            
        }] ;
    
        // collection flow
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
        
        [self.segmentBooks setValue:@(self.bookCurrentIdx) forKey:@"currentIndex"] ;
        [self.segmentBooks scrollToItemAtIndexPath:indexPath atScrollPosition:(UICollectionViewScrollPositionCenteredHorizontally) animated:NO] ;
        [self.segmentBooks reloadData] ;
        
        [self.bookCollectionView reloadData] ;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.02 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.mainCollectionView reloadData] ;
        });
                
    }) ;
    
}

- (XTStretchSegment *)segmentBooks{
    if(!_segmentBooks){
        _segmentBooks = ({
            XTStretchSegment *object = [XTStretchSegment getNew] ;
            [object setupTitleColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) selectedColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) bigFontSize:17 normalFontSize:15 hasUserLine:YES cellSpace:20 sideMarginLeft:20 sideMarginRight:56] ;
            [object setupCollections] ;
            object.xtSSDelegate    = self;
            object.xtSSDataSource  = self;
            object.xt_theme_backgroundColor = k_md_bgColor ;
            
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

- (SchBarPositiveTransition *)transition {
    if (!_transition) {
        _transition = [[SchBarPositiveTransition alloc] initWithPositive:YES] ;
    }
    return _transition ;
}

- (HomeAddButton *)btAdd {
    if (!_btAdd) {
        HomeAddButton *bt = [[HomeAddButton alloc] init] ;
        _btAdd = bt ;        
    }
    return _btAdd ;
}

- (RACSubject *)subjectKeycommand {
    if (!_subjectKeycommand) {
        _subjectKeycommand = [RACSubject subject] ;
    }
    return _subjectKeycommand ;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.transition.isPositive = YES ;
    return self.transition ;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.transition.isPositive = NO ;
    return self.transition ;
}

#pragma mark - OcContainerCell callback  self.xt_viewcontroller
// up - YES, down - NO.
- (void)containerCellDraggingDirection:(BOOL)directionUp {
    if (directionUp != self.uiStatus_TopBar_turnSmall) {
        self.uiStatus_TopBar_turnSmall = directionUp ;
        //    if (!directionUp) {NSLog(@"下")}
        //    else {NSLog(@"上")} ;
    }
}

- (void)containerCellDraggingCurrentMovingDistance:(float)currentDistance {
    NSLog(@"currentDistance : %@", @(currentDistance)) ;
    
    if (currentDistance > 134.) {
        self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = 0 ;

        if (currentDistance > 190.) {
            self.segmentBooks.alpha = self.btBooksSmall_All.alpha = 1 ;
        }
        else {
            float alpha1 = ( (currentDistance - 134.) / (190. - 134.) ) + .4 ;
            self.segmentBooks.alpha = self.btBooksSmall_All.alpha = alpha1 ;
            self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = MAX((1 - alpha1 - .2), .1) ;             
        }
    }
    else {
        if (currentDistance < 0) {
            self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = 1 ;
            self.segmentBooks.alpha = self.btBooksSmall_All.alpha = 0 ;

            return ;
        }
        
        if (currentDistance < 51.) {
            self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = 1 ;
            self.segmentBooks.alpha = self.btBooksSmall_All.alpha = 0 ;
            return ;
        }
        
        // else
        float alpha1 = ( (134. - currentDistance) / 134. ) + .6 ;
        self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = alpha1 ;
        self.segmentBooks.alpha = self.btBooksSmall_All.alpha = MAX((1 - alpha1 - .2), .1) ;
    }
    
}

- (void)containerCellDidSelectedNote:(Note *)note {
    [MarkdownVC newWithNote:note bookID:self.currentBook.icRecordName fromCtrller:self] ;
}

#pragma mark - OcNoteCell call back  self.xt_viewcontroller
/**
  OcNoteCell call back
 */
- (void)noteCellDidSelectedBtMore:(Note *)aNote fromView:(UIView *)fromView {
    
    NSArray *titles = aNote.isTop ? @[@"取消置顶",@"移动"] : @[@"置顶",@"移动"] ;
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:titles fromWithView:fromView CallBackBlock:^(NSInteger btnIndex) {
        
        switch (btnIndex) {
                case 1: { // top
                    [self changeNoteTopState:aNote] ;
                }
                break;
                case 2: { // move
                    [self moveNote:aNote] ;
                }
                break;
                case 3: { // delegte
                    [self deleteNote:aNote] ;
                }
                break;
            default:
                break;
        }
    }] ;
}

#pragma mark - MarkdownVCDelegate <NSObject>

- (void)addNoteComplete:(Note *)aNote {
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
    [cell refresh] ;
}

- (void)editNoteComplete:(Note *)aNote {
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
    [cell refresh] ;
}

- (NSString *)currentBookID {
    return self.currentBook.icRecordName ;
}

- (int)currentBookType {
    return (int)(self.currentBook.vType) ;
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
    
    [self getAllBooks] ;
}

- (void)ocAllBookVCDidClose {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.bookCurrentIdx inSection:0] ;
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:indexPath] ;
    [cell refresh] ;
}

#define SIZECLASS_2_STR(sizeClass) [[self class] sizeClassInt2Str:sizeClass]
#pragma mark - Size Class

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection] ;
    
    [self.subjectTraitCollectionDidChange sendNext:@1] ;
}

- (void)willTransitionToTraitCollection:(UITraitCollection *)newCollection withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super willTransitionToTraitCollection:newCollection withTransitionCoordinator:coordinator];
    
//    NSLog(@"willTransitionToTraitCollection: current %@, new: %@", SIZECLASS_2_STR(self.traitCollection.horizontalSizeClass), SIZECLASS_2_STR(newCollection.horizontalSizeClass)) ;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
//    NSLog(@"viewWillTransitionToSize: size %@", NSStringFromCGSize(size)) ;
    [GlobalDisplaySt sharedInstance].containerSize = size ;
    [[GlobalDisplaySt sharedInstance] correctCurrentCondition:self] ;
    
    NSValue *val = [NSValue valueWithCGSize:size] ;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_SizeClass_Changed object:val] ;
}

+ (NSString *)sizeClassInt2Str:(UIUserInterfaceSizeClass)sizeClass {
    switch (sizeClass) {
        case UIUserInterfaceSizeClassCompact:
            return @"UIUserInterfaceSizeClassCompact";
        case UIUserInterfaceSizeClassRegular:
            return @"UIUserInterfaceSizeClassRegular";
        case UIUserInterfaceSizeClassUnspecified:
        default:
            return @"UIUserInterfaceSizeClassUnspecified";
    }
}

@end
