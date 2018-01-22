

#import <Foundation/Foundation.h>

@interface MapFindViewModel : NSObject

+ (void)loadDataWithLatitude:(NSString *)latitude
                    andLongitude:(NSString *)longitude
                        andScale:(NSString *)scale
                        andBlock:(void(^)(id result))block;

@end
