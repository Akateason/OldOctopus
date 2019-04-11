//
//  LaunchingEvents.m
//  Notebook
//
//  Created by teason23 on 2019/4/11.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "LaunchingEvents.h"
#import <XTlib/XTlib.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "XTCloudHandler.h"
#import "MDImageManager.h"
#import "Note.h"
#import "NoteBooks.h"
#import <UserNotifications/UserNotifications.h>

NSString *const kNotificationSyncCompleteAllPageRefresh = @"kNotificationSyncCompleteAllPageRefresh" ;

@implementation LaunchingEvents

- (void)setup:(UIApplication *)application {
    [self setupRemoteNotification:application] ;
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupIcloudEvent] ;
}


/*
 - (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
 
 completionHandler(UNNotificationPresentationOptionBadge) ;
 }
 
 // 通知的点击事件
 - (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler{
 
 NSDictionary * userInfo = response.notification.request.content.userInfo;
 UNNotificationRequest *request = response.notification.request; // 收到推送的请求
 UNNotificationContent *content = request.content; // 收到推送的消息内容
 NSNumber *badge = content.badge; // 推送消息的角标
 NSString *body = content.body; // 推送消息体
 UNNotificationSound *sound = content.sound; // 推送消息的声音
 NSString *subtitle = content.subtitle; // 推送消息的副标题
 NSString *title = content.title; // 推送消息的标题
 if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
 NSLog(@"iOS10 收到远程通知:%@", userInfo);
 }
 else {
 // 判断为本地通知
 NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
 }
 
 // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
 completionHandler(); // 系统要求执行这个方法
 }
 
 - (void)userNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(nullable UNNotification *)notification {
 
 }
 */
- (void)setupRemoteNotification:(UIApplication *)application {
    // 官方文档(无视警告)
    //    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications] ;
    
    //
    //    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //    center.delegate = self;
    //    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
    //        if (granted) {
    //            NSLog(@"注册成功");
    //            [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
    //                NSLog(@"%@", settings);
    //            }];
    //        } else {
    //            NSLog(@"注册失败");
    //        }
    //    }];
}

- (void)setupDB {
    [XTlibConfig sharedInstance].isDebug    = YES;
    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:XT_LIBRARY_PATH_TRAIL_(@"noteDB")];
}

- (void)setupNaviStyle {
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor] ;
}

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable             = YES ; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO ;  // 控制是否显示键盘上的工具条
}

NSString *const kFirstTimeLaunch = @"kFirstTimeLaunch" ;

- (void)setupIcloudEvent {
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        NSLog(@"User Logined : %@", [user yy_modelToJSONString]) ;
        
        if (user) {
            [[XTCloudHandler sharedInstance] saveSubscription] ;
            [self pullOrSync] ;
        }
    }] ;
}

- (void)pullOrSync {
    BOOL fstTimeLaunch = [XT_USERDEFAULT_GET_VAL(kFirstTimeLaunch) intValue] ;
    if (!fstTimeLaunch) {
        [NoteBooks getFromServerComplete:^(bool hasData) {
            if (!hasData) {
                [self createDefaultBookAndNotes] ;
                return ;
            }
            
            [Note getFromServerComplete:^{
                if ([Note xt_count]) XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
            }] ;
        }] ;
    }
    else {
        [self icloudSync:nil] ;
    }
}

- (void)createDefaultBookAndNotes {
    NoteBooks *book = [[NoteBooks alloc] initWithName:@"小章鱼的笔记本" emoji:@"🐙"] ;
    book.isSendOnICloud = NO ;
    [book xt_insert] ;
    
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"zample" ofType:@"md"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)] ;
    Note *note = [[Note alloc] initWithBookID:book.icRecordName content:str title:@"Intro"] ;
    note.isSendOnICloud = NO ;
    [note xt_insert] ;
    
    [[XTCloudHandler sharedInstance] saveList:@[book.record,note.record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        
        if (!error) {
            book.isSendOnICloud = YES ;
            [book xt_update] ;
            note.isSendOnICloud = YES ;
            [note xt_update] ;
        }
    }] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
    XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
}

- (void)icloudSync:(void(^)(void))completeBlk {
    
    [[XTCloudHandler sharedInstance] syncOperationEveryRecord:^(CKRecord *record) {
        
        NSString *type = (NSString *)(record.recordType) ;
        
        if ([type isEqualToString:@"Note"]) {
            Note *note = [Note recordToNote:record] ;
            note.xt_updateTime = [record.modificationDate xt_getTick] ;
            [note xt_upsertWhereByProp:@"icRecordName"] ;
        }
        else if ([type isEqualToString:@"NoteBook"]) {
            NoteBooks *book = [NoteBooks recordToNoteBooks:record] ;
            book.xt_updateTime = [record.modificationDate xt_getTick] ;
            [book xt_upsertWhereByProp:@"icRecordName"] ;
        }
        
    } delete:^(CKRecordID *recordID, CKRecordType recordType) {
        
        NSString *type = (NSString *)(recordType) ;
        if ([type isEqualToString:@"Note"]) {
            [Note xt_deleteModelWhere:XT_STR_FORMAT(@"icRecordName == '%@'",recordID.recordName)] ;
        }
        else if ([type isEqualToString:@"NoteBook"]) {
            [NoteBooks xt_deleteModelWhere:XT_STR_FORMAT(@"icRecordName == '%@'",recordID.recordName)] ;
        }
        
    } allComplete:^(NSError *operationError) {
        
        if (!operationError) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
        if (completeBlk) completeBlk() ;
    }] ;
}


@end
