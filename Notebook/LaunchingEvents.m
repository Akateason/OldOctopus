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
#import "XTMarkdownParser+ImageUtil.h"
#import "Note.h"
#import "NoteBooks.h"
#import <UserNotifications/UserNotifications.h>
#import <XTReq/XTReq.h>
#import "MDThemeConfiguration.h"
#import <Bugly/Bugly.h>
#import "AppDelegate.h"
#import "GuidingVC.h"
#import "HomeVC.h"
#import "MDNavVC.h"
#import "WebPhotoHandler.h"
#import "HomePadVC.h"
#import "OctWebEditor.h"
#import <SSZipArchive/SSZipArchive.h>
#import <Photos/Photos.h>




NSString *const kNotificationSyncCompleteAllPageRefresh = @"kNotificationSyncCompleteAllPageRefresh" ;

@implementation LaunchingEvents

#pragma mark - did finish launching

- (void)setup:(UIApplication *)application appdelegate:(AppDelegate *)appDelegate {
    //    if (!DEBUG)
    [Bugly startWithAppId:@"8abe605307"] ;

    self.appDelegate = appDelegate ;
    [[MDThemeConfiguration sharedInstance] setup] ;
    [self setupWebZipPackageAndSetupWebView] ;
    [self setupRemoteNotification:application] ;
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupLoadingHomePage] ;
    [self setupIcloudEvent] ;
    [self uploadAllLocalDataIfNotUploaded] ;
    [self setupHudStyle] ;
}

- (void)setupAlbumn {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
    }] ;
}

/**
 1. setupWebZipPackage
 2. setupWebView
 */
static NSString *const kMark_UNZip_Operation = @"kMark_UNZip_Operation" ;
- (void)setupWebZipPackageAndSetupWebView {
    NSString *pathIndex = XT_DOCUMENTS_PATH_TRAIL_(@"web/index.html") ;
    
    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kMark_UNZip_Operation) ;
    BOOL isNotNewVersion = [currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending ;
    
    if (![XTFileManager isFileExist:pathIndex] || !isNotNewVersion) {
        NSString *lastFolderPath = XT_DOCUMENTS_PATH_TRAIL_(@"web") ;
        [XTFileManager deleteFile:lastFolderPath] ;
        
        NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"web" ofType:@"zip"] ;
        NSString *unzipPath = [XTArchive getDocumentsPath] ;
        [SSZipArchive unzipFileAtPath:zipPath toDestination:unzipPath delegate:(id <SSZipArchiveDelegate>)self];
        XT_USERDEFAULT_SET_VAL(currentVersion, kMark_UNZip_Operation) ;
    }
    else {
        [self setupWebView] ;
    }
}

/**
 SSZipArchiveDelegate
 */
- (void)zipArchiveDidUnzipArchiveAtPath:(NSString *)path zipInfo:(unz_global_info)zipInfo unzippedPath:(NSString *)unzippedPath {
    [self setupWebView] ;
}

- (void)setupWebView {
    [[OctWebEditor sharedInstance] setup] ;
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
#ifdef DEBUG
    [XTlibConfig sharedInstance].isDebug    = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:OCTUPUS_DB_Location_Dev];
#else
    [XTlibConfig sharedInstance].isDebug    = NO;
    [[XTFMDBBase sharedInstance] configureDBWithPath:OCTUPUS_DB_Location];
#endif
    
    
    [Note       xt_createTable] ;
    [NoteBooks  xt_createTable] ;
    [WebPhoto   xt_createTable] ;
    
    // upgrade db
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Note.class paramsAdd:@[@"searchContent"] version:2] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Note.class paramsAdd:@[@"modifyDateOnServer"] version:3] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:NoteBooks.class paramsAdd:@[@"modifyDateOnServer"] version:4] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Note.class paramsAdd:@[@"createDateOnServer"] version:5] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:NoteBooks.class paramsAdd:@[@"createDateOnServer"] version:6] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Note.class paramsAdd:@[@"isTop",@"comeFrom"] version:7] ;
    [[XTFMDBBase sharedInstance] dbUpgradeTable:NoteBooks.class paramsAdd:@[@"isTop",@"comeFrom"] version:8] ;
}

- (void)setupNaviStyle {
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor] ;
    
    //todo 黑色主题有问题呢
//    [UIView appearance].tintColor = [[MDThemeConfiguration sharedInstance] themeColor:k_md_textColor] ; // change alert contrller tint color ;
    
}

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager] ;
    manager.enable             = YES ; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO ;  // 控制是否显示键盘上的工具条
}

NSString *const kFirstTimeLaunch = @"kFirstTimeLaunch" ;

- (void)setupLoadingHomePage {
    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return ;
    
    [self createDefaultBookAndNotes] ;
}


- (void)setupIcloudEvent {
    [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
        NSLog(@"!!! Icloud User Logined : %@", [user yy_modelToJSONString]) ;
        if (user.userRecordName) {
            [[XTCloudHandler sharedInstance] saveSubscription] ;
            [self pullOrSync] ;
        }
        else {
//            self.appDelegate.window.rootViewController = [HomeVC getMe];
//            [self.appDelegate.window makeKeyAndVisible];
        }
    }] ;
}

- (void)pullOrSync {
    BOOL fstTimeLaunch = [XT_USERDEFAULT_GET_VAL(kFirstTimeLaunch) intValue] ;
    
    if (!fstTimeLaunch) {
        [self pullAll] ;
    }
    else {
        [self icloudSync:nil] ;
    }
    // Set Rootwindow when did become active .
}

- (void)pullAll {
    [NoteBooks getFromServerComplete:^(bool hasData) {
        
        [Note getFromServerComplete:^{
            if ([Note xt_count]) XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ; // pull all in first time
        }] ;
    }] ;
}

- (void)createDefaultBookAndNotes {
//    book default
    NoteBooks *book = [[NoteBooks alloc] initWithName:@"小章鱼" emoji:@"🐙"] ;
    book.icRecordName = @"book-default" ; // 默认笔记本 id
    book.isSendOnICloud = NO ;
    [book xt_insert] ;
//    introUseICloud
    NSString *path = [[NSBundle bundleForClass:self.class] pathForResource:@"introUseICloud" ofType:@"md"] ;
    NSData *data = [[NSData alloc] initWithContentsOfFile:path];
    NSString *str = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)] ;
    Note *noteICloud = [[Note alloc] initWithBookID:book.icRecordName content:str title:@"如何打开iCloud?"] ;
    noteICloud.isSendOnICloud = NO ;
    noteICloud.icRecordName = @"iOS-note-guide" ; // 默认文章介绍 id
    [noteICloud xt_insert] ;
//    intro
    path = [[NSBundle bundleForClass:self.class] pathForResource:@"intro" ofType:@"md"] ;
    data = [[NSData alloc] initWithContentsOfFile:path];
    str = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)] ;
    Note *note = [[Note alloc] initWithBookID:book.icRecordName content:str title:@"欢迎使用小章鱼🐙"] ;
    note.isSendOnICloud = NO ;
    note.icRecordName = @"iOS-note-intro" ; // 默认文章介绍 id
    [note xt_insert] ;


//  Upload default items .
    [[XTCloudHandler sharedInstance] saveList:@[book.record,noteICloud.record,note.record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        
        if (!error) {
            book.isSendOnICloud = YES ;
            [book xt_update] ;
            note.isSendOnICloud = YES ;
            [note xt_update] ;
            noteICloud.isSendOnICloud = YES ;
            [noteICloud xt_update] ;
        }
    }] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
    XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
}

- (void)icloudSync:(void(^)(void))completeBlk {
    __block BOOL hasSthChanged = NO ;
    
    [[XTCloudHandler sharedInstance] syncOperationEveryRecord:^(CKRecord *record) {
        
        hasSthChanged = YES ;
        
        NSString *type = (NSString *)(record.recordType) ;
        
        if ([type isEqualToString:@"Note"]) {
            Note *note = [Note recordToNote:record] ;
            note.modifyDateOnServer = [record.modificationDate xt_getTick] ;
            note.createDateOnServer = [record.creationDate xt_getTick] ;
            note.isSendOnICloud = YES ;
            [note xt_upsertWhereByProp:@"icRecordName"] ;
        }
        else if ([type isEqualToString:@"NoteBook"]) {
            NoteBooks *book = [NoteBooks recordToNoteBooks:record] ;
            book.modifyDateOnServer = [record.modificationDate xt_getTick] ;
            book.createDateOnServer = [record.creationDate xt_getTick] ;
            book.isSendOnICloud = YES ;
            [book xt_upsertWhereByProp:@"icRecordName"] ;
        }
        
    } delete:^(CKRecordID *recordID, CKRecordType recordType) {
        
        hasSthChanged = YES ;
        
        NSString *type = (NSString *)(recordType) ;
        if ([type isEqualToString:@"Note"]) {
            [Note xt_deleteModelWhere:XT_STR_FORMAT(@"icRecordName == '%@'",recordID.recordName)] ;
        }
        else if ([type isEqualToString:@"NoteBook"]) {
            [NoteBooks xt_deleteModelWhere:XT_STR_FORMAT(@"icRecordName == '%@'",recordID.recordName)] ;
        }
        
    } allComplete:^(NSError *operationError) {
        
        if (!operationError && hasSthChanged) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
        if (completeBlk) completeBlk() ;
    }] ;
}

- (void)uploadAllLocalDataIfNotUploaded {
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"status %ld",(long)status) ;
        
        if (status > AFNetworkReachabilityStatusNotReachable) {
            // upload all local data if not Uploaded
            NSArray *localNotelist = [Note xt_findWhere:@"isSendOnICloud == 0"] ;
            NSArray *localBooklist = [NoteBooks xt_findWhere:@"isSendOnICloud == 0"] ;
            
            NSMutableArray *tmplist = [@[] mutableCopy] ;
            [localNotelist enumerateObjectsUsingBlock:^(Note *note, NSUInteger idx, BOOL * _Nonnull stop) {
                [tmplist addObject:note.record] ;
                note.isSendOnICloud = YES ;
            }] ;
            [localBooklist enumerateObjectsUsingBlock:^(NoteBooks *book, NSUInteger idx, BOOL * _Nonnull stop) {
                [tmplist addObject:book.record] ;
                book.isSendOnICloud = YES ;
            }] ;
            
            if (!tmplist.count) return ;
            
            [[XTCloudHandler sharedInstance] saveList:tmplist deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
                
                if (!error) {
                    [Note xt_updateListByPkid:localNotelist] ;
                    [NoteBooks xt_updateListByPkid:localBooklist] ;
                }
            }] ;
        }
    }] ;
}

#pragma mark - open url
NSString *const kNotificationImportFileIn = @"kNotificationImportFileIn" ;
//导入文件,默认导入到当前的笔记本,如果是最近或者垃圾桶,进入暂存区. 导入之后打开此笔记.
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options {
    if (url != nil && [url isFileURL]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationImportFileIn object:url] ;
    }
    return YES;
}

- (void)setupHudStyle {
    [SVProgressHUD setDefaultStyle:(SVProgressHUDStyleDark)];
}

@end
