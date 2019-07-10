//
//  OctShareCopyLinkView.h
//  Notebook
//
//  Created by teason23 on 2019/7/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^OctCompletion)(BOOL ok);

@interface OctShareCopyLinkView : UIView
@property (weak, nonatomic) IBOutlet UIView *hud;
@property (weak, nonatomic) IBOutlet UILabel *lbTitle;
@property (weak, nonatomic) IBOutlet UITextField *tf;
@property (weak, nonatomic) IBOutlet UIButton *btConfirm;
@property (weak, nonatomic) IBOutlet UIButton *btCancel;

@property (copy, nonatomic) OctCompletion completion ;

+ (void)showOnView:(UIView *)onView
              link:(NSString *)link
          complete:(OctCompletion)completeBlk  ;

@end

NS_ASSUME_NONNULL_END
