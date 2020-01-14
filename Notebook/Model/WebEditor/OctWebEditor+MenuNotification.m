//
//  OctWebEditor+MenuNotification.m
//  Notebook
//
//  Created by teason23 on 2020/1/8.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "OctWebEditor+MenuNotification.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "OctWebEditor+InlineBoardUtil.h"
#import "OctWebEditor+BlockBoardUtil.h"




@implementation OctWebEditor (MenuNotification)

- (void)setupMenuNotification {
    @weakify(self)
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kNote_Menu_Edit_Group object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
        @strongify(self)
        
        if (self.webView.window == nil) return ;
            
        NSString *funcName = x.object ;
        if ([funcName isEqualToString:@"actionAllSelect"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"selectAll" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionUndo"]) {
            [self toolbarDidSelectUndo] ;
        }
        else if ([funcName isEqualToString:@"actionRedo"]) {
            [self toolbarDidSelectRedo] ;
        }
        else if ([funcName isEqualToString:@"actionParaRepeat"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"duplicate" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionParaNew"]) {
            NSDictionary *dic = @{@"location":@"after",
                                  @"text":@"",
                                  @"outMost":@(TRUE)} ;
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"insertParagraph" json:dic completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionParaDelete"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"deleteParagraph" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionTitle1"]) {
            [self toolbarDidSelectH1] ;
        }
        else if ([funcName isEqualToString:@"actionTitle2"]) {
            [self toolbarDidSelectH2] ;
        }
        else if ([funcName isEqualToString:@"actionTitle3"]) {
            [self toolbarDidSelectH3] ;
        }
        else if ([funcName isEqualToString:@"actionTitle4"]) {
            [self toolbarDidSelectH4] ;
        }
        else if ([funcName isEqualToString:@"actionTitle5"]) {
            [self toolbarDidSelectH5] ;
        }
        else if ([funcName isEqualToString:@"actionTitle6"]) {
            [self toolbarDidSelectH6] ;
        }
        else if ([funcName isEqualToString:@"actionUpTitle"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"upgradeTitle" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionDownTitle"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"degradeTitle" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionForm"]) {
            [self toolbarDidSelectTable] ;
        }
        else if ([funcName isEqualToString:@"actionCodeBlock"]) {
            [self toolbarDidSelectCodeBlock] ;
        }
        else if ([funcName isEqualToString:@"actionQuote"]) {
            [self toolbarDidSelectQuoteBlock] ;
        }
        else if ([funcName isEqualToString:@"actionMath"]) {
            [self toolbarDidSelectMathBlock] ;
        }
        else if ([funcName isEqualToString:@"actionHtml"]) {
            [self toolbarDidSelectHtml] ;
        }
        else if ([funcName isEqualToString:@"actionOList"]) {
            [self toolbarDidSelectOrderlist] ;
        }
        else if ([funcName isEqualToString:@"actionUList"]) {
            [self toolbarDidSelectUList];
        }
        else if ([funcName isEqualToString:@"actionTList"]) {
            [self toolbarDidSelectTaskList] ;
        }
        else if ([funcName isEqualToString:@"actionSwitchList"]) {
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"toggleListItemType" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionOpenPara"]) {
            NSDictionary *dic = @{@"location":@"after",
                                  @"text":@"",
                                  @"outMost":@(TRUE)} ;
            [[OctWebEditor sharedInstance] nativeCallJSWithFunc:@"insertParagraph" json:dic completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionSepline"]) {
            [self toolbarDidSelectSepLine] ;
        }
        else if ([funcName isEqualToString:@"actionBold"]) {
            [self toolbarDidSelectBold] ;
        }
        else if ([funcName isEqualToString:@"actionItalic"]) {
            [self toolbarDidSelectItalic] ;
        }
        else if ([funcName isEqualToString:@"actionInlineCode"]) {
            [self toolbarDidSelectInlineCode] ;
        }
        else if ([funcName isEqualToString:@"actionDeleteLine"]) {
            [self toolbarDidSelectDeletion] ;
        }
        else if ([funcName isEqualToString:@"actionLink"]) {
            [self nativeCallJSWithFunc:@"addLink" json:nil completion:^(NSString *val, NSError *error) {
            }] ;
        }
        else if ([funcName isEqualToString:@"actionPicture"]) {
            // todo mac 获取图片
        }
        else if ([funcName isEqualToString:@"actionClearStyle"]) {
            [self toolbarDidSelectClearToCleanPara] ;
        }
        
        
    }] ;
}

@end
