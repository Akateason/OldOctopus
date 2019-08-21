//
//  BookBgView.h
//  Notebook
//
//  Created by teason23 on 2019/8/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface BookBgView : UIView

- (instancetype)initWithSize:(BOOL)bigOrSmall
                        book:(NoteBooks *)book ;

- (void)configBook:(NoteBooks *)book ;

@property (strong, nonatomic) UIImageView *imageBgView ;
@property (strong, nonatomic) UIImageView *imageBookView ;
@property (strong, nonatomic) UILabel *lbEmoji ;

@end


