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

    NSString *inviroment ;
#ifdef DEBUG
    inviroment = @"dev环境" ;
#else
    inviroment = @"product环境" ;
#endif
    
    
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"😝😝😝" message:XT_STR_FORMAT(@"%@(%@) - %@",versionNum,buildNum,inviroment) cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"清空本地数据",@"清空iCloud数据",@"清空iCloud消息订阅",@"编辑器加载本地or线上"] callBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            [self clearLocal] ;
        }
        else if (btnIndex == 2) {
            [self clearICloud] ;
        }
        else if (btnIndex == 3) {
            [self clearSubscribtion] ;
        }
        else if (btnIndex == 4) {
            [self editorLoadFromLocalOrOnline] ;
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

+ (void)editorLoadFromLocalOrOnline {
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"切换editor加载" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"本地",@"线上"] fromWithView:nil CallBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            [self switchEditorLoadWay:0] ;
        }
        else if (btnIndex == 2) {
            [self switchEditorLoadWay:1] ;
        }
        
    }] ;
}

//0本地 1线上
static NSString *const k_UD_isLoadWebViewOnline = @"k_UD_isLoadWebViewOnline" ;
+ (void)switchEditorLoadWay:(BOOL)isOnline {
    XT_USERDEFAULT_SET_VAL(@(isOnline), k_UD_isLoadWebViewOnline) ;
}

+ (BOOL)getEditorLoadWay {
    return [XT_USERDEFAULT_GET_VAL(k_UD_isLoadWebViewOnline) boolValue] ;
}


@end
