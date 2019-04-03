//
//  AppDelegate.m
//  Notebook
//
//  Created by teason23 on 2019/2/19.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "AppDelegate.h"
#import <XTlib/XTlib.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "XTCloudHandler.h"
#import "MDImageManager.h"
#import "Note.h"
#import "NoteBooks.h"


@interface AppDelegate ()

@end


@implementation AppDelegate


- (void)test {
    
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
//    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications] ;
    
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupIcloudEvent] ;
    
    
    
    [self test] ;

    return YES;
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
    manager.enable             = YES; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO;  // 控制是否显示键盘上的工具条
}

NSString *const kFirstTimeLaunch = @"kFirstTimeLaunch" ;
- (void)setupIcloudEvent {
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        NSLog(@"user : %@", [user yy_modelToJSONString]) ;
    }] ;
    
    [[XTCloudHandler sharedInstance] saveSubscription] ;
    
    BOOL fstTimeLaunch = [XT_USERDEFAULT_GET_VAL(kFirstTimeLaunch) intValue] ;
    if (fstTimeLaunch) {
        [NoteBooks getFromServerComplete:^{
            
            [Note getFromServerComplete:^{
                
                XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
            }] ;
        }] ;
    }
    else {
        [self icloudSync] ;
    }
    

}

- (void)icloudSync {
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
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
    }] ;
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult result))completionHandler {
    
//    CKNotification *cloudKitNotification = [CKNotification notificationFromRemoteNotificationDictionary:userInfo];
//    NSString *alertBody = cloudKitNotification.alertBody;
//    NSString *alertLocalizationKey = cloudKitNotification.alertLocalizationKey ;
//    if (cloudKitNotification.notificationType == CKNotificationTypeQuery) {
//        CKRecordID *recordID = [(CKQueryNotification *)cloudKitNotification recordID] ;
//        // todo Update ID
//        if ([alertLocalizationKey isEqualToString:@"Note_Changed"]) {
//
//        }
//        else if ([alertLocalizationKey isEqualToString:@"NoteBook_Changed"]) {
//
//        }
//    }
    
//    Update views or notify the user according to the record changes.
    [self icloudSync] ;
    
}


@end
