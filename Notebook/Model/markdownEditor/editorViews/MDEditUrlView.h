//
//  MDEditUrlView.h
//  Notebook
//
//  Created by teason23 on 2019/3/25.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkdownModel.h"

@class XTTextField ;

typedef void(^CallbackBlk)(BOOL isConfirm, NSString *title, NSString *url) ;

@interface MDEditUrlView : UIView
@property (weak, nonatomic) IBOutlet XTTextField *tfTitle;
@property (weak, nonatomic) IBOutlet XTTextField *tfUrl;
@property (copy, nonatomic) CallbackBlk blk ;

+ (void)showOnView:(UITextView *)editor
            window:(UIWindow *)window
             model:(MarkdownModel *)model
    keyboardHeight:(CGFloat)keyboardHeight
          callback:(CallbackBlk)blk ;

@end


