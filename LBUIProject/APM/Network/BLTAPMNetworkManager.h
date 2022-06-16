//
//  BLTAPMNetworkManager.h
//  chugefang
//
//  Created by liu bin on 2021/3/25.
//  Copyright © 2021 baletu123. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BLTAPMObserverHeader.h"


@interface BLTAPMNetworkManager : NSObject

//接口慢的上线
@property (nonatomic, assign) NSTimeInterval limitInterval;

//callback里的字典可以直接上传给神策  如果需要修改键值   自己转换
- (void)startNetworkWithOptions:(BLTAPMNetworkOptions)options callback:(void(^)(NSDictionary *dic))callback;

@end


