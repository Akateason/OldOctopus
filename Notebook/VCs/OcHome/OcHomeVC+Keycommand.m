//
//  OcHomeVC+Keycommand.m
//  Notebook
//
//  Created by teason23 on 2019/11/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "OcHomeVC+Keycommand.h"

@implementation OcHomeVC (Keycommand)

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (NSArray<UIKeyCommand *>*)keyCommands {
#ifdef ISMAC
    return @[] ;
#endif
    
    
    return @[
             [UIKeyCommand keyCommandWithInput:@"N"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"新建笔记"],
             [UIKeyCommand keyCommandWithInput:@"B"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"新建笔记本"],
             [UIKeyCommand keyCommandWithInput:@"R"
                                 modifierFlags:UIKeyModifierCommand
                                        action:@selector(selectTab:)
                          discoverabilityTitle:@"手动同步iCloud"],
             ] ;
}

- (void)selectTab:(UIKeyCommand *)sender {
    [self.subjectKeycommand sendNext:sender] ;        
}

- (void)keycommandCallback:(UIKeyCommand *)sender {
    NSString *title = sender.discoverabilityTitle;
    NSLog(@"%@",title) ;
    if ([title isEqualToString:@"新建笔记"]) {
        [self addNoteOnClick] ;
    }
    else if ([title isEqualToString:@"新建笔记本"]) {
        [self addBookOnClick] ;
    }
    else if ([title containsString:@"手动同步"]) {
        
        [[LaunchingEvents sharedInstance] pullAllComplete:^{
            [SVProgressHUD showSuccessWithStatus:@"手动同步完成"] ;
        }] ;
    }
}

@end
