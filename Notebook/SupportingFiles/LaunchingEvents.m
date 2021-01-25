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
#import "AppDelegate.h"
#import "OctGuidingVC.h"
#import "MDNavVC.h"
#import "WebPhotoHandler.h"
#import "HomePadVC.h"
#import "OctWebEditor.h"
#import <SSZipArchive/SSZipArchive.h>
#import <Photos/Photos.h>
#import "AppstoreCommentUtil.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import <UMCommon/UMCommon.h>


#ifdef ISIOS
#import <Bugly/Bugly.h>
#import <AipOcrSdk/AipOcrSdk.h>
#endif



NSString *const kNotificationSyncCompleteAllPageRefresh = @"kNotificationSyncCompleteAllPageRefresh" ;

@implementation LaunchingEvents

#pragma mark - did finish launching

- (void)setup:(UIApplication *)application appdelegate:(AppDelegate *)appDelegate {
    
#ifdef ISIOS
    [Bugly startWithAppId:@"8abe605307"] ;
#endif
    [self configUmeng];
    
    self.appDelegate = appDelegate ;
    [self setupCocoaLumberjack] ;
    [[MDThemeConfiguration sharedInstance] setup] ;
    [self setupWebZipPackageAndSetupWebView] ;
    [self setupRemoteNotification:application] ;
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupLoadingHomePage] ;
    [self setupIcloudLoginAndDoEvent] ; // get User. Then Pull or Sync .
    [self uploadAllLocalDataIfNotUploaded] ;
    [self setupHudStyle] ;
    [self setupNotePreviewPicture] ;
    [self setupOCR] ;
}

- (void)configUmeng {
#ifndef DEBUG
    [UMConfigure initWithAppkey:@"5e93d5dddbc2ec07e86bc025" channel:@"App Store"];
#endif
}

- (void)setupOCR {
#ifdef ISIOS
    [[AipOcrService shardService] authWithAK:@"E2YNlPToQx7Am0hv25kdbgwr" andSK:@"V5XGN3R01D1miu7Wb6YN9GxAUzrxqWnG"];
#endif
}

- (void)setupNotePreviewPicture {
    [Note addPreviewPictureInLaunchingTime] ;
}

- (void)setupCocoaLumberjack {
    [DDLog addLogger:[DDOSLogger sharedInstance]] ;
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init] ;
    fileLogger.rollingFrequency = 60 * 60 * 24 ; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7 ;
    [DDLog addLogger:fileLogger] ;
}

#pragma mark --

/**
 1. setupWebZipPackage
 2. setupWebView
 */
static NSString *const kMark_UNZip_Operation = @"kMark_UNZip_Operation_new" ; // +++
- (void)setupWebZipPackageAndSetupWebView {
    // 图片缓存目录
    NSString *picPath = XT_LIBRARY_PATH_TRAIL_(@"pic") ;
    [XTFileManager createFolder:picPath] ;
    
    // zip包解压目录
    NSString *pathIndex = XT_LIBRARY_PATH_TRAIL_(@"web/index.html") ;
    
    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *currentBuildNum = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] ;
    NSString *combineVersion = XT_STR_FORMAT(@"%@.%@",currentVersion,currentBuildNum) ;
    // 版本号.build号拼接后比对, 判断是否需要解压, 1.0.0.1
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kMark_UNZip_Operation) ;
    BOOL isNotNewVersion = [combineVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending ;
    
    if (![XTFileManager isFileExist:pathIndex] || !isNotNewVersion) {
        NSString *lastFolderPath = XT_LIBRARY_PATH_TRAIL_(@"web") ;
        [XTFileManager deleteFile:lastFolderPath] ;
        
        NSString *zipPath = [[NSBundle mainBundle] pathForResource:@"web" ofType:@"zip"] ;
        NSString *unzipPath = [XTArchive getLibraryPath] ; // unzip
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

- (void)setupRemoteNotification:(UIApplication *)application {
    // 官方文档一致(无视这条警告)
    //    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
    UIUserNotificationSettings *notificationSettings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeNone | UIUserNotificationTypeSound categories:nil];
    [application registerUserNotificationSettings:notificationSettings];
    [application registerForRemoteNotifications] ;
}

#pragma mark --

- (void)setupDB {
#ifdef DEBUG
//    [XTlibConfig sharedInstance].isShowControllerLifeCycle = NO;
//    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:OCTUPUS_DB_Location_Dev];
    NSLog(@"db path : %@",OCTUPUS_DB_Location_Dev) ;
//    [XTRequest shareInstance].isDebug = NO;
    
#else
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
    [[XTFMDBBase sharedInstance] dbUpgradeTable:Note.class paramsAdd:@[@"previewPicture"] version:9] ;
}

#pragma mark --

- (void)setupNaviStyle {
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor] ;
}

#pragma mark --

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager] ;
    manager.enable             = YES ; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO ;  // 控制是否显示键盘上的工具条
}

#pragma mark --

NSString *const kFirstTimeLaunch = @"kFirstTimeLaunch" ;

- (void)setupLoadingHomePage {
    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return ;
    
    [self createDefaultBookAndNotes];
}

#pragma mark --

- (void)setupIcloudLoginAndDoEvent {
    [[XTCloudHandler sharedInstance] setup:^(BOOL success) {
        
        if (success) {
            [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser * _Nonnull user) {
                NSLog(@"!!! Icloud User Logined : %@", [user yy_modelToJSONString]) ;
                if (user.userRecordName) {
                    [[XTCloudHandler sharedInstance] saveSubscription] ;
                    [self pullOrSync] ;
                }
                else {
                    
                }
            }] ;
        } else {
            NSLog(@"login failed");
        }
        
    }] ;
    
    // 处理偶现登录失败
    NSNumber *num = XT_USERDEFAULT_GET_VAL(kUD_OCT_PullAll_Done) ;
    if ([num intValue] != 1) {
        @weakify(self)
        [[[[RACSignal interval:8 onScheduler:[RACScheduler mainThreadScheduler]]
           skip:1]
          take:10]
         subscribeNext:^(NSDate * _Nullable x) {
            @strongify(self)
            NSNumber *num1 = XT_USERDEFAULT_GET_VAL(kUD_OCT_PullAll_Done) ;
            if ([num1 intValue] == 1) return ;
            
            @weakify(self)
            [[XTCloudHandler sharedInstance] fetchUser:^(XTIcloudUser *user) {
                @strongify(self)
                // [[XTCloudHandler sharedInstance] saveSubscription] ;
                [self pullOrSync] ;
            }] ;
        }] ;
    }
}

#pragma mark --
#pragma mark - pull and sync

- (void)pullOrSync {
    BOOL fstTimeLaunch = [XT_USERDEFAULT_GET_VAL(kFirstTimeLaunch) intValue] ;
    WEAK_SELF
    [self pullAllComplete:^{
        if (!fstTimeLaunch) {
            [weakSelf createDefaultBookAndNotes] ;
        }
    }] ;
}

- (void)pullAllComplete:(void(^)(void))completion {
    NSLog(@"pullall start") ;
    [XTCloudHandler sharedInstance].isSyncingOnICloud = YES;
    
    [NoteBooks getFromServerComplete:^(bool hasData) {
        
        [Note getFromServerComplete:^(bool isPullAll){
                        
            [XTCloudHandler sharedInstance].isSyncingOnICloud = NO;
            
            if (isPullAll) { // pull all done.
                if ([Note xt_count]) {
                    XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
                    XT_USERDEFAULT_SET_VAL(@1, kUD_OCT_PullAll_Done) ;
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ; // pull all in first time
                                        
                NSLog(@"pullall complete") ;
                if (completion) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        completion() ;
                    }) ;
                }
            } else { // sync
                [self icloudSync:^{
                    if (completion) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            completion() ;
                        }) ;
                    }
                }] ;
            }
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
//    introPro
    path = [[NSBundle bundleForClass:self.class] pathForResource:@"introUsePro" ofType:@"md"] ;
    data = [[NSData alloc] initWithContentsOfFile:path];
    str = [[NSString alloc] initWithData:data encoding:(NSUTF8StringEncoding)] ;
    Note *notePro = [[Note alloc] initWithBookID:book.icRecordName content:str title:@"小章鱼更多功能"] ;
    notePro.isSendOnICloud = NO ;
    notePro.icRecordName = @"iOS-note-pro-intro" ; // 默认文章介绍 id
    [notePro xt_insert] ;


//  Upload default items .
    [[XTCloudHandler sharedInstance] saveList:@[book.record,noteICloud.record,note.record,notePro.record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        
        if (!error) {
            book.isSendOnICloud = YES ;
            [book xt_update] ;
            note.isSendOnICloud = YES ;
            [note xt_update] ;
            noteICloud.isSendOnICloud = YES ;
            [noteICloud xt_update] ;
            notePro.isSendOnICloud = YES ;
            [notePro xt_update] ;
        }
    }] ;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNote_Default_Note_And_Book_Updated object:nil] ;
}

- (void)icloudSync:(void(^)(void))completeBlk {
    [XTCloudHandler sharedInstance].isSyncingOnICloud = YES;
    
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
        [XTCloudHandler sharedInstance].isSyncingOnICloud = NO;
        
        if (!operationError && hasSthChanged) [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationSyncCompleteAllPageRefresh object:nil] ;
        if (completeBlk) completeBlk() ;
    }] ;
}

#pragma mark --

- (void)uploadAllLocalDataIfNotUploaded {
    if (![XTIcloudUser hasLogin]) {        
        return ;
    }
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring] ;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        NSLog(@"status %ld",(long)status) ;
        
        if (status > AFNetworkReachabilityStatusNotReachable) {
            // upload all local data if not Uploaded
            
            NSArray *localNotelist = [Note      xt_findWhere:@"isSendOnICloud == 0"] ;
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
                
                if (!error && savedRecords.count > 0 && savedRecords != nil) {
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
    [SVProgressHUD setDefaultStyle:(SVProgressHUDStyleDark)] ;
    [SVProgressHUD setMinimumDismissTimeInterval:1.4] ;
}

@end
