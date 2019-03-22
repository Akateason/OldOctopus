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


- (void)iCloudStatus:(void(^)(bool bOpen))blkICloudOpen ;
- (void)fetchUser:(void(^)(XTIcloudUser *user))blkUser ;

    
    
    
//todo
- (void)insert ;
- (void)insert:(CKRecord *)record ;

- (void)fetchWithId:(NSString *)recordID ;
- (void)fetchListWithTypeName:(NSString *)typeName ;
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
