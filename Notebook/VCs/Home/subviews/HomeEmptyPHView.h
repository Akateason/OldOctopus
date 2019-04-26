//
//  HomeEmptyPHView.h
//  Notebook
//
//  Created by teason23 on 2019/4/1.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
@class NoteBooks ;

NS_ASSUME_NONNULL_BEGIN

@interface HomeEmptyPHView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbEmoji;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UIView *area;
@property (weak, nonatomic) IBOutlet UILabel *lbPh;
@property (weak, nonatomic) IBOutlet UIImageView *imgIcon;


@property (strong, nonatomic) NoteBooks *book ;
@property (nonatomic) BOOL isMark ;
//- (void)start ;

@end

NS_ASSUME_NONNULL_END
