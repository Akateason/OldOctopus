//
//  LeftDrawerVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class NoteBooks ;

NS_ASSUME_NONNULL_BEGIN

@interface LeftDrawerVC : BasicVC

@property (nonatomic) CGFloat distance ;
@property (strong, nonatomic) NoteBooks *currentBook ;

- (void)render ;
- (void)render:(BOOL)goHome ;
- (void)currentBookChanged:(void(^)(NoteBooks *book, bool isClick))blkChange ;


- (void)refreshHomeWithBook:(NoteBooks *)book ;

@end

NS_ASSUME_NONNULL_END
