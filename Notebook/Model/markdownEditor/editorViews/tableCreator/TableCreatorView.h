//
//  TableCreatorView.h
//  Notebook
//
//  Created by teason23 on 2019/6/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef void(^CallbackBlk)(BOOL isConfirm, NSString *line, NSString *column) ;

@interface TableCreatorView : UIView
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITextField *tfLineCount;
@property (weak, nonatomic) IBOutlet UITextField *tfColumnCount;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;
@property (weak, nonatomic) IBOutlet UIButton *btOk;
@property (copy, nonatomic) CallbackBlk blk ;

+ (void)showOnView:(UIView *)onView
            window:(UIWindow *)window
    keyboardHeight:(CGFloat)keyboardHeight
          callback:(CallbackBlk)blk ;

@end

