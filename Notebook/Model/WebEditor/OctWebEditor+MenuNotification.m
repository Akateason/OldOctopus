//
//  OctWebEditor+MenuNotification.m
//  Notebook
//
//  Created by teason23 on 2020/1/8.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "OctWebEditor+MenuNotification.h"
#import "OctWebEditor+OctToolbarUtil.h"




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
            
        }
        else if ([funcName isEqualToString:@"actionTitle2"]) {
            
        }
        else if ([funcName isEqualToString:@"actionTitle3"]) {
            
        }
        else if ([funcName isEqualToString:@"actionTitle4"]) {
            
        }
        else if ([funcName isEqualToString:@"actionTitle5"]) {
            
        }
        else if ([funcName isEqualToString:@"actionTitle6"]) {
            
        }
        else if ([funcName isEqualToString:@"actionUpTitle"]) {
            
        }
        else if ([funcName isEqualToString:@"actionDownTitle"]) {
            
        }
        else if ([funcName isEqualToString:@"actionForm"]) {
            
        }
        else if ([funcName isEqualToString:@"actionCodeBlock"]) {
            
        }
        else if ([funcName isEqualToString:@"actionQuote"]) {
                        
        }
        else if ([funcName isEqualToString:@"actionMath"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionHtml"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionOList"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionUList"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionTList"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionSwitchList"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionOpenPara"]) {
                                  
        }
        else if ([funcName isEqualToString:@"actionSepline"]) {
                                  
        }

        
        
    }] ;
}

@end
