//
//  MarkdownVC.h
//  Notebook
//
//  Created by teason23 on 2019/3/8.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BasicVC.h"

@protocol MarkdownVCDelegate <NSObject>
- (void)addNoteComplete:(Note *)aNote ;
- (void)editNoteComplete:(Note *)aNote ;
@end

@interface MarkdownVC : BasicVC
@property (nonatomic)       BOOL                    canBeEdited ;
@property (weak, nonatomic) id <MarkdownVCDelegate> delegate ;

+ (instancetype)newWithNote:(Note *)note
                     bookID:(NSString *)bookID
                fromCtrller:(UIViewController *)ctrller ;

@end


