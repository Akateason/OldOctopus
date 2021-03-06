//
//  LeftDrawerVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/28.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"
@class NoteBooks ;



@interface LeftDrawerVC : BasicVC
@property (strong, nonatomic) NoteBooks *currentBook ;

- (void)render ;

- (void)currentBookChanged:(void(^)(NoteBooks *book))blkChange ;
- (void)bookCellTapped:(void(^)(void))blk  ;


// 删除笔记本时用. 找下一个有用的笔记本
- (NoteBooks *)nextUsefulBook ;

- (void)refreshHomeWithBook:(NoteBooks *)book ;






@end


