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

NS_ASSUME_NONNULL_BEGIN

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

- (NSString *)createUniqueIdentifier ;
- (void)iCloudStatus:(void(^)(bool bOpen))blkICloudOpen ;
- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser ;

    

- (void)fetchWithId:(NSString *)recordID ;

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
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;

- (void)fetchListWithTypeName:(NSString *)typeName
            completionHandler:(void (^)(NSArray<CKRecord *> *results, NSError *error))completionHandler ;



//todo
- (void)insert ;
- (void)insert:(CKRecord *)record ;

- (void)updateWithRecId:(NSString *)recId ;

- (void)deleteWithId:(NSString *)recId ;

/**
 add ref
 
 @param key            refKey
 @param sourceRecordID 主
 @param targetRecordID 从
 */
- (void)setReferenceWithReferenceKey:(NSString *)key
                   andSourceRecordID:(NSString *)sourceRecordID
                   andTargetRecordID:(NSString *)targetRecordID ;

- (void)searchRefWithRefRecId:(CKRecordID *)refrecID ;

- (void)searchReferWithRefID:(CKRecordID *)refrecID
                  sourceType:(NSString *)sourceType ;

@end

NS_ASSUME_NONNULL_END
