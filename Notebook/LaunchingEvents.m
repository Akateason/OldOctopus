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
#import "XTMarkdownParser+ImageUtil.h"
#import "Note.h"
#import "NoteBooks.h"
#import <UserNotifications/UserNotifications.h>
#import <XTReq/XTReq.h>
#import "MDThemeConfiguration.h"
#import "AppDelegate.h"
#import "MDNavVC.h"




@implementation LaunchingEvents

- (void)setup:(UIApplication *)application appdelegate:(AppDelegate *)appDelegate {

    self.appDelegate = appDelegate ;
    [[MDThemeConfiguration sharedInstance] setup] ;
    
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    [self setupLoadingHomePage] ;
}







- (void)setupDB {
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
}

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable             = YES ; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO ;  // 控制是否显示键盘上的工具条
}

NSString *const kFirstTimeLaunch = @"kFirstTimeLaunch" ;

- (void)setupLoadingHomePage {
//    NSString *currentVersion = [CommonFunc getVersionStrOfMyAPP] ;
//    NSString *versionCached = XT_USERDEFAULT_GET_VAL(kKey_markForGuidingDisplay) ;
//    if ([currentVersion compare:versionCached options:NSNumericSearch] != NSOrderedDescending) return ;
    
//    [self createDefaultBookAndNotes] ;
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
//    [[XTCloudHandler sharedInstance] saveList:@[book.record,noteICloud.record,note.record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
//
//        if (!error) {
//            book.isSendOnICloud = YES ;
//            [book xt_update] ;
//            note.isSendOnICloud = YES ;
//            [note xt_update] ;
//            noteICloud.isSendOnICloud = YES ;
//            [noteICloud xt_update] ;
//        }
//    }] ;
    
    XT_USERDEFAULT_SET_VAL(@1, kFirstTimeLaunch) ;
}

@end
