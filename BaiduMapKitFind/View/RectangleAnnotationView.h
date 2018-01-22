
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface RectangleAnnotationView : BMKAnnotationView

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *messageAnnoIsBig;

- (void)didSelectedAnnotation:(RectangleAnnotationView *)annotation;
- (void)didDeSelectedAnnotation:(RectangleAnnotationView *)annotation;

@end
