//
//  HiddenUtil.m
//  Notebook
//
//  Created by teason23 on 2019/4/22.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "HiddenUtil.h"
#import "Note.h"
#import "NewBookVC.h"
#import "XTCloudHandler.h"
#import <XTlib/XTlib.h>
#import "LaunchingEvents.h"


@implementation HiddenUtil

+ (void)showAlert {
    NSString *versionNum = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] ;
    NSString *buildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ;
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"😝😝😝" message:XT_STR_FORMAT(@"%@(%@)",versionNum,buildNum) cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"清空本地数据",@"清空iCloud数据",@"清空iCloud消息订阅"] callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            [self clearLocal] ;
        }
        else if (btnIndex == 2) {
            [self clearICloud] ;
        }
        else if (btnIndex == 3) {
            [self clearSubscribtion] ;
        }
        
    }] ;
}


+ (void)clearLocal {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"确定清空本地数据?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            [XTFileManager deleteFile:[OCTUPUS_DB_Location stringByAppendingString:@".sqlite"]] ;
            USERDEFAULT_DELTE_VAL(kFirstTimeLaunch) ;
        }
                
    }] ;
}

+ (void)clearICloud {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"确定清空iCloud云端数据?" message:@"一旦清空无法复原" cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            
            [Note deleteAllNoteComplete:^(bool success) {
                
            }] ;
            
            [NoteBooks deleteAllNoteBookComplete:^(bool success) {
                
            }] ;
        }
        
    }] ;
}

+ (void)clearSubscribtion {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"确定清空iCloud云端订阅?" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:@"确定" otherButtonTitles:nil callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            
            [[XTCloudHandler sharedInstance] deleteAllSubscriptionCompletion:^(BOOL success) {
                
            }] ;
        }
        
    }] ;
}





@end
