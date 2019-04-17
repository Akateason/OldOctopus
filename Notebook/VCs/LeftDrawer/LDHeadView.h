//
//  LDHeadView.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *const kNotification_AddBook = @"kNotification_AddBook" ;



@class NoteBooks ;
@protocol LDHeadViewDelegate <NSObject>
- (void)LDHeadDidSelectedOneBook:(NoteBooks *)abook ;
@end

@interface LDHeadView : UIView <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) id <LDHeadViewDelegate> ld_delegate ;
@property (weak, nonatomic) IBOutlet UILabel *lbHead;
@property (weak, nonatomic) IBOutlet UILabel *lbName;
@property (weak, nonatomic) IBOutlet UITableView *table;
- (void)setupUser ;
@end

NS_ASSUME_NONNULL_END
