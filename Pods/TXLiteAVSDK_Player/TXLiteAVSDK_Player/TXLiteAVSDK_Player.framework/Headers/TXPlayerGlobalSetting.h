//  Copyright © 2022 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import "TXLiteAVSymbolExport.h"

NS_ASSUME_NONNULL_BEGIN

LITEAV_EXPORT @interface TXPlayerGlobalSetting : NSObject

/**
 * 设置播放引擎的cache目录。设置后，预下载，播放器等会优先从此目录读取和存储。
 *
 * @discussion 设置播放器Cache缓存目录路径
 * @param  cacheFolder  缓存目录路径，nil 表示不开启缓存
 */
+ (void)setCacheFolderPath:(NSString *)cacheFolder;

/**
 * 获取设置的播放引擎的cache目录
 *
 * @discussion 返回播放器Cache缓存目录的Path
 * @return  返回 Cache缓存目录的Path
 */
+ (NSString *)cacheFolderPath;

/**
 * 设置播放引擎的最大缓存大小。设置后会根据设定值自动清理Cache目录的文件
 *
 * @discussion 设置播放器最大缓存的Cache Size大小（单位MB）
 * @param maxCacheSizeMB 最大缓存大小（单位：MB）
 */
+ (void)setMaxCacheSize:(NSInteger)maxCacheSizeMB;

/**
 * 获取设置的播放引擎的最大缓存大小
 *
 * @discussion 返回播放器最大缓存的Cache Size大小（单位M）
 * @return  返回 Cache Size的大小
 */
+ (NSInteger)maxCacheSize;

+ (id)getOptions:(NSNumber *)featureId;

@end

NS_ASSUME_NONNULL_END
