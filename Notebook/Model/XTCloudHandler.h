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
@end







@interface XTCloudHandler : NSObject
XT_SINGLETON_H(XTCloudHandler)
@property (strong, nonatomic) CKContainer *container ;
@property (strong, nonatomic) CKRecordZoneID *zoneID ;
@property (readonly, nonatomic) BOOL isSyncingOnICloud ;

- (NSString *)createUniqueIdentifier ;
- (void)iCloudStatus:(void(^)(bool bOpen))blkICloudOpen ;
- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser ;

// sync
- (void)syncOperationEveryRecord:(void (^)(CKRecord *record))recordChangedBlock
                          delete:(void (^)(CKRecordID *recordID, CKRecordType recordType))recordWithIDWasDeletedBlock
                     allComplete:(void (^)(NSError *operationError))fetchRecordZoneChangesCompletionBlock ;

// Fetch (no use)
- (void)fetchWithId:(NSString *)recordID completionHandler:(void (^)(CKRecord *  record, NSError *  error))completionHandler ;

// Fetch list (no use)
- (void)fetchListWithTypeName:(NSString *)typeName
                    predicate:(NSPredicate *)predicate
                         sort:(NSArray<NSSortDescriptor *> *)sortlist
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;
- (void)fetchListWithTypeName:(NSString *)typeName
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;


// Insert
- (void)insert:(CKRecord *)record completionHandler:(void (^)(CKRecord *  record, NSError *  error))completionHandler ;
// Update
- (void)updateWithRecId:(NSString *)recId
              updateDic:(NSDictionary *)dic
      completionHandler:(void (^)(CKRecord *  record, NSError *  error))completionHandler ;

// Delete From server
- (void)deleteWithId:(NSString *)recId ;

// Subcript
- (void)saveSubscription ;

// Ref
- (void)setReferenceWithReferenceKey:(NSString *)key
                   andSourceRecordID:(NSString *)sourceRecordID
                   andTargetRecordID:(NSString *)targetRecordID ;

- (void)searchRefWithRefRecId:(CKRecordID *)refrecID ;

- (void)searchReferWithRefID:(CKRecordID *)refrecID
                  sourceType:(NSString *)sourceType ;

@end


