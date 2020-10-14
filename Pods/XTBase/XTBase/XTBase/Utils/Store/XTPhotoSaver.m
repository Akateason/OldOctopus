//
//  XTPhotoSaver.m
//  XTBase
//
//  Created by teason23 on 2020/4/10.
//  Copyright © 2020 teason23. All rights reserved.
//

#import "XTPhotoSaver.h"
#import <Photos/Photos.h>
#import "XTlibConst.h"

@implementation XTPhotoSaver

/**
 *  先获得之前创建过的相册
 */
+ (PHAssetCollection *)getCollectionNamed:(NSString *)albumName {
    PHFetchResult<PHAssetCollection *> *collectionResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collectionResult) {
        if ([collection.localizedTitle isEqualToString:albumName]) {
            return collection;
        }
    }
    // 如果相册不存在,就创建新的相册(文件夹)
    __block NSString *collectionId = nil; // __block修改block外部的变量的值
    // 这个方法会在相册创建完毕后才会返回
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        // 新建一个PHAssertCollectionChangeRequest对象, 用来创建一个新的相册
        collectionId = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:albumName].placeholderForCreatedAssetCollection.localIdentifier;
    } error:nil];
    
    return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionId] options:nil].firstObject;
}



+ (void)saveImage:(UIImage *)image
          inAlbum:(NSString *)albumName
         complete:(void(^)(BOOL bSave))completion
{
    __block NSString *assetId = nil;
    // 1. 存储图片到"相机胶卷"
    // 这个block里保存一些"修改"性质的代码
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 新建一个PHAssetCreationRequest对象, 保存图片到"相机胶卷"
        // 返回PHAsset(图片)的字符串标识
      assetId = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
                    
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (error) {
            xt_LOG_DEBUG(@"保存图片到相机胶卷中失败");
            return;
        }
        xt_LOG_DEBUG(@"成功保存图片到相机胶卷中");
        
        // 2. 获得相册对象
        PHAssetCollection *collection = [self getCollectionNamed:albumName];
        
        // 3. 添加到指定相册
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection];
            // 根据唯一标示获得相片对象
            PHAsset *asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[assetId] options:nil].firstObject;
            // 添加图片到相册中
            [request addAssets:@[asset]];
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            if (error) {
                xt_LOG_DEBUG(@"添加图片到相册中失败");
                return;
            }
            xt_LOG_DEBUG(@"添加图片到相册中成功");
            
            if (completion) completion(success);
        }];
    }];
}

@end
