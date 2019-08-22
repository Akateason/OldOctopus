//
//  BookBgView.m
//  Notebook
//
//  Created by teason23 on 2019/8/21.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "BookBgView.h"

@implementation BookBgView

- (instancetype)initWithSize:(BOOL)bigOrSmall
                        book:(NoteBooks *)book
{
    self = [super init] ;
    if (self) {
        float length = bigOrSmall ? 42. : 26.  ;
        self.frame = CGRectMake(0, 0, length, length) ;
        
        NSString *imgStr = bigOrSmall ? @"book_bg_big@2x" : @"book_bg_small@2x" ;
        NSString *filePath = [[NSBundle mainBundle] pathForResource:imgStr ofType:@"png"] ;
        UIImage *image = [UIImage imageWithContentsOfFile:filePath] ;
        UIImageView *imageBgView = [[UIImageView alloc] initWithImage:image] ;
        [self addSubview:imageBgView] ;
        [imageBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self) ;
            make.width.height.equalTo(@(length)) ;
        }] ;
        self.imageBgView = imageBgView ;
        
        UIImageView *imageBookView = [[UIImageView alloc] init] ;
        [self addSubview:imageBookView] ;
        [imageBookView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self) ;
            make.width.height.equalTo(@(bigOrSmall ? 24. : 21.)) ;
        }] ;
        self.imageBookView = imageBookView ;
        self.imageBookView.hidden = YES ;
        
        UILabel *lb = [UILabel new] ;
        lb.font = [UIFont systemFontOfSize:bigOrSmall ? 22 : 14] ;
        
        [self addSubview:lb] ;
        [lb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self) ;
        }] ;
        self.lbEmoji = lb ;
        self.lbEmoji.hidden = YES ;
        
        if (book.vType != Notebook_Type_notebook) {
            UIImage *image = [UIImage imageNamed:book.emoji] ;
            self.imageBookView.image = image ;
            self.imageBookView.hidden = NO ;
            self.lbEmoji.hidden = YES ;
        }
        else {
            self.lbEmoji.text = book.displayEmoji ;
            self.imageBookView.hidden = YES ;
            self.lbEmoji.hidden = NO ;
        }
    }
    return self ;
}

- (void)configBook:(NoteBooks *)book {
    if (book.vType != Notebook_Type_notebook) {
        UIImage *image = [UIImage imageNamed:book.emoji] ;
        self.imageBookView.image = image ;

        self.imageBookView.hidden = NO ;
        self.lbEmoji.hidden = YES ;
    }
    else {
        self.lbEmoji.text = book.displayEmoji ;
        
        self.imageBookView.hidden = YES ;
        self.lbEmoji.hidden = NO ;
    }
}


@end
