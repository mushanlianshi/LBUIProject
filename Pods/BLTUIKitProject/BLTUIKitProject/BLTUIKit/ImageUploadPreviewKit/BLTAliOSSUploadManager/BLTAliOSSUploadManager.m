//
//  BLTAliOssUploadManager.m
//  Baletoo_landlord
//
//  Created by liu bin on 2020/3/25.
//  Copyright © 2020 com.wanjian. All rights reserved.
//

#import "BLTAliOSSUploadManager.h"
//#import <AliyunOSSiOS/AliyunOSSiOS.h>

@interface BLTAliOSSUploadManager ()

//@property (nonatomic, strong) OSSPutObjectRequest *normalUploadRequest;
//
//@property (nonatomic, strong) OSSClient * client;

@property (nonatomic, strong) BLTOSSConfigModel * configModel;

@end

@implementation BLTAliOSSUploadManager

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    static BLTAliOSSUploadManager *instance = nil;
    dispatch_once(&onceToken,^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (void)refreshClientWithConfigModel:(BLTOSSConfigModel *)configModel{
    if (_configModel == configModel) {
        return;
    }
    _configModel = configModel;
//    id<OSSCredentialProvider> credential = [[OSSStsTokenCredentialProvider alloc] initWithAccessKeyId:configModel.AccessKeyId secretKeyId:configModel.AccessKeySecret securityToken:configModel.SecurityToken];
//    if (!_client) {
//        _client = [[OSSClient alloc] initWithEndpoint:configModel.OSS_END_POINT credentialProvider:credential];
//    }else{
//        _client.endpoint = configModel.OSS_END_POINT;
//        _client.credentialProvider = credential;
//    }
    
}

/** 传普通图片的方法 */
- (void)ossUploadImageData:(NSData *)imageData objectKey:(NSString *)objectKey successBlock:(void(^)(NSString *uploadOSSURL))successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [self p_ossUploadData:imageData dataUrl:nil objectKey:objectKey successBlock:successBlock progressBlock:progressBlock failureBlock:failureBlock];
}

/** 传普通图片的方法 */
- (void)ossUploadDataUrl:(NSString *)dataUrl objectKey:(NSString *)objectKey successBlock:(void(^)(NSString *uploadOSSURL))successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock{
    [self p_ossUploadData:nil dataUrl:dataUrl objectKey:objectKey successBlock:successBlock progressBlock:progressBlock failureBlock:failureBlock];
}

- (void)p_ossUploadData:(NSData *)data  dataUrl:(NSString *)dataUrl objectKey:(NSString *)objectKey successBlock:(void(^)(NSString *uploadOSSURL))successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock{
//    if (![objectKey oss_isNotEmpty]) {
//        NSError *error = [NSError errorWithDomain:NSInvalidArgumentException code:0 userInfo:@{NSLocalizedDescriptionKey: @"objectKey should not be nil"}];
//        failureBlock(error);
//        return;
//    }
//
//    if (!data && dataUrl.length == 0) {
//        NSError *error = [NSError errorWithDomain:NSInvalidArgumentException code:0 userInfo:@{NSLocalizedDescriptionKey: @"imageData and url should not be nil"}];
//        failureBlock(error);
//        return;
//    }
//
//    OSSPutObjectRequest *normalUploadRequest = [OSSPutObjectRequest new];
//    normalUploadRequest.bucketName = _configModel.OSS_BUCKET;
//    normalUploadRequest.objectKey = [NSString stringWithFormat:@"%@%@",_configModel.upload_all,objectKey];
//    if (data) {
//        normalUploadRequest.uploadingData = data;
//    }else if (dataUrl.length > 0){
//        NSURL *url = [NSURL fileURLWithPath:dataUrl];
//        normalUploadRequest.uploadingFileURL = url;
//    }
    
//    normalUploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//        float progress = 1.f * totalByteSent / totalBytesExpectedToSend;
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (progressBlock) {
//                progressBlock(progress);
//            }
//        });
//    };
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        OSSTask * task = [self.client putObject:normalUploadRequest];
//        [task continueWithBlock:^id(OSSTask *task) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if (task.error) {
//                    failureBlock(task.error);
//                } else {
//                    NSString *uploadOSSURL = [NSString stringWithFormat:@"http://%@.%@/%@%@",self.configModel.OSS_BUCKET,self.configModel.OSS_END_POINT,self.configModel.upload_all,objectKey];
//                    successBlock(uploadOSSURL);
//                }
//            });
//            return nil;
//        }];
//    });
}

/** 传大文件的方法 */
- (void)ossUploadBigDataURL:(NSURL *)dataURL  objectKey:(NSString *)objectKey successBlock:(dispatch_block_t)successBlock progressBlock:(void (^)(CGFloat progress))progressBlock failureBlock:(void (^)(NSError *error))failureBlock{
    
//    OSSResumableUploadRequest * resumableUpload = [OSSResumableUploadRequest new];
//    resumableUpload.bucketName = self.configModel.OSS_BUCKET;            // 设置bucket名称
//    resumableUpload.objectKey = [NSString stringWithFormat:@"%@%@",_configModel.upload_all,objectKey];       // 设置object key
//    resumableUpload.uploadingFileURL = dataURL;                 // 设置要上传的文件url
//    resumableUpload.contentType = @"application/octet-stream";  // 设置content-type
//    resumableUpload.partSize = 102400;                          // 设置分片大小
//    // 设置上传进度回调
//    resumableUpload.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//        NSLog(@"progress: %lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//    };
//    //
//    OSSTask * resumeTask = [self.client resumableUpload:resumableUpload];
//    [resumeTask waitUntilFinished];          // 阻塞当前线程直到上传任务完成
//    dispatch_async(dispatch_get_main_queue(), ^{
//        if (resumeTask.result) {
//            successBlock();
//        } else {
//            failureBlock(resumeTask.error);
//        }
//    });
}


@end



@implementation BLTOSSConfigModel

+ (instancetype)configModelWithDic:(NSDictionary *)infoDic{
    BLTOSSConfigModel *configModel = [[BLTOSSConfigModel alloc] init];
    configModel.OSS_BUCKET = infoDic[@"OSS_BUCKET"];
    configModel.OSS_END_POINT = infoDic[@"OSS_END_POINT"];
    configModel.AccessKeySecret = infoDic[@"AccessKeySecret"];
    configModel.AccessKeyId = infoDic[@"AccessKeyId"];
    configModel.SecurityToken = infoDic[@"SecurityToken"];
    configModel.upload_all = infoDic[@"upload_all"];
    return configModel;
}

@end
