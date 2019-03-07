//
//  XTCloudHandler.m
//  Notebook
//
//  Created by teason23 on 2019/3/6.
//  Copyright © 2019 teason23. All rights reserved.
//

#import "XTCloudHandler.h"

static NSString *const kIdContainer = @"iCloud.container.id.octupus" ;


@implementation XTCloudHandler
XT_SINGLETON_M(XTCloudHandler)

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

- (void)fetchUser {
    [self.container requestApplicationPermission:(CKApplicationPermissionUserDiscoverability) completionHandler:^(CKApplicationPermissionStatus applicationPermissionStatus, NSError * _Nullable error) {
        
        [self.container fetchUserRecordIDWithCompletionHandler:^(CKRecordID * _Nullable recordID, NSError * _Nullable error) {
    
    
            [self.container discoverUserIdentityWithUserRecordID:recordID completionHandler:^(CKUserIdentity * _Nullable userInfo, NSError * _Nullable error) {
    
                NSLog(@"user : %@", [userInfo yy_modelToJSONString]) ;
            }] ;
        }] ;
    }] ;
}


- (void)insert {
    //创建主键ID  这个ID到时查找有用到
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:@"abcxtc"];
    
    //创建CKRecord 保存数据
    CKRecord *noteRecord = [[CKRecord alloc] initWithRecordType:@"Test" recordID:noteId];
    //设置数据
    [noteRecord setObject:@"123" forKey:@"c1"];
    [noteRecord setObject:@"234" forKey:@"c2"];
    
    //保存操作
    [self.container.privateCloudDatabase saveRecord:noteRecord completionHandler:^(CKRecord *_Nullablerecord,NSError *_Nullable error) {
        if(!error) {
            NSLog(@"保存成功");
        }
        else {
            NSLog(@"保存失败: %@",error);
        }
    }];
}

- (void)insert:(CKRecord *)record {
    [self.container.privateCloudDatabase saveRecord:record completionHandler:^(CKRecord *_Nullablerecord,NSError *_Nullable error) {
        if(!error) {
            NSLog(@"保存成功");
        }
        else {
            NSLog(@"保存失败: %@",error);
        }
    }];
}

- (void)fetchWithId:(NSString *)recordID {
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:recordID]; // recordID
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库
    
    //通过主键ID查找记录
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord *_Nullable record,NSError *_Nullable error) {
        if(!error) {
            NSLog(@"查询成功: %@",record);
        }
        else {
            NSLog(@"查询失败: %@",error);
        }
    }];
}

- (void)fetchListWithTypeName:(NSString *)typeName {
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库

//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name != %@",@"xiaowang"];
//    CKQuery *query = [[CKQuery alloc] initWithRecordType:recordTypeName predicate:predicate];
    
//    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"gender" ascending:NO];
//    NSSortDescriptor *secondDescriptor = [[NSSortDescriptor alloc] initWithKey:@"age" ascending:NO];
    
//    query.sortDescriptors = @[firstDescriptor,secondDescriptor];
    

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES] ;
    CKQuery *query = [[CKQuery alloc] initWithRecordType:typeName predicate:predicate];

    //通过谓词查找记录
    [database performQuery:query //query
              inZoneWithID:nil
         completionHandler:^(NSArray<CKRecord*>  *_Nullable results,NSError *_Nullable error) {
        if(!error) {
            NSLog(@"results 查询成功 : %@",results);
        }
        else {
            NSLog(@"查询失败: %@",error);
        }
    }] ;
}

- (void)updateWithRecId:(NSString *)recId {
    CKRecordID *noteId = [[CKRecordID alloc] initWithRecordName:recId];
    CKDatabase *database = self.container.privateCloudDatabase ; //私有数据库

    //先找到记录，再修改记录
    [database fetchRecordWithID:noteId completionHandler:^(CKRecord *_Nullable record,NSError *_Nullable error) {
        if(!error) {
            [record setObject:@"改了 1" forKey:@"c1"];
            [record setObject:@"改了 2" forKey:@"c2"];
            
            //修改后保存记录
            [database saveRecord:record completionHandler:^(CKRecord *_Nullable  record,NSError *_Nullable error) {
                if(!error) {
                    NSLog(@"修改成功 %@",record);
                }
                else {
                    NSLog(@"修改失败: %@",error);
                }
            }];
        }
        else {
            NSLog(@"找不到该记录，查询失败: %@",error);
        }
    }];
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
