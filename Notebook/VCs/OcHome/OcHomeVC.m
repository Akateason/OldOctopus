//
//  OcHomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC.h"
#import "OcBookCell.h"
#import "OcContainerCell.h"
#import "MDNavVC.h"

#import <XTlib/XTStretchSegment.h>

// lastBook
// @key     kUDCached_lastBook_RecID
// @value   recID,  trash, recent , staging 这三种的话就保存vType.toStr
static NSString *const kUDCached_lastBook_RecID = @"kUDCached_lastBook_RecID" ;

@interface OcHomeVC () <UICollectionViewDelegate,UICollectionViewDataSource,XTStretchSegmentDelegate, XTStretchSegmentDataSource>

/**
 topbar的变化State Y - 短， N - 长， default - 长;
 */
@property (nonatomic)           BOOL                uiStatus_TopBar_turnSmall ;
// 短topbar book segment
@property (strong, nonatomic)   XTStretchSegment    *segmentBooks ;
@property (copy, nonatomic)     NSArray             *bookList ;

@property (strong, nonatomic)   NoteBooks           *currentBook ;

@end

@implementation OcHomeVC

+ (UIViewController *)getMe {
    OcHomeVC *topVC = [OcHomeVC getCtrllerFromStory:@"Home" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"OcHomeVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:topVC] ;
    return navVC ;
}

#pragma mark - life

- (void)prepareUI {
    self.fd_prefersNavigationBarHidden = YES ;
    
    [OcBookCell      xt_registerNibFromCollection:self.bookCollectionView] ;
    [OcContainerCell xt_registerNibFromCollection:self.mainCollectionView] ;
    
    self.bookCollectionView.delegate    = self ;
    self.bookCollectionView.dataSource  = self ;
    self.mainCollectionView.delegate    = self ;
    self.mainCollectionView.dataSource  = self ;
    self.mainCollectionView.pagingEnabled = YES ;
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    layout.itemSize = CGSizeMake(APP_WIDTH, APP_HEIGHT - APP_SAFEAREA_STATUSBAR_FLEX - 49. - 134.) ;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal ;
    layout.minimumLineSpacing = 0 ;
    self.mainCollectionView.collectionViewLayout = layout ;
    
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    self.bookList = @[] ;
    
    [self getAllBooks] ;
    
    [self setupNotifications] ;
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
    
    
}

#pragma mark - Funcs

- (void)refreshAll {
    [self.mainCollectionView reloadData] ;
    
    if (self.uiStatus_TopBar_turnSmall) {
        [self.segmentBooks reloadData] ;
    }
    else {
        [self.bookCollectionView reloadData] ;
    }
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






#pragma mark - props

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
        
        
    }] ;
}

- (XTStretchSegment *)segmentBooks{
    if(!_segmentBooks){
        _segmentBooks = ({
            XTStretchSegment *object = [XTStretchSegment getNew] ;
            [object setupTitleColor:nil selectedColor:nil bigFontSize:20 normalFontSize:15 hasUserLine:YES lineSpace:20 sideMargin:20] ;
            [object setupCollections] ;
            object.xtSSDelegate    = self;
            object.xtSSDataSource  = self;
            
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

#pragma mark - collection

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
    if (collectionView == self.bookCollectionView) {
        OcBookCell *cell = [OcBookCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        NoteBooks *book = self.bookList[indexPath.row] ;
        [cell xt_configure:book indexPath:indexPath] ;
        return cell ;
    }
    else if (collectionView == self.mainCollectionView) {
        OcContainerCell *cell = [OcContainerCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        return cell ;
    }
    return nil ;
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
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"btBase"]] ;
    imageView.frame        = CGRectMake(0, 0, 30, 70) ;
    return imageView ;
}

- (void)stretchSegment:(XTStretchSegment *)segment didSelectedIdx:(NSInteger)idx {
    NSLog(@"did select : %@", @(idx)) ;
}

@end
