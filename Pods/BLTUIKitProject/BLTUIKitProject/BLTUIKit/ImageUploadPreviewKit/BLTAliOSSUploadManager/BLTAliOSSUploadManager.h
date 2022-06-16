//
//  BLTAliOssUploadManager.h
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import <Foundation/Foundation.h>



@class BLTOSSConfigModel;
@interface BLTAliOSSUploadManager : NSObject

+ (instancetype)sharedInstance;

- (void)refreshClientWithConfigModel:(BLTOSSConfigModel *)configModel;
/**  传普通图片的方法 在这之前先调refresh方法  先调试 后面修改 */

/// 上传data类型的文件
/// @param imageData data文件
/// @param objectKey 上传到OSS文件名
/// @param successBlock 成功的回调
/// @param progressBlock 进度回调
/// @param failureBlock 失败的回调
- (void)ossUploadImageData:(NSData *)imageData objectKey:(NSString *)objectKey successBlock:(void(^)(NSString *uploadOSSURL))successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock;

- (void)ossUploadDataUrl:(NSString *)dataUrl objectKey:(NSString *)objectKey successBlock:(void(^)(NSString *uploadOSSURL))successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock;

/// 上传文件URL的方法
/// @param dataURL 文件的路径
/// @param objectKey 上传到OSS文件名
/// @param successBlock 成功的回调
/// @param progressBlock 进度回调
/// @param failureBlock 失败的回调
- (void)ossUploadBigDataURL:(NSURL *)dataURL  objectKey:(NSString *)objectKey  successBlock:(dispatch_block_t)successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock;

@end



@interface BLTOSSConfigModel : NSObject

+ (instancetype)configModelWithDic:(NSDictionary *)infoDic;

@property (nonatomic, copy) NSString *AccessKeySecret;

@property (nonatomic, copy) NSString *AccessKeyId;

@property (nonatomic, copy) NSString *SecurityToken;

@property (nonatomic, copy) NSString *upload_all;

@property (nonatomic, copy) NSString *OSS_END_POINT;

@property (nonatomic, copy) NSString *OSS_BUCKET;

@end
