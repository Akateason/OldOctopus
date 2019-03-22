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



@interface AppDelegate ()

@end


@implementation AppDelegate


- (void)test {
    XTCloudHandler *handle = [[XTCloudHandler alloc] init];
//        [handle iCloudStatus] ;

    [handle fetchUser:^(XTIcloudUser * _Nonnull user) {
        NSLog(@"user : %@", [user yy_modelToJSONString]) ;
        
    }] ;
    
    [[MDImageManager sharedInstance] uploadImage:[UIImage imageNamed:@"test"] progress:^(float flt) {
        
    } success:^(NSURLResponse * _Nonnull response, id  _Nonnull responseObject) {
        
    } failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
        
    }] ;

    //    [handle insert] ;

    //    CKRecordID *recId = [[CKRecordID alloc] initWithRecordName:@"11111"];
    //    CKRecord *rec = [[CKRecord alloc] initWithRecordType:@"TestTargetRefObj" recordID:recId];
    //    [rec setObject:@"嘻嘻" forKey:@"name"];
    //    [handle insert:rec] ;
    //
    //    recId = [[CKRecordID alloc] initWithRecordName:@"11112"];
    //    rec = [[CKRecord alloc] initWithRecordType:@"TestTargetRefObj" recordID:recId];
    //    [rec setObject:@"哈哈" forKey:@"name"];
    //    [handle insert:rec] ;

    //    [handle setReferenceWithReferenceKey:@"book" andSourceRecordID:@"abcxtc" andTargetRecordID:@"11111"] ;

    //    [handle searchReferWithRefID:rec.recordID sourceType:@"Test"] ;


    //    [handle fetchWithId:@"abcxtc"] ;

    //    [handle fetchListWithTypeName:@"Test"] ;

    //    [handle updateWithRecId:@"abcxtc"] ;

    //    [handle deleteWithId:@"abcxtc"] ;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self setupDB] ;
    [self setupNaviStyle] ;
    [self setupIqKeyboard] ;
    
    [self test] ;

    return YES;
}

- (void)setupDB {
    [XTlibConfig sharedInstance].isDebug    = YES;
    [XTFMDBBase sharedInstance].isDebugMode = YES;
    [[XTFMDBBase sharedInstance] configureDBWithPath:XT_DOCUMENTS_PATH_TRAIL_(@"noteDB")];

}

- (void)setupNaviStyle {
    [[UIApplication sharedApplication] keyWindow].tintColor = [UIColor whiteColor] ;

    
}

- (void)setupIqKeyboard {
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable             = YES; // 控制整个功能是否启用。
    manager.enableAutoToolbar  = NO;  // 控制是否显示键盘上的工具条
}


@end
