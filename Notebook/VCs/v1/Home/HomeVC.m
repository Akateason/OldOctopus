//
//  HomeVC.m
//  Notebook
//
//  Created by teason23 on 2019/3/27.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HomeVC.h"
#import "LeftDrawerVC.h"
#import "NoteBooks.h"
#import "Note.h"
#import "NoteCell.h"
#import "MarkdownVC.h"
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
#import "SchBarPositiveTransition.h"
#import "HomeVC+Util.h"
#import <SafariServices/SafariServices.h>
#import "MDNavVC.h"
#import "OctWebEditor.h"
#import "NHSlidingController.h"
#import "UIViewController+SlidingController.h"
#import "GlobalDisplaySt.h"
#import "SettingSave.h"
#import "SearchEmptyVC.h"
#import "UserTestCodeVC.h"

#import "SWRevealTableViewCell.h"




@interface HomeVC () <UITableViewDelegate, UITableViewDataSource, UITableViewXTReloaderDelegate, MarkdownVCDelegate, SWRevealTableViewCellDataSource, SWRevealTableViewCellDelegate, UIViewControllerTransitioningDelegate>
@property (weak, nonatomic) IBOutlet UIView *topSafeAreaView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *topArea;
@property (weak, nonatomic) IBOutlet UILabel *nameOfNoteBook;

@property (weak, nonatomic) IBOutlet UIButton *btLeftDraw;

@property (weak, nonatomic) IBOutlet UIButton *btAdd;
@property (weak, nonatomic) IBOutlet UIButton *btMore;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top_topbar;


@property (strong, nonatomic) LOTAnimationView          *animationSync ;
@property (strong, nonatomic) SchBarPositiveTransition  *transition ;
@property (strong, nonatomic) HomeEmptyPHView           *phView ;
@property (strong, nonatomic) SearchEmptyVC             *sEmptyVC ;
@property (nonatomic)         BOOL                      isOnDeleting ;
@end

@implementation HomeVC

#pragma mark - public

+ (UIViewController *)getMe {
    HomeVC *topVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
    MDNavVC *navVC = [[MDNavVC alloc]initWithRootViewController:topVC] ;
    LeftDrawerVC *bottomVC = [LeftDrawerVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"LeftDrawerVC"];
    topVC.leftVC = bottomVC ;
    NHSlidingController *slidingController = [[NHSlidingController alloc] initWithTopViewController:navVC bottomViewController:bottomVC slideDistance:self.movingDistance] ;
    bottomVC.slidingController = slidingController ;
    topVC.slidingController = slidingController ;
    navVC.slidingController = slidingController ;
    return slidingController ;
}

#pragma mark - life

- (void)viewDidLoad {
    [super viewDidLoad] ;
    
    [self leftVC] ;
    self.listNotes = @[] ;
    
    self.fd_prefersNavigationBarHidden = YES ;
    
    @weakify(self)
    [self.leftVC currentBookChanged:^(NoteBooks *book) {
        @strongify(self)        
        
        [self.table xt_loadNewInfoInBackGround:YES] ;
        self.btAdd.hidden = book.vType == Notebook_Type_trash ;
        self.btMore.hidden = book.vType == Notebook_Type_trash || book.vType == Notebook_Type_recent || book.vType == Notebook_Type_staging ;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_book_Changed object:book] ;
    }] ;
    
    [self.leftVC bookCellTapped:^{
        @strongify(self)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (!IS_IPAD) {
                [self.slidingController setDrawerOpened:NO animated:YES] ;
            }
        });
    }] ;
    
     [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationSyncCompleteAllPageRefresh object:nil]
        takeUntil:self.rac_willDeallocSignal]
       deliverOnMainThread]
      throttle:1.]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         NSLog(@"go sync list") ;
         if (self.isOnDeleting) return ;
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
    
    [[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNotificationImportFileIn object:nil]
       takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(NSNotification * _Nullable x) {
         @strongify(self)
         NSString *path = x.object ;
         NSString *md = [[NSString alloc] initWithContentsOfFile:path encoding:(NSUTF8StringEncoding) error:nil] ;
         NSString *title = [Note getTitleWithContent:md] ;
         Note *aNote = [[Note alloc] initWithBookID:self.leftVC.currentBook.icRecordName content:md title:title] ;
         [Note createNewNote:aNote] ;
         
         @weakify(self)
         [self renderTable:^{
             @strongify(self)
             [self newNoteCombineFunc:aNote] ;
         }] ;
     }] ;
    
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
        [UserTestCodeVC getMeFrom:self.slidingController] ;
    }] ;
}

- (void)renderTable:(void(^)(void))completion {
    if (self.leftVC.currentBook.vType == Notebook_Type_recent) {
        self.nameOfNoteBook.text = @"最近使用" ;
        NSArray *list = [Note xt_findWhere:@"isDeleted == 0 order by modifyDateOnServer DESC limit 20"] ;
        [self dealTopNoteLists:list] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        self.nameOfNoteBook.text = @"垃圾桶" ;
        NSArray *list = [Note xt_findWhere:@"isDeleted == 1 AND icRecordName NOT LIKE 'mac-note%%'"] ;
        list = [self sortThisList:list] ;
        [self dealTopNoteLists:list] ;
        completion() ;
        return ;
    }
    else if (self.leftVC.currentBook.vType == Notebook_Type_staging) {
        self.nameOfNoteBook.text = @"暂存区" ;
        NSArray *list = [[Note xt_findWhere:@"noteBookId == '' and isDeleted == 0"] xt_orderby:@"modifyDateOnServer" descOrAsc:YES] ;
        [self dealTopNoteLists:list] ;
        completion() ;
        return ;
    }
    
    // note book normal
    if (self.leftVC.currentBook.name != nil) {
        self.nameOfNoteBook.text = XT_STR_FORMAT(@"%@ %@",self.leftVC.currentBook.displayEmoji,self.leftVC.currentBook.name) ;
    }
    
    @weakify(self)
    [Note noteListWithNoteBook:self.leftVC.currentBook completion:^(NSArray * _Nonnull list) {
        @strongify(self)
        [self dealTopNoteLists:list] ;
        completion() ;
    }] ;
}

- (NSArray *)sortThisList:(NSArray *)list {
    SettingSave *sSave = [SettingSave fetch] ;
    NSString *orderBy = sSave.sort_isNoteUpdateTime ? @"createDateOnServer" : @"modifyDateOnServer" ;
    list = [list xt_orderby:orderBy descOrAsc:sSave.sort_isNewestFirst] ;
    return list ;
}

- (void)dealTopNoteLists:(NSArray *)list {
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    [list enumerateObjectsUsingBlock:^(Note *aNote, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![aNote.icRecordName containsString:@"mac-"]) {
            [tmplist addObject:aNote] ;
        }
    }] ;
    list = tmplist ; // 屏蔽桌面端的文章
    
    NSMutableArray *topList = [@[] mutableCopy] ;
    NSMutableArray *normalList = [@[] mutableCopy] ;
    [list enumerateObjectsUsingBlock:^(Note *aNote, NSUInteger idx, BOOL * _Nonnull stop) {
        if (aNote.isTop) {
            [topList addObject:aNote] ;
        }
        else {
            [normalList addObject:aNote] ;
        }
    }] ;
    
    topList = [[self sortThisList:topList] mutableCopy] ;
    [topList addObjectsFromArray:normalList] ;
    self.listNotes = topList ;
}

- (void)openDrawer {
    [self.leftVC render] ;
    [self.slidingController toggleDrawer] ;
}

- (void)newNoteCombineFunc:(Note *)aNote {
//    if ([GlobalDisplaySt sharedInstance].displayMode == GDST_Home_2_Column_Verical_default) {
//        [MarkdownVC newWithNote:aNote bookID:self.leftVC.currentBook.icRecordName fromCtrller:self] ;
//    }
//    else {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kNote_ClickNote_In_Pad object:aNote] ;
//    }
}

- (void)prepareUI {
    [self.btLeftDraw xt_enlargeButtonsTouchArea] ;
    
    self.top_topbar.constant = APP_STATUSBAR_HEIGHT ;
    
    [NoteCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [HomeSearchCell xt_registerNibFromTable:self.table bundleOrNil:[NSBundle bundleForClass:self.class]] ;
    [self.table xt_setup] ;
    self.table.dataSource = self ;
    self.table.delegate = self ;
    self.table.xt_Delegate = self ;
    self.table.mj_footer = nil ;
    
    self.table.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : XT_MAKE_theme_color(k_md_bgColor,1) ;
    
    self.table.contentInset = UIEdgeInsetsMake(10, 0, 0, 0) ;
    self.table.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag ;
    
    self.topSafeAreaView.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : k_md_bgColor ;
    self.topArea.xt_theme_backgroundColor = IS_IPAD ? XT_MAKE_theme_color(k_md_midDrawerPadColor, 1) : k_md_bgColor ;
    
    self.nameOfNoteBook.text = @"";
    self.nameOfNoteBook.xt_theme_textColor = XT_MAKE_theme_color(k_md_homeTitleTextColor, .8) ;
    

    self.btAdd.touchExtendInset = UIEdgeInsetsMake(-15, -15, -15, -15) ;
    self.btAdd.xt_theme_imageColor = k_md_themeColor ;
    @weakify(self)
    [self.btAdd xt_addEventHandler:^(id sender) {
        @strongify(self)
        
        @weakify(self)
        [self.btAdd oct_buttonClickAnimationComplete:^{
            @strongify(self)
            [self addBtOnClick:sender] ;
        }] ;
    } forControlEvents:(UIControlEventTouchUpInside)] ;
    
    self.btMore.touchExtendInset = UIEdgeInsetsMake(-15, -15, -15, -15) ;
    self.btMore.xt_theme_imageColor = k_md_iconColor ;
    [self.btMore xt_addEventHandler:^(id sender) {
        @strongify(self)
        
        @weakify(self)
        [self.btMore oct_buttonClickAnimationComplete:^{
            @strongify(self)
            [self moreBtOnClick:sender] ;
        }] ;
    } forControlEvents:UIControlEventTouchUpInside] ;
    
    self.btLeftDraw.userInteractionEnabled = YES ;
    [self.btLeftDraw xt_whenTapped:^{
        @strongify(self)
        
        @weakify(self)
        [self.btLeftDraw oct_buttonClickAnimationComplete:^{
            @strongify(self)
            [self openDrawer] ;
        }] ;
    }] ;
    
    self.nameOfNoteBook.userInteractionEnabled = YES ;
    [self.nameOfNoteBook xt_whenTapped:^{
        @strongify(self)
        
        @weakify(self)
        [self.btLeftDraw oct_buttonClickAnimationComplete:^{
            @strongify(self)
            [self openDrawer] ;
        }] ;
    }] ;
    
    [self.leftVC render] ;
    
    [[RACObserve([XTCloudHandler sharedInstance], isSyncingOnICloud) deliverOnMainThread] subscribeNext:^(id  _Nullable x) {
        bool isSync = [x boolValue] ;
        if (isSync) {
            [self.animationSync play] ;
            self.animationSync.hidden = NO ;
        }
        else {
            [self.animationSync stop] ;
            self.animationSync.hidden = YES ;
        }
    }] ;
        
    if (IS_IPAD) {
        UIView *sideLine = [UIView new] ;
        sideLine.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
        [self.view addSubview:sideLine] ;
        [sideLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@.5) ;
            make.top.right.bottom.equalTo(self.view) ;
        }] ;
        
        UIView *sideLine2 = [UIView new] ;
        sideLine2.xt_theme_backgroundColor = XT_MAKE_theme_color(k_md_iconColor, .2) ;
        [self.view addSubview:sideLine2] ;
        [sideLine2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(@.5) ;
            make.top.left.bottom.equalTo(self.view) ;
        }] ;
    }
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
    self.isOnDeleting = NO ;
    
    [self renderTable:^{
        endRefresh() ;
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
    Note *aNote = self.listNotes[indexPath.row] ;
    [cell xt_configure:aNote indexPath:indexPath] ;
    
    cell.rightButtons = [self setupPanList:cell] ;
    cell.rightSwipeSettings.transition = MGSwipeStateSwippingLeftToRight;
    cell.allowsMultipleSwipe = YES ;
    cell.delegate = (id<MGSwipeTableCellDelegate>)self ;
    
    [cell trashMode:(self.leftVC.currentBook.vType == Notebook_Type_trash)] ;
    if (self.leftVC.currentBook.vType != Notebook_Type_trash && IS_IPAD) {
        [cell setUserSelected:
         [aNote.icRecordName isEqualToString:XT_USERDEFAULT_GET_VAL(kUDCached_lastNote_RecID)]
         ] ;
    }
    return cell ;
}

// 左滑的时候隐藏其他左滑的cell
- (void)swipeTableCell:(nonnull MGSwipeTableCell *)cell didChangeSwipeState:(MGSwipeState)state gestureIsActive:(BOOL)gestureIsActive {
    if (gestureIsActive && state == MGSwipeStateSwipingRightToLeft) {
        NSIndexPath *indexPath = cell.xt_indexPath ;
        NSMutableArray *tmplist = [self.table.indexPathsForVisibleRows mutableCopy] ;
        for (NSIndexPath *ip in self.table.indexPathsForVisibleRows) {
            if (ip.section == indexPath.section && ip.row == indexPath.row) {
                [tmplist removeObject:ip] ;
            }
        }
        
        [self.table reloadRowsAtIndexPaths:tmplist withRowAnimation:(UITableViewRowAnimationNone)] ;
    }
    
    self.isOnDeleting = gestureIsActive ;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [HomeSearchCell xt_cellHeight] ;
    }
    return [NoteCell xt_cellHeight] ;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        [SearchVC showSearchVCFrom:self] ;
        return ;
    }
    
    NoteCell *cell = [tableView cellForRowAtIndexPath:indexPath] ;
    if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        [cell showSwipe:(MGSwipeDirectionRightToLeft) animated:YES] ;
        return ;
    }
    
    NSInteger row = indexPath.row ;
    Note *aNote = self.listNotes[row] ;
    
    if (IS_IPAD) {
        XT_USERDEFAULT_SET_VAL(aNote.icRecordName, kUDCached_lastNote_RecID) ;
        [tableView reloadData] ;
        [self newNoteCombineFunc:aNote] ;
    }
    else {
        [UIView animateWithDuration:.2 animations:^{
            cell.area.backgroundColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_textColor, .03) ;
        } completion:^(BOOL finished) {
            cell.area.backgroundColor = XT_GET_MD_THEME_COLOR_KEY_A(k_md_bgColor, 1) ;
            [self newNoteCombineFunc:aNote] ;
        }] ;
    }
}

- (UIView *)makePlaceHolderView {
    if (self.leftVC.currentBook.vType == Notebook_Type_trash) {
        self.sEmptyVC.lbWord.text = @"" ;
        return self.sEmptyVC.view ;
    }
    else {
//        if (IS_IPAD && [GlobalDisplaySt sharedInstance].displayMode == GDST_Home_3_Column_Horizon ) {
//            self.sEmptyVC.lbWord.text = @"点击开始记录你的新故事..." ;
//            return self.sEmptyVC.view ;
//        }
        self.phView.book = self.leftVC.currentBook ;
        return self.phView ;
    }
}

- (BOOL)enableScrollWhenPlaceHolderViewShowing {
    return YES ;
}

#pragma mark - MarkdownVCDelegate <NSObject>

- (void)addNoteComplete:(Note *)aNote {
    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
    [tmplist insertObject:aNote atIndex:0] ;
    self.listNotes = tmplist ;
    [self.table reloadData] ;
}

//- (void)editNoteComplete:(Note *)aNote {
//    NSMutableArray *tmplist = [self.listNotes mutableCopy] ;
//    [self.listNotes enumerateObjectsUsingBlock:^(Note  *obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if ([obj.icRecordName isEqualToString:aNote.icRecordName]) {
//            [tmplist removeObjectAtIndex:idx] ;
//            [tmplist insertObject:aNote atIndex:0] ;
//            *stop = YES;
//            return;
//        }
//    }] ;
//    self.listNotes = tmplist ;
//    [self.table reloadData] ;
//}

- (NSString *)currentBookID {
    return self.leftVC.currentBook.icRecordName ;
}

- (int)currentBookType {
    return self.leftVC.currentBook.vType ;
}

#pragma mark - prop

- (HomeEmptyPHView *)phView {
    if (!_phView) {
        _phView = [HomeEmptyPHView xt_newFromNibByBundle:[NSBundle bundleForClass:self.class]] ;
        WEAK_SELF
        [_phView.area xt_whenTapped:^{
            Note *aNote = [[Note alloc] initWithBookID:self.leftVC.currentBook.icRecordName content:@"" title:@""] ;            
            [weakSelf newNoteCombineFunc:aNote] ;
        }] ;
    }
    return _phView ;
}

- (SearchEmptyVC *)sEmptyVC {
    if (!_sEmptyVC) {
        SearchEmptyVC *vc = [SearchEmptyVC getCtrllerFromNIB] ;
        [vc viewDidLoad] ;
        _sEmptyVC = vc ;
        [_sEmptyVC.view xt_whenTapped:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:kNote_new_Note_In_Pad object:nil] ;
        }] ;
    }
    return _sEmptyVC ;
}

+ (CGFloat)movingDistance {
    if (IS_IPAD) {
        return 230. ; // 200.
    }
    return  62. / 75. * APP_WIDTH ;
}

- (LOTAnimationView *)animationSync {
    if (!_animationSync) {
        LOTAnimationView *animation = [LOTAnimationView animationNamed:@"userhead_sync_animate" inBundle:[NSBundle bundleForClass:self.class]] ;
        animation.loopAnimation = YES ;
        float animateFlex = 14 ;
        animation.frame = [self.topArea convertRect:self.btLeftDraw.frame fromView:self.topArea] ;
        animation.frame = CGRectMake(animation.frame.origin.x - animateFlex, animation.frame.origin.y - animateFlex, animation.frame.size.width + 2 * animateFlex, animation.frame.size.height + 2 * animateFlex) ;
        _animationSync = animation ;
        [self.topArea insertSubview:_animationSync belowSubview:self.btLeftDraw] ;
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
