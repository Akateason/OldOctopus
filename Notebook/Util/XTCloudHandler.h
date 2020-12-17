//
//  XTCloudHandler.h
//  Notebook
//
//  Created by teason23 on 2019/3/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XTlib/XTlib.h>
#import <CloudKit/CloudKit.h>

@interface XTIcloudUser : NSObject <NSCoding>
@property (copy, nonatomic) NSString *userRecordName ;
@property (copy, nonatomic) NSString *name ;
@property (copy, nonatomic) NSString *givenName ;
@property (copy, nonatomic) NSString *familyName ;
+ (NSString *)pathForUserSave ;
+ (instancetype)userInCacheSyncGet ;
+ (BOOL)hasLogin ; // 未登录时, 只能纯本地使用.
+ (NSString *)displayUserName ; // 未登录返回 默认名字.
@end










@interface XTCloudHandler : NSObject
XT_SINGLETON_H(XTCloudHandler)
@property (strong, nonatomic) CKContainer *container ;
@property (strong, nonatomic) CKRecordZoneID *zoneID ;
@property (readwrite, nonatomic) BOOL isSyncingOnICloud ;

- (void)setup:(void(^)(BOOL success))completion ;
- (NSString *)createUniqueIdentifier ;
- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser ;
- (void)alertCallUserToIcloud:(UIViewController *)vc ;

// Sync
- (void)syncOperationEveryRecord:(void (^)(CKRecord *record))recordChangedBlock
                          delete:(void (^)(CKRecordID *recordID, CKRecordType recordType))recordWithIDWasDeletedBlock
                     allComplete:(void (^)(NSError *operationError))fetchRecordZoneChangesCompletionBlock ;


// Fetch list (no use)
- (void)fetchListWithTypeName:(NSString *)typeName
                    predicate:(NSPredicate *)predicate
                         sort:(NSArray<NSSortDescriptor *> *)sortlist
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;
- (void)fetchListWithTypeName:(NSString *)typeName
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;

- (void)fetchWithId:(NSString *)recordID
  completionHandler:(void (^)(CKRecord *record, NSError *error))completionHandler ;


// Insert
- (void)insert:(CKRecord *)record
completionHandler:(void (^)(CKRecord *  record, NSError *  error))completionHandler ;

// Update
- (void)updateWithRecId:(NSString *)recId
              updateDic:(NSDictionary *)dic
      completionHandler:(void (^)(CKRecord *  record, NSError *  error))completionHandler ;

// insert or update list thread safe !!
- (void)saveList:(NSArray<CKRecord *> *)recInsertOrUpdateList
      deleteList:(NSArray<CKRecordID *> *)recDeleteList
        complete:(void(^)(NSArray *savedRecords, NSArray *deletedRecordIDs, NSError *error))modifyRecordsCompletionBlock ;

// Subcript
- (void)saveSubscription ;
- (void)deleteAllSubscriptionCompletion:(void(^)(BOOL success))completion ;

@end


