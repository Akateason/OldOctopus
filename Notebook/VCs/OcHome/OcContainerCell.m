//
//  OcContainerCell.m
//  Notebook
//
//  Created by teason23 on 2019/8/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcContainerCell.h"
#import "OcNoteCell.h"
#import "OcHomeVC.h"
#import "SettingSave.h"
#import "HomeEmptyPHView.h"
#import "OcHomeEmptyVC.h"
#import "OcLineNoteCell.h"

@interface OcContainerCell ()
@property (nonatomic) BOOL isLine ;
@end

@implementation OcContainerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.noteList = @[] ;
    
    [OcNoteCell xt_registerNibFromCollection:self.contentCollection] ;
    [OcLineNoteCell xt_registerNibFromCollection:self.contentCollection] ;
    self.contentCollection.dataSource = (id<UICollectionViewDataSource>)self ;
    self.contentCollection.delegate = (id<UICollectionViewDelegate>)self ;
    self.contentCollection.xt_Delegate = (id<UICollectionViewXTReloader>)self ;
    
    [self.contentCollection xt_setup] ;
    self.contentCollection.mj_header = nil ;
    self.contentCollection.mj_footer = nil ;
    
    self.contentCollection.xt_theme_backgroundColor = k_md_backColor ;
    
    self.contentCollection.collectionViewLayout = [[GlobalDisplaySt sharedInstance] homeContentLayout] ;
    
    // 占位
    OcHomeEmptyVC *emptyVc = [OcHomeEmptyVC getCtrllerFromNIBWithBundle:[NSBundle bundleForClass:self.class]] ;
    self.contentCollection.customNoDataView = emptyVc.view ;
    
    @weakify(self)
    [[[[[RACObserve(self.contentCollection, contentOffset) map:^id _Nullable(NSValue *value) {
        CGPoint pt = value.CGPointValue ;
        return @(pt.y) ;
    }] filter:^BOOL(id  _Nullable value) {
        @strongify(self)
        return self.window != nil ;
    }]
       distinctUntilChanged]
      takeUntil:self.rac_willDeallocSignal]
     subscribeNext:^(NSNumber *offsetY) {
         @strongify(self)
         CGPoint translation = [self.contentCollection.panGestureRecognizer translationInView:self] ;
         BOOL directionIsVerical = (fabs(translation.y) > fabs(translation.x)) ;
         BOOL overDistance = offsetY.floatValue > 134. ;
        
         BOOL scrollUpDirection = translation.y < 0 ;
         
         if ( directionIsVerical ) {
             // ending state
             if (scrollUpDirection) {
                 if (overDistance) [(OcHomeVC *)self.xt_viewController containerCellDraggingDirection:YES] ;
             }
             else {
                 if (!overDistance) [(OcHomeVC *)self.xt_viewController containerCellDraggingDirection:NO] ;
             }
         }
    }] ;
    
    [[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SortWay_Changed object:nil]
        merge:
        [[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_SizeClass_Changed object:nil]
        ] takeUntil:self.rac_willDeallocSignal]
      deliverOnMainThread]
     subscribeNext:^(id  _Nullable x) {
                @strongify(self)
                
        SettingSave *ssave = [SettingSave fetch] ;
        self.isLine = ssave.homePageCellDisplayWay_isLine ;

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            [self.contentCollection setCollectionViewLayout:[[GlobalDisplaySt sharedInstance] homeContentLayout] animated:YES] ;
            self.contentCollection.mj_offsetY = 0 ;
            if (self.noteList.count > 0) {
                [self refresh] ;
            }
        }) ;
        
    }] ;

}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:book indexPath:indexPath] ;
    
    SettingSave *ssave = [SettingSave fetch] ;
    self.isLine = ssave.homePageCellDisplayWay_isLine ;
}

- (void)renderWithBook:(NoteBooks *)book complete:(void(^)(void))completion {
    
    if (book.vType == Notebook_Type_recent) {
        NSArray *list = [Note xt_findWhere:@"isDeleted == 0 order by modifyDateOnServer DESC limit 20"] ;
        [self dealTopNoteLists:list] ;
        completion() ;
        return ;
    }
    else if (book.vType == Notebook_Type_staging) {
        NSArray *list = [[Note xt_findWhere:@"noteBookId == '' and isDeleted == 0"] xt_orderby:@"modifyDateOnServer" descOrAsc:YES] ;
        [self dealTopNoteLists:list] ;
        completion() ;
        return ;
    }
    
    // note book normal
    @weakify(self)
    [Note noteListWithNoteBook:book completion:^(NSArray * _Nonnull list) {
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
    self.noteList = topList ;
}

#pragma mark - collection

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.noteList.count ;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NoteBooks *book = self.xt_model ;
    
    if (self.isLine) {
        OcLineNoteCell *cell = [OcLineNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        if (self.noteList.count == 0 || indexPath.row > self.noteList.count - 1) {
            return cell ;
        }
        Note *note = self.noteList[indexPath.row] ;
        [cell xt_configure:note indexPath:indexPath] ;
        cell.recentState = book.vType == Notebook_Type_recent ;
        return cell ;
    }
    else {
        OcNoteCell *cell = [OcNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
        if (self.noteList.count == 0 || indexPath.row > self.noteList.count - 1) {
            return cell ;
        }
        Note *note = self.noteList[indexPath.row] ;
        [cell xt_configure:note indexPath:indexPath] ;
        cell.recentState = book.vType == Notebook_Type_recent ;
        return cell ;
    }
    
    return nil ;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Note *note = self.noteList[indexPath.row] ;
    [(OcHomeVC *)self.xt_viewController containerCellDidSelectedNote:note] ;
}



- (void)refresh {
    WEAK_SELF
    [self renderWithBook:self.xt_model complete:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.contentCollection reloadData] ;
        }) ;
    }] ;
}

@end
