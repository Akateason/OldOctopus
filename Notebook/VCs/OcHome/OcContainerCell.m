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

static const int kNotesContainerPageSize = 10 ;

@implementation OcContainerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.noteList = @[] ;
    
    [OcNoteCell xt_registerNibFromCollection:self.contentCollection] ;
    self.contentCollection.dataSource = (id<UICollectionViewDataSource>)self ;
    self.contentCollection.delegate = (id<UICollectionViewDelegate>)self ;
    self.contentCollection.xt_Delegate = (id<UICollectionViewXTReloader>)self ;
    [self.contentCollection xt_setup] ;
    self.contentCollection.mj_footer = nil ;

    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init] ;
    float wid = ( APP_WIDTH - 10. * 3 ) / 2. ;
    float height = wid  / 345. * 432. ;
    layout.itemSize = CGSizeMake(wid, height) ;
    layout.minimumLineSpacing = 10 ;
    layout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10) ;
    self.contentCollection.collectionViewLayout = layout ;
    
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
//         NSLog(@"offset : %@",offsetY) ;
//         NSLog(@"self : %@",self) ;
         CGPoint translation = [self.contentCollection.panGestureRecognizer translationInView:self] ;
         CGPoint velocity = [self.contentCollection.panGestureRecognizer velocityInView:self] ;
//         BOOL velocityOverThis = (fabs(velocity.y) > 600) ;
         BOOL directionIsVerical = (fabs(translation.y) > fabs(translation.x)) ;
         BOOL overDistance = offsetY.floatValue > 134 ;
         BOOL scrollUpDirection = translation.y < 0 ;
         
         if ( directionIsVerical ) {
             NSLog(@"v : %@",@(velocity.y)) ;
             if (scrollUpDirection) {
                 if (overDistance) [(OcHomeVC *)self.xt_viewController containerCellDraggingDirection:YES] ;
             }
             else {
                 if (!overDistance) [(OcHomeVC *)self.xt_viewController containerCellDraggingDirection:NO] ;
             }
         }
    }] ;
}

- (void)xt_configure:(NoteBooks *)book indexPath:(NSIndexPath *)indexPath {
    [super xt_configure:book indexPath:indexPath] ;
        
}

- (void)renderWithBook:(NoteBooks *)book complete:(void(^)(void))completion {
//    if (self.noteList) {
//    }
    
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
    OcNoteCell *cell = [OcNoteCell xt_fetchFromCollection:collectionView indexPath:indexPath] ;
    cell.backgroundColor = [UIColor xt_seedGreen] ;
    Note *note = self.noteList[indexPath.row] ;
    [cell xt_configure:note indexPath:indexPath] ;
    return cell ;
}

#pragma mark - UICollectionViewXTReloader <NSObject>

- (void)collectionView:(UICollectionView *)collection loadNew:(void (^)(void))endRefresh {
    [self renderWithBook:self.xt_model complete:^{
        endRefresh() ;
    }] ;
}

@end
