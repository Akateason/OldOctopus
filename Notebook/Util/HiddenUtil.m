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
    
    NSString *editorState = XT_STR_FORMAT(@"编辑器 : %@", [self getEditorLoadWay]?@"连接电脑调试":@"本地zip") ;
    NSString *devLinkStr = XT_STR_FORMAT(@"更改开发者编辑器url地址: %@",[self developerMacLink]) ;
    
    NSString *userIDStr = XT_STR_FORMAT(@"用户id : %@, 点击复制uid",[XTIcloudUser userInCacheSyncGet].userRecordName) ;
    
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"😝😝😝" message:XT_STR_FORMAT(@"%@(%@) - %@ - %@",versionNum,buildNum,inviroment,editorState) cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"清空本地数据",@"清空iCloud数据",@"清空iCloud消息订阅",@"编辑器加载本地zip或者开发者url",devLinkStr,userIDStr] callBackBlock:^(NSInteger btnIndex) {
        
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
        else if (btnIndex == 5) {
            [self devLinkChanging] ;
        }
        else if (btnIndex == 6) {
            [self copyUserIDLink] ;
        }
        
    }] ;
}


+ (void)copyUserIDLink {
    NSString *userID = [XTIcloudUser userInCacheSyncGet].userRecordName ;
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = userID ;
    [SVProgressHUD showSuccessWithStatus:@"uid已复制"] ;
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
    [UIAlertController xt_showAlertCntrollerWithAlertControllerStyle:UIAlertControllerStyleAlert title:@"切换editor加载" message:nil cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@[@"本地zip",@"开发者url"] fromWithView:nil CallBackBlock:^(NSInteger btnIndex) {
        
        if (btnIndex == 1) {
            [self switchEditorLoadWay:0] ;
        }
        else if (btnIndex == 2) {
            [self switchEditorLoadWay:1] ;
        }
        
    }] ;
}

+ (void)devLinkChanging {
    [UIAlertController xt_showTextFieldAlertWithTitle:@"更改编辑器调试地址" subtitle:@"形如: http://192.168.50.97:3000/" cancel:@"取消" commit:@"保存" placeHolder:@"输入" fromWithView:nil callback:^(BOOL isConfirm, NSString *text) {
        
        if (isConfirm) {
            [self setDeveloperMacLink:text] ;
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


// 线上地址
static NSString *const k_UD_Developer_Mac_Tune_Link = @"k_UD_Developer_Mac_Tune_Link" ;
+ (NSString *)developerMacLink {
    NSString *link = XT_USERDEFAULT_GET_VAL(k_UD_Developer_Mac_Tune_Link) ;
    return link ?: @"http://192.168.50.97:3000/" ;
}

+ (void)setDeveloperMacLink:(NSString *)link {
    XT_USERDEFAULT_SET_VAL(link, k_UD_Developer_Mac_Tune_Link) ;
}

@end
