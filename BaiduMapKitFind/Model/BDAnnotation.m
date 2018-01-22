
#import "BDAnnotation.h"

@implementation BDAnnotation

//重写判定两个对象相等的逻辑
- (BOOL)isEqual:(BDAnnotation *)object {
    //如果两个大头针的title一样，那么就是同一个大头针 也可以判定经纬度一样
    return [self.title isEqual:object.title];
}

@end
