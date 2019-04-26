//
//  HomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"
#import <FDFullscreenPopGesture/UINavigationController+FDFullscreenPopGesture.h>
#import <UIViewController+CWLateralSlide.h>
#import "LeftDrawerVC.h"
#import "NoteBooks.h"
#import "Note.h"
#import "NoteCell.h"
#import "MarkdownVC.h"
#import <CYLTableViewPlaceHolder/CYLTableViewPlaceHolder.h>
#import "HomeEmptyPHView.h"
#import "AppDelegate.h"
#import "LDHeadView.h"
#import "NewBookVC.h"
#import "MoveNoteToBookVC.h"
#import "LaunchingEvents.h"
#import "SearchVC.h"
#import "HomeVC+PanGestureHandler.h"
#import "HomeSearchCell.h"
#import "NewBookVC.h"
#import <Lottie/Lottie.h>
#import "GuidingVC.h"
#import "SchBarPositiveTransition.h"
#import "TrashEmptyView.h"


@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, CYLTableViewPlaceHolderDelegate, MarkdownVCDelegate, SWRevealTableViewCellDataSource, UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *topSafeAreaView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;
@property (weak, nonatomic) IBOutlet UILabel *lbUser;
@property (weak, nonatomic) IBOutlet UIButton *btAdd;
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet UILabel *bookEmoji;

@property (strong, nonatomic) LeftDrawerVC *leftVC ;
@property (copy, nonatomic) NSArray *listNotes ;
@property (strong, nonatomic) HomeEmptyPHView *phView ;
@property (strong, nonatomic) NewBookVC *nBookVC ;
@property (strong, nonatomic) LOTAnimationView *animationSync ;
@property (strong, nonatomic) SchBarPositiveTransition *transition ;
@end

@implementation HomeVC

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [GuidingVC showFromCtrllerIfNeeded:self] ;
    
    [self leftVC] ;
    self.listNotes = @[] ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    [self.leftVC currentBookChanged:^(NoteBooks *book) {
        @strongify(self)        
        [self.table xt_loadNewInfoInBackGround:YES] ;
        self.btAdd.hidden = book.vType == Notebook_Type_trash ;
        self.btMore.hidden = book.vType == Notebook_Type_trash || book.vType == Notebook_Type_recent || book.vType == Notebook_Type_staging ;
    }] ;
    
    [self.leftVC bookCellTapped:^{
        @strongify(self)
        [self.leftVC dismissViewControllerAnimated:YES completion:nil] ;
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter]
    rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:.5] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        [self.leftVC render] ;
        [self.table xt_loadNewInfoInBackGround:YES] ;
    }] ;
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationForThemeColorDidChanged object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         [self.table reloadData] ;
     }] ;
    
    [[[RACSignal interval:10 onScheduler:[RACScheduler mainThreadScheduler]]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSDate * _Nullable x) {
         @strongify(self)
         if (self.view.window) {
             LaunchingEvents *events = ((AppDelegate *)[UIApplication sharedApplication].delegate).launchingEvents ;
             [events icloudSync:^{}] ;
         }
     }]  ;
    
    [self.leftVC render] ;
    [self.table xt_loadNewInfoInBackGround:YES] ;
    
    
}

- (void)renderTable:(void(^)(void))completion {
    if (self.leftVC.currentBook.vType == Notebook_Type_recent) {
        self.nameOfNoteBook.text = @"最近使用" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [Note xt_findWhere:@"isDeleted == 0 order by modifyDateOnServer DESC limit 20"] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        self.nameOfNoteBook.text = @"垃圾桶" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [Note xt_findWhere:@"isDeleted == 1"] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_staging) {
        self.nameOfNoteBook.text = @"暂存区" ;
        self.bookEmoji.text = @"" ;
        self.listNotes = [[Note xt_findWhere:@"noteBookId == '' and isDeleted == 0"] xt_orderby:@"modifyDateOnServer" descOrAsc:YES] ;
        completion() ;
        return ;
    }
    
    // note book normal
    self.nameOfNoteBook.text = self.leftVC.currentBook.name ;
    self.bookEmoji.text = self.leftVC.currentBook.displayEmoji ;
    
    @weakify(self)
    [Note noteListWithNoteBook:self.leftVC.currentBook completion:^(NSArray * _Nonnull list) {
        @strongify(self)
        self.listNotes = list ;
        completion() ;
    }] ;
}

- (void)openDrawer {
    if (![XTIcloudUser hasLogin]) {
        [XTIcloudUser alertUserToLoginICloud] ;
        return ;
    }
    
    [self.leftVC render] ;
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:self.movingDistance maskAlpha:0.1 scaleY:1 direction:CWDrawerTransitionFromLeft backImage:nil] ;
    [self cw_showDrawerViewController:self.leftVC animationType:0 configuration:conf] ;
}

- (void)prepareUI {
    self.lbUser.xt_theme_backgroundColor = k_md_themeColor ;
    self.lbUser.textColor = [UIColor whiteColor] ;
    
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [HomeSearchCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.mj_footer = nil ;
    
    self.table.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_bgColor,1) ;
    
    self.table.contentInset = UIEdgeInsetsMake(10, 0, 0, 0) ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    
    self.topSafeAreaView.xt_theme_backgroundColor = k_md_bgColor ;
    self.topArea.xt_theme_backgroundColor = k_md_bgColor ;
    
    self.bookEmoji.text = @"" ;
    self.nameOfNoteBook.text = @"";
    self.nameOfNoteBook.xt_theme_textColor = XT_MAKE_theme_color(k_md_homeTitleTextColor, .8) ;
    
    self.btAdd.xt_theme_imageColor = k_md_iconColor ;
    @weakify(self)
    [self.btAdd bk_addEventHandler:^(id sender) {
        @strongify(self)
        if (![XTIcloudUser hasLogin]) {
            [XTIcloudUser alertUserToLoginICloud] ;
            return ;
        }
        
        @weakify(self)
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"🖋 新建笔记",@"📒 新建笔记本"] callBackBlock:^(NSInteger btnIndex) {
            @strongify(self)
            if (btnIndex == 1) {
                [MarkdownVC newWithNote:nil bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
            }
            else if (btnIndex == 2) {
                self.nBookVC =
                [NewBookVC showMeFromCtrller:self changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                    // create new book
                    NoteBooks *aBook = [[NoteBooks alloc] initWithName:bookName emoji:emoji] ;
                    [NoteBooks createNewBook:aBook] ;
                    self.nBookVC = nil ;
                    
                    [self.leftVC render] ;
                    [self.leftVC refreshHomeWithBook:aBook] ;
                } cancel:^{
                    self.nBookVC = nil ;
                }] ;
            }
        }] ;
        
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    [self.btMore bk_addEventHandler:^(id sender) {
        
        if (![XTIcloudUser hasLogin]) {
            [XTIcloudUser alertUserToLoginICloud] ;
            return ;
        }
        @weakify(self)
        [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleActionSheet) title:nil message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"删除笔记本" otherButtonTitles:@[@"重命名笔记本"] callBackBlock:^(NSInteger btnIndex) {
            @strongify(self)
            if (btnIndex == 1) { //  rename book
                __block NoteBooks *aBook = self.leftVC.currentBook ;
                @weakify(self)
                self.nBookVC =
                [NewBookVC showMeFromCtrller:self editBook:aBook changed:^(NSString * _Nonnull emoji, NSString * _Nonnull bookName) {
                    @strongify(self)
                    aBook.name = bookName ;
                    aBook.emoji = [@{@"native":emoji} yy_modelToJSONString] ;
                    [NoteBooks updateMyBook:aBook] ;
                    self.nBookVC = nil ;
                    [self.leftVC render] ;
                    [self.leftVC setCurrentBook:aBook] ;
                } cancel:^{
                    @strongify(self)
                    self.nBookVC = nil ;
                }] ;
            }
            else if (btnIndex == 2) { // delete book
                @weakify(self)
                [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:(UIAlertControllerStyleAlert) title:@"删除笔记本" message:@"删除笔记本会将此笔记本内的文章都移入回收站" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确认" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex1) {
                    @strongify(self)
                    if (btnIndex1 == 1) {
                        @weakify(self)
                        [NoteBooks deleteBook:self.leftVC.currentBook done:^{
                            @strongify(self)
                            self.leftVC.currentBook = nil ;
                            [self.leftVC render] ;
                        }] ;
                    }
                }] ;

            }
        }] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    self.lbUser.userInteractionEnabled = YES ;
    [self.lbUser bk_whenTapped:^{
        @strongify(self)
        [self openDrawer] ;
    }] ;
    
    [self.leftVC render] ;
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @strongify(self)
        if (direction == CWDrawerTransitionFromLeft) [self openDrawer] ;
    }] ;
    
    [[RACObserve([XTCloudHandler sharedInstance], isSyncingOnICloud) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        bool isSync = [x boolValue] ;
        if (isSync) {
            [self.animationSync play] ;
        }
        else {
            [self.animationSync stop] ;
        }
        self.animationSync.hidden = !isSync ;
    }] ;
    
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
        @strongify(self)
        self.lbUser.text = [user.givenName substringToIndex:1] ;
    }] ;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated] ;
    [self.navigationController setNavigationBarHidden:YES animated:NO] ;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated] ;
}

#pragma mark - table

- (void)tableView:(UITableView *)table loadNew:(void (^)(void))endRefresh {
    [self renderTable:^{
        endRefresh() ;
        
//        self.table.mj_offsetY = [HomeSearchCell xt_cellHeight] ;
    }] ;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 ;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return self.listNotes.count ? 1 : 0 ;
    return self.listNotes.count ;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HomeSearchCell *cell = [HomeSearchCell xt_fetchFromTable:tableView] ;
        return cell ;
    }
    NoteCell *cell = [NoteCell xt_fetchFromTable:tableView] ;
    [cell xt_configure:self.listNotes[indexPath.row] indexPath:indexPath] ;
    cell.revealPosition = SWCellRevealPositionRightExtended ;
    cell.draggableBorderWidth = 200 ;
    cell.dataSource = self ;
    [cell trashMode:(self.leftVC.currentBook.vType == Notebook_Type_trash)] ;
    
    return cell ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [HomeSearchCell xt_cellHeight] ;
    }
    return [NoteCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [SearchVC showSearchVCFrom:self inTrash:(self.leftVC.currentBook.vType == Notebook_Type_trash)] ;
        return ;
    }
    
    NSInteger row = indexPath.row ;
    Note *aNote = self.listNotes[row] ;
    [MarkdownVC newWithNote:aNote bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
}

- (UIView *)makePlaceHolderView {
    if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        return [TrashEmptyView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
    }
    else {
        self.phView.book = self.leftVC.currentBook ;
        return self.phView ;
    }
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES ;
}

- (NSArray *)rightButtonItemsInRevealTableViewCell:(SWRevealTableViewCell *)cell1 {
    return [self setupPanList] ;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(NoteCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) return ;
    
    cell.lbTitle.alpha = 0. ;
    [UIView animateWithDuration:0.2
                     animations:^{
                         cell.lbTitle.alpha = 1 ;
                     }
                     completion:^(BOOL finished) {

                     }] ;
    
    cell.lbTitle.layer.transform = CATransform3DMakeTranslation(10, 0, 0) ;
    [UIView animateWithDuration:.25
                     animations:^{
                         cell.lbTitle.layer.transform = CATransform3DIdentity ;
                     }
                     completion:nil] ;
    
    cell.layer.transform = CATransform3DMakeScale(0.76, 0.76, 1) ;
    [UIView animateWithDuration:.25
                     animations:^{
                         cell.layer.transform = CATransform3DIdentity ;
                     }] ;
    
    cell.lbDate.alpha = 0. ;
    cell.lbContent.alpha = 0. ;
    [UIView animateWithDuration:1.
                     animations:^{
                         cell.lbDate.alpha = 1. ;
                         cell.lbContent.alpha = 1. ;
                     }] ;
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"%f",scrollView.mj_offsetY) ;
//
////    float searchHeight = [HomeSearchCell xt_cellHeight] ;
////    if (scrollView.mj_offsetY > - searchHeight) {
////
////    }
////    else {
////
////    }
//}


#pragma mark - MarkdownVCDelegate <NSObject>

- (void)addNoteComplete:(Note *)aNote {
    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
    [tmplist insertObject:aNote atIndex:0] ;
    self.listNotes = tmplist ;
    [self.table reloadData] ;
}

- (void)editNoteComplete:(Note *)aNote {
    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
    [self.listNotes enumerateObjectsUsingBlock:^(Note  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.icRecordName isEqualToString:aNote.icRecordName]) {
            [tmplist removeObjectAtIndex:idx] ;
            [tmplist insertObject:aNote atIndex:0] ;
            *stop = YES;
            return;
        }
    }] ;
    self.listNotes = tmplist ;
    [self.table reloadData] ;
}

#pragma mark - prop

- (LeftDrawerVC *)leftVC{
    if(!_leftVC){
        _leftVC = ({
            LeftDrawerVC * object = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"] ;
            object.distance = self.movingDistance ;
            object;
       });
    }
    return _leftVC;
}

- (HomeEmptyPHView *)phView {
    if (!_phView) {
        _phView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        WEAK_SELF
        [_phView.area bk_whenTapped:^{
            [MarkdownVC newWithNote:nil bookID:weakSelf.leftVC.currentBook.icRecordName fromCtrller:weakSelf] ;
        }] ;
    }
    return _phView ;
}

- (CGFloat)movingDistance {
    return  62. / 75. * APP_WIDTH ;
}

- (LOTAnimationView *)animationSync {
    if (!_animationSync) {
        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"userhead_sync_animate" inBundle:[NSBundle bundleForClass:self.class]] ;
        animation.loopAnimation = YES ;
        float animateFlex = 8 ;
        animation.frame = CGRectMake(self.lbUser.frame.origin.x - animateFlex, APP_NAVIGATIONBAR_HEIGHT + self.lbUser.frame.origin.y - animateFlex, self.lbUser.frame.size.width + 2 * animateFlex, self.lbUser.frame.size.height + 2 * animateFlex) ;
        _animationSync = animation ;
        [self.view addSubview:_animationSync] ;
    }
    return _animationSync ;
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







@end
