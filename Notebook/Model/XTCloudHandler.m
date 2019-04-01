//
//  XTCloudHandler.m
//  Notebook
//
//  Created by teason23 on 2019/3/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTCloudHandler.h"

@implementation XTIcloudUser

+ (NSString *)pathForUserSave {
    return XT_LIBRARY_PATH_TRAIL_(@"iclouduser.arc") ;
}

+ (instancetype)userInCacheSyncGet {
    return [XTArchive unarchiveSomething:[XTIcloudUser pathForUserSave]] ;
}

XT_encodeWithCoderRuntimeCls(XTIcloudUser)
XT_initWithCoderRuntimeCls(XTIcloudUser)

@end






static NSString *const kIdContainer = @"iCloud.container.id.octupus" ;

@implementation XTCloudHandler
XT_SINGLETON_M(XTCloudHandler)

- (NSString *)createUniqueIdentifier {
    NSDate *now = [NSDate date] ;
    NSString *getString = [now xt_getStr] ;
    getString = XT_STR_FORMAT(@"%@_%lld",getString, [now xt_getTick]) ;
    getString = [getString base64EncodedString] ;
    return getString ;
}

- (CKRecordZoneID *)zoneID {
    if (!_zoneID) {
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"OCTOPUS"] ;
        _zoneID = zone.zoneID ;
    }
    return _zoneID ;
}

- (void)iCloudStatus:(void(^)(bool bOpen))blkICloudOpen {
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus accountStatus,NSError *_Nullableerror) {
        if (accountStatus == CKAccountStatusNoAccount) {
            blkICloudOpen(NO) ;
        }
        else {
            blkICloudOpen(YES) ;
        }
    }];
}

- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser {
    XTIcloudUser *user = [XTArchive unarchiveSomething:[XTIcloudUser pathForUserSave]] ;
    if (user != nil) {
        blkUser(user) ;
        return ;
    }
    
    [self.container requestApplicationPermission:(CKApplicationPermissionUserDiscoverability) completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
        //1. 提醒用户开 icloud drive
        
        [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
            if (!recordID) {
                blkUser(nil) ;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showInfoWithStatus:@"请登录您的icloud"] ;
                }) ;
                return ;
            }
            
            [self.container discoverUserIdentityWithUserRecordID:recordID completionHandler:^(CKUserIdentity * _Nullable userInfo, NSError * _Nullable error) {
                
                if (error) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showInfoWithStatus:@"请登录您的icloud"] ;
                    }) ;
                    return ;
                }
                
                XTIcloudUser *user = [XTIcloudUser new] ;
                user.userRecordName = userInfo.userRecordID.recordName ;
                user.familyName = userInfo.nameComponents.familyName ;
                user.givenName = userInfo.nameComponents.givenName ;
                user.name = [user.familyName stringByAppendingString:user.givenName] ;
                blkUser(user) ;
                [XTArchive archiveSomething:user path:[XTIcloudUser pathForUserSave]] ;
            }] ;
        }] ;
    }] ;
}

- (void)insert:(CKRecord *)record completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    [self.container.privateCloudDatabase saveRecord:record completionHandler:completionHandler] ;
}

- (void)fetchWithId:(NSString *)recordID completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:recordID zoneID:self.zoneID] ;
    CKDatabase *database = self.container.privateCloudDatabase ;
    [database fetchRecordWithID:noteId completionHandler:completionHandler];
}

- (void)fetchListWithTypeName:(NSString *)typeName
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler {
    [self fetchListWithTypeName:typeName predicate:nil sort:nil completionHandler:completionHandler] ;
}


/**
 fetch list
 //    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@",@"xiaowang"];
 //    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordTypeName predicate:predicate];
 
 //    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gender" ascending:NO];
 //    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:NO];
 
 //    query.sortDescriptors = @[firstDescriptor,secondDescriptor];
 */
- (void)fetchListWithTypeName:(NSString *)typeName
                    predicate:(NSPredicate *)predicate
                         sort:(NSArray<NSSortDescriptor *> *)sortlist
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler {

    CKDatabase *database = self.container.privateCloudDatabase ;
    
    
    if (!predicate) predicate = [NSPredicate predicateWithValue:YES] ;
    CKQuery *query = [[CKQuery alloc] initWithRecordType:typeName predicate:predicate];
    if (sortlist) query.sortDescriptors = sortlist ;
    
    [database performQuery:query
              inZoneWithID:self.zoneID
         completionHandler:completionHandler] ;
}



- (void)updateWithRecId:(NSString *)recId
              updateDic:(NSDictionary *)dic
      completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    
    [self fetchWithId:recId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if(!error) {
            for (NSString *key in dic) {
                [record setObject:dic[key] forKey:key] ;
            }
            [self.container.privateCloudDatabase saveRecord:record completionHandler:completionHandler];
        }
        else {
            completionHandler(record, error) ; // query failed
        }
    }] ;
}

- (void)deleteWithId:(NSString *)recId {
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:recId];
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库

    [database deleteRecordWithID:noteId completionHandler:^(CKRecordID *_Nullable recordID,NSError *_Nullable error) {
        
        if(!error) {
            NSLog(@"删除成功");
        }
        else {
            NSLog(@"删除失败: %@",error);
        }
    }];
}

- (void)saveSubscription {
    // Subscript Note
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES] ;
    CKSubscription *subscription = [[CKSubscription alloc] initWithRecordType:@"Note" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate] ;
    
    CKNotificationInfo *info = [CKNotificationInfo new] ;
    info.alertLocalizationKey = @"Note_Changed" ;
    info.shouldBadge = YES ;
    subscription.notificationInfo = info;
    
    [database saveSubscription:subscription
             completionHandler:^(CKSubscription *subscription, NSError *error) {
             }] ;
    
    // Subscript NoteBook
    subscription = [[CKSubscription alloc] initWithRecordType:@"NoteBook" predicate:predicate options:CKSubscriptionOptionsFiresOnRecordCreation | CKSubscriptionOptionsFiresOnRecordUpdate] ;
    info.alertLocalizationKey = @"NoteBook_Changed" ;
    subscription.notificationInfo = info;
    [database saveSubscription:subscription
             completionHandler:^(CKSubscription *subscription, NSError *error) {
             }] ;
}



/**
 add ref

 @param key            refKey
 @param sourceRecordID 主
 @param targetRecordID 从
 */
- (void)setReferenceWithReferenceKey:(NSString *)key
                   andSourceRecordID:(NSString *)sourceRecordID
                   andTargetRecordID:(NSString *)targetRecordID
{
    CKRecordID *noteID = [[CKRecordID alloc] initWithRecordName:targetRecordID];
    CKReference *ref = [[CKReference alloc] initWithRecordID:noteID action:CKReferenceActionDeleteSelf];
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库
    
    CKRecordID *sourceRecordId = [[CKRecordID alloc] initWithRecordName:sourceRecordID];
    
    [database fetchRecordWithID:sourceRecordId completionHandler:^(CKRecord *_Nullable record,NSError *_Nullable error) {
        
        if (!error) {
            [record setObject:ref forKey:key];
            
            [database saveRecord:record completionHandler:^(CKRecord *_Nullable record,NSError *_Nullable error) {
                
                if (!error) {
                    NSLog(@"保存ref成功");
                }
                else {
                    NSLog(@"保存ref失败: %@",error);
                }
            }];
        }
    }];
}

- (void)searchRefWithRefRecId:(CKRecordID *)refrecID
{
    [self.container.privateCloudDatabase fetchRecordWithID:refrecID completionHandler:^(CKRecord *rec, NSError *error) {
        if (!error) {
            NSLog(@"成功 %@", rec);

        }
        else {
            NSLog(@"搜索ref失败");
        }
    }];
}


- (void)searchReferWithRefID:(CKRecordID *)refrecID
                  sourceType:(NSString *)sourceType {
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"book = %@", refrecID];
    CKQuery *query = [[CKQuery alloc] initWithRecordType:sourceType predicate:predicate] ; // "Test"
    
    CKDatabase *db = self.container.privateCloudDatabase ;
    [db performQuery:query inZoneWithID:nil completionHandler:^(NSArray *results, NSError *error) {
        if (!error) {
            NSLog(@"搜索ref下的list成功 %@", results);
        }
        else {
            NSLog(@"搜索ref失败");
        }
    }];
}


#pragma mark - prop

- (CKContainer *)container {
    if (!_container) {
        _container = [CKContainer containerWithIdentifier:kIdContainer] ;
    }
    return _container ;
}

@end
