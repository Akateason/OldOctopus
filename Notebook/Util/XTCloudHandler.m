//
//  XTCloudHandler.m
//  Notebook
//
//  Created by teason23 on 2019/3/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTCloudHandler.h"
#import <CommonCrypto/CommonRandom.h>
#import "GuidingICloud.h"


@implementation XTIcloudUser

+ (NSString *)pathForUserSave {
    return XT_LIBRARY_PATH_TRAIL_(@"iclouduser.arc") ;
}

+ (instancetype)userInCacheSyncGet {
    return [XTArchive unarchiveSomething:[XTIcloudUser pathForUserSave]] ;
}

+ (BOOL)hasLogin {
    return self.userInCacheSyncGet != nil ;
}

+ (void)alertUserToLoginICloud {
    [[XTCloudHandler sharedInstance] alertCallUserToIcloud] ;
}

XT_encodeWithCoderRuntimeCls(XTIcloudUser)
XT_initWithCoderRuntimeCls(XTIcloudUser)

@end








static NSString *const kIdContainer = @"iCloud.container.id.octupus" ;

@interface XTCloudHandler ()
@property (nonatomic) BOOL isSyncingOnICloud ;
@end

@implementation XTCloudHandler
XT_SINGLETON_M(XTCloudHandler)

- (NSString *)createUniqueIdentifier {
    NSDate *now = [NSDate date] ;
    NSString *getString = [now xt_getStr] ;
    getString = XT_STR_FORMAT(@"%@_%lld_",getString, [now xt_getTick]) ;

    int len = 20 ;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity:len];
    for (NSInteger i = 0; i < len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((unsigned int)[letters length])]] ;
    }
    getString = [getString stringByAppendingString:randomString] ;
    return getString ;
}

- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser {
//    blkUser(nil) ;
//    return ;
    
    XTIcloudUser *user = [XTArchive unarchiveSomething:[XTIcloudUser pathForUserSave]] ;
    if (user != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            blkUser(user) ;
        }) ;
        return ;
    }
    @weakify(self)
    [self.container requestApplicationPermission:(CKApplicationPermissionUserDiscoverability) completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
        // 这里要 提醒用户开 icloud drive
        @strongify(self)
        if (error || applicationPermissionStatus == CKApplicationPermissionStatusDenied) {

            [self alertCallUserToIcloud] ;

            dispatch_async(dispatch_get_main_queue(), ^{
                blkUser(nil) ;
            }) ;
            return ;
        }
        
        @weakify(self)
        [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
            @strongify(self)
            if (!recordID) {
                [self alertCallUserToIcloud] ;
                dispatch_async(dispatch_get_main_queue(), ^{
                    blkUser(nil) ;
                }) ;
                return ;
            }
            
            @weakify(self)
            [self.container discoverUserIdentityWithUserRecordID:recordID completionHandler:^(CKUserIdentity * _Nullable userInfo, NSError * _Nullable error) {
                @strongify(self)
                if (error) {
                    [self alertCallUserToIcloud] ;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blkUser(nil) ;
                    }) ;
                    return ;
                }
                
                if (!userInfo && !error) {
                    [self alertCallUserToIcloud] ;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blkUser(nil) ;
                    }) ;
                    // 获取不到用户信息, 但不报错 !
//                    XTIcloudUser *user = [XTIcloudUser new] ;
//                    user.userRecordName = @"userNotLoginedICloud" ;
//                    user.familyName = @"" ;
//                    user.givenName = @"小章鱼用户" ;
//                    user.name = XT_STR_FORMAT(@"%@ %@",user.givenName,user.familyName) ;
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        blkUser(user) ;
//                    }) ;
//
//                    if (user.name.length > 0 && user != nil) {
//                        [XTArchive archiveSomething:user path:[XTIcloudUser pathForUserSave]] ;
//                    }
                    
                    return ;
                }
                
                XTIcloudUser *user = [XTIcloudUser new] ;
                user.userRecordName = userInfo.userRecordID.recordName ;
                user.familyName = userInfo.nameComponents.familyName ;
                user.givenName = userInfo.nameComponents.givenName ;
                user.name = XT_STR_FORMAT(@"%@ %@",user.givenName,user.familyName) ;                
                dispatch_async(dispatch_get_main_queue(), ^{
                    blkUser(user) ;
                }) ;
                
                if (user.name.length > 0 && user != nil) {
                    [XTArchive archiveSomething:user path:[XTIcloudUser pathForUserSave]] ;
                }
                
            }] ;
        }] ;
    }] ;
}

- (void)alertCallUserToIcloud {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        GuidingICloud *guid = [GuidingICloud show] ;
        
    }) ;
}





////////////////////////////////////// CURD events //////////////////////////////////////

- (void)insert:(CKRecord *)record completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    [self saveList:@[record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        completionHandler(savedRecords.firstObject, error) ;
    }] ;
}

- (void)updateWithRecId:(NSString *)recId
              updateDic:(NSDictionary *)dic
      completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    
    [self fetchWithId:recId completionHandler:^(CKRecord * _Nullable record, NSError * _Nullable error) {
        if(!error) {
            for (NSString *key in dic) {
                [record setObject:dic[key] forKey:key] ;
            }
            [self saveList:@[record] deleteList:nil complete:^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
                completionHandler(savedRecords.firstObject, error) ;
            }] ;
        }
        else {
            completionHandler(record, error) ; // query failed
        }
    }] ;
}



- (void)saveList:(NSArray<CKRecord *> *)recInsertOrUpdateList
      deleteList:(NSArray<CKRecordID *> *)recDeleteList
        complete:(void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error))modifyRecordsCompletionBlock {
    self.isSyncingOnICloud = YES ;
    CKModifyRecordsOperation *modifyRecordsOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:recInsertOrUpdateList recordIDsToDelete:recDeleteList];
    modifyRecordsOperation.savePolicy = CKRecordSaveAllKeys;
    NSLog(@"CLOUDKIT Changes Uploading: %lu", (unsigned long)recInsertOrUpdateList.count);
    modifyRecordsOperation.modifyRecordsCompletionBlock = ^(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error) {
        self.isSyncingOnICloud = NO ;
        if (error) NSLog(@"[%@] Error pushing local data: %@", self.class, error);
        modifyRecordsCompletionBlock(savedRecords,deletedRecordIDs,error) ;
    };
    [self.container.privateCloudDatabase addOperation:modifyRecordsOperation] ;
}

- (void)fetchWithId:(NSString *)recordID
  completionHandler:(void (^)(CKRecord * _Nullable record, NSError * _Nullable error))completionHandler {
    
    self.isSyncingOnICloud = YES ;
    CKRecordID *recId = [[CKRecordID alloc] initWithRecordName:recordID zoneID:self.zoneID] ;
    CKFetchRecordsOperation *operate = [[CKFetchRecordsOperation alloc] init] ;
    operate.database = self.container.privateCloudDatabase ;
    operate.recordIDs = @[recId] ;
    [operate setFetchRecordsCompletionBlock:^(NSDictionary<CKRecordID *,CKRecord *> *recordsByRecordID, NSError * operationError) {
        self.isSyncingOnICloud = NO ;
        completionHandler([[recordsByRecordID allValues] firstObject], operationError ) ;
    }] ;
    [self.container.privateCloudDatabase addOperation:operate] ;
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
    
    self.isSyncingOnICloud = YES ;
    
    CKDatabase *database = self.container.privateCloudDatabase ;
    if (!predicate) predicate = [NSPredicate predicateWithValue:YES] ;
    CKQuery *query = [[CKQuery alloc] initWithRecordType:typeName predicate:predicate];
    if (sortlist) query.sortDescriptors = sortlist ;
    
    NSMutableArray *tmplist = [@[] mutableCopy] ;
    CKQueryOperation *operation = [[CKQueryOperation alloc] initWithQuery:query] ;
    operation.zoneID = self.zoneID ;
    operation.database = self.container.privateCloudDatabase ;
    [operation setRecordFetchedBlock:^(CKRecord * _Nonnull record) {
        [tmplist addObject:record] ;
    }] ;
    [operation setQueryCompletionBlock:^(CKQueryCursor * _Nullable cursor, NSError * _Nullable operationError) {
        self.isSyncingOnICloud = NO ;
        completionHandler(tmplist, operationError) ;
    }] ;
    [database addOperation:operation] ;
}

- (void)saveSubscription {
    // Subscript Note
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES] ;
    CKQuerySubscription *subsrp = [[CKQuerySubscription alloc] initWithRecordType:@"Note" predicate:predicate options:CKQuerySubscriptionOptionsFiresOnRecordCreation | CKQuerySubscriptionOptionsFiresOnRecordUpdate | CKQuerySubscriptionOptionsFiresOnRecordDeletion ] ;
    
    CKNotificationInfo *info = [CKNotificationInfo new] ;
    info.shouldBadge = YES ;
    subsrp.notificationInfo = info ;
    [database saveSubscription:subsrp
             completionHandler:^(CKSubscription *subscription, NSError *error) {
                 
             }] ;
    
    // Subscript NoteBook
    subsrp = [[CKQuerySubscription alloc] initWithRecordType:@"NoteBook" predicate:predicate options:CKQuerySubscriptionOptionsFiresOnRecordCreation | CKQuerySubscriptionOptionsFiresOnRecordUpdate | CKQuerySubscriptionOptionsFiresOnRecordDeletion ] ;
    info.shouldBadge = YES ;
    subsrp.notificationInfo = info;
    [database saveSubscription:subsrp
             completionHandler:^(CKSubscription *subscription, NSError *error) {
                 
             }] ;
}

- (void)deleteAllSubscriptionCompletion:(void(^)(BOOL success))completion {
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库
    
    [database fetchAllSubscriptionsWithCompletionHandler:^(NSArray<CKSubscription *> * _Nullable subscriptions, NSError * _Nullable error) {
        NSMutableArray *tmplist = [@[] mutableCopy] ;
        [subscriptions enumerateObjectsUsingBlock:^(CKSubscription * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [tmplist addObject:obj.subscriptionID] ;
        }] ;
    
        
        CKModifySubscriptionsOperation *opt = [[CKModifySubscriptionsOperation alloc] initWithSubscriptionsToSave:nil subscriptionIDsToDelete:tmplist] ;
        [database addOperation:opt] ;
        opt.modifySubscriptionsCompletionBlock = ^(NSArray<CKSubscription *> * _Nullable savedSubscriptions, NSArray<CKSubscriptionID> * _Nullable deletedSubscriptionIDs, NSError * _Nullable operationError) {
            completion(!operationError) ;
        } ;
        
    }] ;
}

static NSString *const kKeyForPreviousServerChangeToken = @"kKeyForPreviousServerChangeToken" ;

- (void)syncOperationEveryRecord:(void (^)(CKRecord *record))recordChangedBlock
                          delete:(void (^)(CKRecordID *recordID, CKRecordType recordType))recordWithIDWasDeletedBlock
                     allComplete:(void (^)(NSError *operationError))fetchRecordZoneChangesCompletionBlock
{
    
    
    CKFetchRecordZoneChangesOperation *operation ;
    CKServerChangeToken *previousToken = [XTArchive unarchiveSomething:XT_DOCUMENTS_PATH_TRAIL_(kKeyForPreviousServerChangeToken)] ;
//    NSLog(@"previousToken : %@",previousToken) ;
    
    if (@available(iOS 12.0, *)) {
        CKFetchRecordZoneChangesConfiguration *config = [[CKFetchRecordZoneChangesConfiguration alloc] init] ;
        if (previousToken != nil) config.previousServerChangeToken = previousToken ;
        
        operation = [[CKFetchRecordZoneChangesOperation alloc] initWithRecordZoneIDs:@[self.zoneID] configurationsByRecordZoneID:@{self.zoneID:config}] ;
    }
    else {
        // Fallback on earlier versions
        CKFetchRecordZoneChangesOptions *config = [[CKFetchRecordZoneChangesOptions alloc] init] ;
        if (previousToken != nil) config.previousServerChangeToken = previousToken ;
        
        operation = [[CKFetchRecordZoneChangesOperation alloc] initWithRecordZoneIDs:@[self.zoneID] optionsByRecordZoneID:@{self.zoneID:config}] ;
    }
    
    operation.database = self.container.privateCloudDatabase ;
    operation.fetchAllChanges = YES ;
    operation.recordChangedBlock = ^(CKRecord * _Nonnull record) {
        if (record) self.isSyncingOnICloud = YES ;
        recordChangedBlock(record) ;
    } ;
    
    operation.recordZoneFetchCompletionBlock = ^(CKRecordZoneID * _Nonnull recordZoneID, CKServerChangeToken * _Nullable serverChangeToken, NSData * _Nullable clientChangeTokenData, BOOL moreComing, NSError * _Nullable recordZoneError) {
        if (!recordZoneError) {
//            NSLog(@"previous : %@",previousToken) ;
//            NSLog(@"change : %@",serverChangeToken) ;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [XTArchive archiveSomething:serverChangeToken path:XT_DOCUMENTS_PATH_TRAIL_(kKeyForPreviousServerChangeToken)] ;
            });
        }
        else {
            if (recordZoneError.code == 21) { // CKErrorChangeTokenExpired
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    [XTFileManager deleteFile:XT_DOCUMENTS_PATH_TRAIL_(kKeyForPreviousServerChangeToken)] ;
                }) ;
            }
        }
    } ;
    
    operation.recordWithIDWasDeletedBlock = recordWithIDWasDeletedBlock ;
    
    operation.fetchRecordZoneChangesCompletionBlock = ^(NSError * _Nullable operationError) {
        self.isSyncingOnICloud = NO ;
        if (operationError) NSLog(@"operationError : %@",operationError) ;
        fetchRecordZoneChangesCompletionBlock(operationError) ;
    } ;
    
    [self.container.privateCloudDatabase addOperation:operation] ;
}

/**
 add ref

 @param key            refKey
 @param sourceRecordID 主
 @param targetRecordID 从
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

- (void)searchRefWithRefRecId:(CKRecordID *)refrecID {
    
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
*/

#pragma mark - prop

- (CKContainer *)container {
    if (!_container) {
        _container = [CKContainer containerWithIdentifier:kIdContainer] ;
    }
    return _container ;
}

- (CKRecordZoneID *)zoneID {
    if (!_zoneID) {
        CKRecordZone *zone = [[CKRecordZone alloc] initWithZoneName:@"OCTOPUS"] ;
        _zoneID = zone.zoneID ;
    }
    return _zoneID ;
}

@end
