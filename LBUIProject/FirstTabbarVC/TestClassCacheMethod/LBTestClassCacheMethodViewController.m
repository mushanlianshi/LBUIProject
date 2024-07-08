//
//  LBTestClassCacheMethodViewController.m
//  LBUIProject
//
//  Created by liu bin on 2021/7/7.
//

#import "LBTestClassCacheMethodViewController.h"

@interface _LBTestCacheObject : NSObject

- (void)testMethod1;
- (void)testMethod2;
- (void)testMethod3;
- (void)testMethod4;
- (void)testMethod5;

@end

@implementation _LBTestCacheObject


- (void)testMethod1{
    
}


- (void)testMethod2{
    
}


- (void)testMethod3{
    
}

- (void)testMethod4{
    
}

- (void)testMethod5{
    
}

@end





@interface LBTestClassCacheMethodViewController ()

@end

typedef uint32_t mask_t;

struct lb_bucket_t{
    SEL _sel;
    IMP _imp;
};

struct lb_cache_t{
    struct lb_bucket_t * _buckets;
    mask_t _maybeMask;
    uint16_t _flags;
    uint16_t _occupied;
};

struct lb_class_data_bits_t{
    uintptr_t bits; //8字节
};

struct lb_objc_class{
    Class isa;
    Class superclass;
    struct lb_cache_t cache;
    struct lb_class_data_bits_t bits;
};


@implementation LBTestClassCacheMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _LBTestCacheObject *cacheObject = [[_LBTestCacheObject alloc] init];
    [cacheObject testMethod1];
    [cacheObject testMethod2];
    [cacheObject testMethod3];
    [cacheObject testMethod4];
    [cacheObject testMethod5];
    
//    如果方法多   达到扩容的时候  可能会把前面缓存的方法释放掉  导致缓存中没有了
//    [cacheObject testMethod1];//再次调用  会放到扩容后的缓存中
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        Class lbclass = cacheObject.class;
        struct lb_objc_class *lb_class = (__bridge  struct lb_objc_class *)lbclass;
        NSLog(@"LBLog %hu-%u",lb_class->cache._occupied,lb_class->cache._maybeMask);
        
        for (mask_t i = 0; i < lb_class->cache._maybeMask; i++) {
            struct lb_bucket_t bucket = lb_class->cache._buckets[i];
            NSLog(@"LBLog %@ -------- %p ",NSStringFromSelector(bucket._sel),bucket._imp);
        }
    });
    
}



@end
