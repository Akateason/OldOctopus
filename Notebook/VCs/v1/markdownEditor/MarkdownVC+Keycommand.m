//
//  MarkdownVC+Keycommand.m
//  Notebook
//
//  Created by teason23 on 2019/10/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC+Keycommand.h"
#import "OctWebEditor.h"
#import "OctWebEditor+OctToolbarUtil.h"
#import "OctWebEditor+InlineBoardUtil.h"
#import "OctWebEditor+BlockBoardUtil.h"

@implementation MarkdownVC (Keycommand)



#pragma mark - UIkeyCommand iPad

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSArray<UIKeyCommand *>*)keyCommands {
#ifdef ISMAC
    return @[] ;
#endif
            
    return @[
             [UIKeyCommand keyCommandWithInput:@"A"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"全选"],
             [UIKeyCommand keyCommandWithInput:@"Z"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"撤销"],
             [UIKeyCommand keyCommandWithInput:@"Z"
                                 modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"重做"],
             
             [UIKeyCommand keyCommandWithInput:@"C"
                                 modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"以Markdown格式拷贝"],
             [UIKeyCommand keyCommandWithInput:@"C"
                                 modifierFlags:UIKeyModifierCommand | UIKeyModifierControl | UIKeyModifierShift
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"以Html格式拷贝"],
             [UIKeyCommand keyCommandWithInput:@"V"
                                 modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"粘贴纯文本"],
             
             [UIKeyCommand keyCommandWithInput:@"V"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
                           action:@selector(selectTab:)
             discoverabilityTitle:@"重复段落"],
             [UIKeyCommand keyCommandWithInput:@"N"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"新建段落"],
             [UIKeyCommand keyCommandWithInput:@"D"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierShift
                           action:@selector(selectTab:)
             discoverabilityTitle:@"删除段落"],
             
             [UIKeyCommand keyCommandWithInput:@"1"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题1"],
             [UIKeyCommand keyCommandWithInput:@"2"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题2"],
             [UIKeyCommand keyCommandWithInput:@"3"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题3"],
             [UIKeyCommand keyCommandWithInput:@"4"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题4"],
             [UIKeyCommand keyCommandWithInput:@"5"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题5"],
             [UIKeyCommand keyCommandWithInput:@"6"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"标题6"],
                          
             [UIKeyCommand keyCommandWithInput:@"="
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"升级标题"],
             [UIKeyCommand keyCommandWithInput:@"-"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"降级标题"],
             
             [UIKeyCommand keyCommandWithInput:@"-"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"水平分割线"],
             
             [UIKeyCommand keyCommandWithInput:@"B"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"重点"],
             [UIKeyCommand keyCommandWithInput:@"I"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"强调"],
             [UIKeyCommand keyCommandWithInput:@"`"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"行内代码"],
             [UIKeyCommand keyCommandWithInput:@"D"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"删除线"],
             [UIKeyCommand keyCommandWithInput:@"U"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"下划线"],
             [UIKeyCommand keyCommandWithInput:@"L"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"链接"],
             [UIKeyCommand keyCommandWithInput:@"I"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"图片"],
             [UIKeyCommand keyCommandWithInput:@"R"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"清除样式(行内/段落)"],
             
             [UIKeyCommand keyCommandWithInput:@"T"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"表格"],
             [UIKeyCommand keyCommandWithInput:@"C"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"代码块"],
             [UIKeyCommand keyCommandWithInput:@"Q"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"引用块"],
             [UIKeyCommand keyCommandWithInput:@"M"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"数学公式块"],
             [UIKeyCommand keyCommandWithInput:@"J"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"HTML块"],
             
             [UIKeyCommand keyCommandWithInput:@"O"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"有序列表"],
             [UIKeyCommand keyCommandWithInput:@"U"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"无序列表"],
             [UIKeyCommand keyCommandWithInput:@"X"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"任务列表"],
             
             [UIKeyCommand keyCommandWithInput:@"L"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"切换Loose/Tight列表"],
             
             
             
             
             
             ] ;
}

- (void)selectTab:(UIKeyCommand *)sender {
    [self.subjectIpadKeyboardCommand sendNext:sender] ;
}


- (void)callbackKeycommand:(UIKeyCommand *)sender {
    
    NSString *title = sender.discoverabilityTitle;
    NSLog(@"---- 快捷键 ---- %@",title) ;
//    [SVProgressHUD showWithStatus:title] ;
    
    
    if ([title isEqualToString:@"全选"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"selectAll" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"撤销"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectUndo] ;
    }
    else if ([title isEqualToString:@"重做"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectRedo] ;
    }
    
    else if ([title isEqualToString:@"以Markdown格式拷贝"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"copyAsMarkdown" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"以Html格式拷贝"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"copyAsHtml" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"粘贴纯文本"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"pasteAsPlainText" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    
    else if ([title isEqualToString:@"重复段落"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"duplicate" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"新建段落"]) {
        NSDictionary *dic = @{@"location":@"after",
                              @"text":@"",
                              @"outMost":@(TRUE)} ;
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"insertParagraph" json:dic completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"删除段落"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"deleteParagraph" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    
    else if ([title isEqualToString:@"标题1"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH1] ;
    }
    else if ([title isEqualToString:@"标题2"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH2] ;
    }
    else if ([title isEqualToString:@"标题3"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH3] ;
    }
    else if ([title isEqualToString:@"标题4"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH4] ;
    }
    else if ([title isEqualToString:@"标题5"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH5] ;
    }
    else if ([title isEqualToString:@"标题6"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectH6] ;
    }
    
    else if ([title isEqualToString:@"升级标题"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"upgradeTitle" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"降级标题"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"degradeTitle" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    
    else if ([title isEqualToString:@"水平分割线"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectSepLine] ;
    }
    
    else if ([title isEqualToString:@"重点"]) { // bold
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectBold] ;
    }
    else if ([title isEqualToString:@"强调"]) { // italic
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectItalic] ;
    }
    else if ([title isEqualToString:@"行内代码"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectInlineCode] ;
    }
    else if ([title isEqualToString:@"删除线"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectDeletion] ;
    }
    else if ([title isEqualToString:@"下划线"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectUnderline] ;
    }
    else if ([title isEqualToString:@"链接"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"addLink" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    else if ([title isEqualToString:@"图片"]) {
        [[OctWebEditor currentOctWebEditor].toolBar openPhotoPart] ;
    }
    else if ([title isEqualToString:@"清除样式(行内/段落)"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectClearToCleanPara] ;
    }
    
    else if ([title isEqualToString:@"表格"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectTable] ;
    }
    else if ([title isEqualToString:@"代码块"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectCodeBlock] ;
    }
    else if ([title isEqualToString:@"引用块"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectQuoteBlock] ;
    }
    else if ([title isEqualToString:@"数学公式块"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectMathBlock] ;
    }
    else if ([title isEqualToString:@"HTML块"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectHtml] ;
    }
    
    else if ([title isEqualToString:@"有序列表"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectOrderlist] ;
    }
    else if ([title isEqualToString:@"无序列表"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectUList] ;
    }
    else if ([title isEqualToString:@"任务列表"]) {
        [[OctWebEditor currentOctWebEditor] toolbarDidSelectTaskList] ;
    }
    else if ([title isEqualToString:@"切换Loose/Tight列表"]) {
        [[OctWebEditor currentOctWebEditor] nativeCallJSWithFunc:@"toggleListItemType" json:nil completion:^(NSString *val, NSError *error) {
            
        }] ;
    }
    
    
    
    
}


@end
