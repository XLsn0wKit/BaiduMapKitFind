
#import "MapFindViewModel.h"

@implementation MapFindViewModel

+ (void)loadDataWithLatitude:(NSString *)latitude
                    andLongitude:(NSString *)longitude
                        andScale:(NSString *)scale
                        andBlock:(void(^)(id result))block {
    
    
    /// 写入假数据
    /// 30.2749179599, 120.1623057522
    /// 30.1816260660, 120.1555925970
    block(@[@{@"latitude" : @"30.2749179599",
              @"longitude" : @"120.1623057522",
              @"count" : @"5",
              @"title" : @"武林门"
              },
            
            @{@"latitude" : @"30.1816260660",
              @"longitude" : @"120.1555925970",
              @"count" : @"11",
              @"title" : @"杨家墩"
              }]);
}

@end
