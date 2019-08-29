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

@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource,XTStretchSegmentDelegate, XTStretchSegmentDataSource>
@property (strong, nonatomic) SchBarPositiveTransition  *transition ;
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
    FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
    configuration.menuRowHeight = 75. ;
    configuration.menuWidth = 145. ;
    configuration.textColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) ;
    configuration.textFont = [UIFont systemFontOfSize:17] ;
    configuration.backgroundColor = XT_GET_MD_THEME_COLOR_KEY(k_md_hudColor) ;
    configuration.borderColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    configuration.borderWidth = .25 ;
//    configuration.textAlignment = ...
    configuration.ignoreImageOriginalColor = YES ;// set 'ignoreImageOriginalColor' to YES, images color will be same as textColor
//    configuration.allowRoundedArrow = ...// Default is 'NO', if sets to 'YES', the arrow will be drawn with round corner.
    configuration.separatorColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .1) ;
    configuration.separatorInset = UIEdgeInsetsMake(0, 65, 0, 0) ;
    configuration.shadowColor = [UIColor colorWithWhite:0 alpha:.15] ; //XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .15) ; // Default is black
    configuration.shadowOpacity = 1; // Default is 0 - choose anything between 0 to 1 to show actual shadow, e.g. 0.2
    configuration.shadowRadius = 30; // Default is 5
    configuration.shadowOffsetX = 0;
    configuration.shadowOffsetY = 15;
    configuration.menuIconMargin = 20 ;
    configuration.menuTextMargin = 17 ;

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
//    NSMutableArray *tmplist = [cell.noteList mutableCopy] ;
//    [tmplist replaceObjectAtIndex:cell.xt_indexPath.row withObject:aNote] ;
    [cell.contentCollection xt_loadNewInfoInBackGround:YES] ;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [cell.contentCollection scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:(UICollectionViewScrollPositionTop) animated:YES] ;
    });
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
            [object setupTitleColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .6) selectedColor:XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .8) bigFontSize:17 normalFontSize:14 hasUserLine:YES lineSpace:20 sideMarginLeft:20 sideMarginRight:56] ;
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
    if (directionUp != self.uiStatus_TopBar_turnSmall) self.uiStatus_TopBar_turnSmall = directionUp ;
    //    if (!directionUp) {NSLog(@"下")}
    //    else {NSLog(@"上")} ;
}

- (void)containerCellDidSelectedNote:(Note *)note {
    [MarkdownVC newWithNote:note bookID:self.currentBook.icRecordName fromCtrller:self] ;
}

#pragma mark - OcNoteCell call back  self.xt_viewcontroller
/**
  OcNoteCell call back
 */
- (void)noteCellDidSelectedBtMore:(Note *)aNote fromView:(UIView *)fromView {
    
    NSArray *titles = aNote.isTop ? @[@"移动",@"取消置顶"] : @[@"移动",@"置顶"] ;
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除" otherButtonTitles:titles fromWithView:fromView CallBackBlock:^(NSInteger btnIndex) {
        
        switch (btnIndex) {
                case 1: { // move
                    [self moveNote:aNote] ;
                }
                break;
                case 2: { // top
                    [self changeNoteTopState:aNote] ;
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

@end
