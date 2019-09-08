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

static const float kFlex_loft_sync_animate = 10.f ;



@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource,XTStretchSegmentDelegate, XTStretchSegmentDataSource>
@property (strong, nonatomic) SchBarPositiveTransition  *transition ;
@property (strong, nonatomic) MoveNoteToBookVC *moveVC ;
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
    
    [[OctWebEditor sharedInstance] setSideFlex] ;
    
    [self xt_prepareUI] ;
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
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
    
    [[RACObserve([XTCloudHandler sharedInstance], isSyncingOnICloud) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        @strongify(self)
        BOOL isSync = [x boolValue] ;
        if (isSync) {
            [self.animationSync play] ;
            self.animationSync.hidden = NO ;
        }
        else {
            [self.animationSync stop] ;
            self.animationSync.hidden = YES ;
        }
    }] ;

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
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuRowHeight = 75. ;
    configuration.menuWidth = 145. ;
    configuration.textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ;
    configuration.textFont = [UIFont systemFontOfSize:17] ;
    configuration.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_hudColor) ;
    configuration.borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    configuration.borderWidth = .25 ;
    configuration.separatorColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .2) ;
    configuration.separatorInset = UIEdgeInsetsMake(0, 20, 0, 20) ;
    configuration.shadowColor = [UIColor colorWithWhite:0 alpha:.15] ; //XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .15) ; // Default is black
    configuration.shadowOpacity = 1; // Default is 0 - choose anything between 0 to 1 to show actual shadow, e.g. 0.2
    configuration.shadowRadius = 30; // Default is 5
    configuration.shadowOffsetX = 0;
    configuration.shadowOffsetY = 15;
    configuration.menuIconMargin = 20 ;
    configuration.menuTextMargin = 17 ;
    configuration.selectedCellBackgroundColor = [UIColor colorWithWhite:0 alpha:0.05] ;

    @weakify(self)
    [FTPopOverMenu showForSender:self.btAdd withMenuArray:@[@"笔记",@"笔记本"] imageArray:@[@"home_add_note",@"home_add_book"] configuration:configuration doneBlock:^(NSInteger selectedIndex) {
        @strongify(self)
        if (selectedIndex == 0) {        // new note
            [self addNoteOnClick] ;
        }
        else if (selectedIndex == 1) {   // new book
            [self addBookOnClick] ;
        }
    } dismissBlock:^{
        
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
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
    
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
            self.btAllNote.alpha = self.lbMyNotes.alpha = self.lbAll.alpha = self.img_lbAllRight.alpha = self.bookCollectionView.alpha = uiStatus_TopBar_turnSmall ? 0. : 1. ;
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

- (LOTAnimationView *)animationSync {
    if (!_animationSync) {
        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"userhead_sync_animate" inBundle:[NSBundle bundleForClass:self.class]] ;
        animation.loopAnimation = YES ;
        animation.frame = [self.topBar convertRect:self.btUser.frame fromView:self.topBar] ;
        animation.frame = CGRectMake(animation.frame.origin.x - kFlex_loft_sync_animate, animation.frame.origin.y - kFlex_loft_sync_animate, animation.frame.size.width + 2 * kFlex_loft_sync_animate, animation.frame.size.height + 2 * kFlex_loft_sync_animate) ;
        _animationSync = animation ;
        [self.topBar insertSubview:_animationSync belowSubview:self.btUser] ;
    }
    return _animationSync ;
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
    [cell.contentCollection xt_loadNewInfoInBackGround:NO] ;
}

- (void)editNoteComplete:(Note *)aNote {
    OcContainerCell *cell = (OcContainerCell *)[self.mainCollectionView cellForItemAtIndexPath:self.mainCollectionView.xt_currentIndexPath] ;
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
}

- (NSString *)currentBookID {
    return self.currentBook.icRecordName ;
}

- (int)currentBookType {
    return self.currentBook.vType ;
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
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
}

#define SIZECLASS_2_STR(sizeClass) [[self class] sizeClassInt2Str:sizeClass]
#pragma mark - Size Class

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    
//    NSLog(@"traitCollectionDidChange: previous %@, new %@", SIZECLASS_2_STR(previousTraitCollection.horizontalSizeClass), SIZECLASS_2_STR(self.traitCollection.horizontalSizeClass)) ;
    
    if (@available(iOS 12.0, *)) {
        if (self.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) { // dark
            [[MDThemeConfiguration sharedInstance] setThemeDayOrNight:YES] ;
        }
        else { // light
            [[MDThemeConfiguration sharedInstance] setThemeDayOrNight:NO] ;
        }
    } else {
        // Fallback on earlier versnions
    }

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
//    [[NSNotificationCenter defaultCenter] postNotificationName:kNoteSlidingSizeChanging object:val] ;
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
