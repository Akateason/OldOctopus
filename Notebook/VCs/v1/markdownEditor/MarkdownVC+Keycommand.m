//
//  MarkdownVC+Keycommand.m
//  Notebook
//
//  Created by teason23 on 2019/10/29.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "MarkdownVC+Keycommand.h"


@implementation MarkdownVC (Keycommand)


#pragma mark - UIkeyCommand iPad

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSArray<UIKeyCommand *>*)keyCommands {
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
             
             [UIKeyCommand keyCommandWithInput:@"M"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"以Markdown格式拷贝"],
             [UIKeyCommand keyCommandWithInput:@"H"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"以Html格式拷贝"],
             [UIKeyCommand keyCommandWithInput:@"V"
                                 modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"粘贴纯文本"],
             
             [UIKeyCommand keyCommandWithInput:@"P"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"重复段落"],
             [UIKeyCommand keyCommandWithInput:@"B"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
                           action:@selector(selectTab:)
             discoverabilityTitle:@"新建段落"],
             [UIKeyCommand keyCommandWithInput:@"D"
                    modifierFlags:UIKeyModifierCommand | UIKeyModifierAlternate
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
             discoverabilityTitle:@"加粗"],
             [UIKeyCommand keyCommandWithInput:@"I"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"斜体"],
             [UIKeyCommand keyCommandWithInput:@"`"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"行内代码"],
             [UIKeyCommand keyCommandWithInput:@"D"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"删除线"],
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
             discoverabilityTitle:@"清除样式"],
             
             [UIKeyCommand keyCommandWithInput:@"T"
                    modifierFlags:UIKeyModifierCommand
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
             
             [UIKeyCommand keyCommandWithInput:@"0"
                    modifierFlags:UIKeyModifierCommand
                           action:@selector(selectTab:)
             discoverabilityTitle:@"段落"],
             
             
             
             ] ;
}

- (void)selectTab:(UIKeyCommand *)sender {
    NSString *title = sender.discoverabilityTitle;
    NSLog(@"%@",title) ;
    if ([title isEqualToString:@"全选"]) {
        
    }
    else if ([title isEqualToString:@"撤销"]) {
        
    }
    else if ([title isEqualToString:@"重做"]) {
        
    }
    
    
    
}


@end
