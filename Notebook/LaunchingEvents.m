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


NSString *const kNotificationSyncCompleteAllPageRefresh = @"kNotificationSyncCompleteAllPageRefresh" ;

@implementation LaunchingEvents

- (void)setup:(UIApplication *)application appdelegate:(AppDelegate *)appDelegate {
    //    if (!DEBUG)
//        [Bugly startWithAppId:@"8abe605307"] ;

    self.appDelegate = appDelegate ;
    [[MDThemeConfiguration sharedInstance] setup] ;
    [self setupRemoteNotification:application] ;
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupLoadingHomePage] ;
    [self setupIcloudEvent] ;
    [self uploadAllLocalDataIfNotUploaded] ;
}



- (void)setupRemoteNotification:(UIApplication *)application {
    // 官方文档(无视警告)
    //    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications] ;
}




- (void)setupDB {
//    [XTlibConfig sharedInstance].isDebug    = YES;
//    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:OCTUPUS_DB_Location];
    
    [Note       xt_createTable] ;
    [NoteBooks  xt_createTable] ;
    
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
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
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
            HomeVC *homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
            MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:homeVC] ;
            self.appDelegate.window.rootViewController = navVC;
            [self.appDelegate.window makeKeyAndVisible];
        }
    }] ;
}

- (void)pullOrSync {
    BOOL fstTimeLaunch = [XT_USERDEFAULT_GET_VAL(kFirstTimeLaunch) intValue] ;
    
    GuidingVC *guidVC = [GuidingVC show] ;
    if (!fstTimeLaunch || guidVC != nil) {
        
        if (IS_IPAD) {
            HomeVC *homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
            MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:homeVC] ;
            self.appDelegate.window.rootViewController = navVC;
            [self.appDelegate.window makeKeyAndVisible];
        }
        else {
            MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:guidVC] ;
            self.appDelegate.window.rootViewController = navVC;
            [self.appDelegate.window makeKeyAndVisible];
        }
        
        [self pullAll] ;
    }
    else {
        HomeVC *homeVC = [HomeVC getCtrllerFromStory:@"Main" bundle:[NSBundle bundleForClass:self.class] controllerIdentifier:@"HomeVC"] ;
        MDNavVC *navVC = [[MDNavVC alloc] initWithRootViewController:homeVC] ;
        self.appDelegate.window.rootViewController = navVC;
        [self.appDelegate.window makeKeyAndVisible];
        
        [self icloudSync:nil] ;
    }
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

@end
