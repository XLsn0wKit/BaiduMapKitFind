
#import "MapFindViewController.h"

@interface MapFindViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, UISearchBarDelegate>

@property (nonatomic, strong) BMKMapView *bMapView;//百度地图
@property (nonatomic, strong) BMKLocationService *locService;//定位服务
@property (nonatomic, assign) float zoomValue;//移动或缩放前的比例尺
@property (nonatomic, assign) CLLocationCoordinate2D oldCoor;//地图移动前中心经纬度

@property(nonatomic, strong) RectangleAnnotationView *messageA;//记录点击过的大头针。便于点击空白时。把这个大头针缩小为原始大小

@end

@implementation MapFindViewController

#pragma mark -- Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = setWhiteColor;
    self.title = @"显示电站";
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.bMapView viewWillAppear];
    self.bMapView.delegate = self; //
    self.locService.delegate = self;
    [self.locService startUserLocationService];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.bMapView viewWillDisappear];
    self.bMapView.delegate = nil; // 不用时，置nil
    self.locService.delegate = nil;
    [self.locService stopUserLocationService];
  
}
- (void)dealloc {
    if (self.bMapView) {
        self.bMapView = nil;
    }
    if (self.locService) {
        self.locService.delegate = nil;
    }
}

#pragma mark -- UI

- (void)setupUI {

    
    self.bMapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    [self.view addSubview:self.bMapView];
    self.locService = [[BMKLocationService alloc] init];
    self.bMapView.delegate = self;
    self.locService.delegate = self;
    self.bMapView.showsUserLocation = YES;
    self.bMapView.showMapScaleBar = YES;//显示比例尺
    self.bMapView.mapScaleBarPosition = CGPointMake(10, 75);//比例尺位置
    self.bMapView.minZoomLevel = 9;
    self.bMapView.maxZoomLevel = 19;
    self.bMapView.isSelectedAnnotationViewFront = YES;
    self.bMapView.userTrackingMode = BMKUserTrackingModeNone;
    [self.locService startUserLocationService];
    
    //创建编码对象
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:@"杭州" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error != nil || placemarks.count == 0) {
            return;
        }
        //创建placemark对象
        CLPlacemark *placemark = [placemarks firstObject];
        NSLog(@"%f,%f",placemark.location.coordinate.latitude,placemark.location.coordinate.longitude);
        //赋值详细地址
        NSLog(@"详细地址 %@",placemark.name);
        CLLocationCoordinate2D coor;
        coor.latitude = placemark.location.coordinate.latitude;
        coor.longitude = placemark.location.coordinate.longitude;
        [self.bMapView setCenterCoordinate:coor];
        [self.bMapView setZoomLevel:12];
        self.zoomValue = 12;
    }];

}

#pragma mark -- 回到用户的位置。
- (void)backUserLocation {
    //移动到用户的位置
    [self.bMapView setCenterCoordinate:self.locService.userLocation.location.coordinate animated:YES];
}

#pragma mark -- BMKLocationServiceDelegate

/**
 *在地图View将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
    NSLog(@"start locate");
}

/**
 *在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
}

#pragma mark -- BMMapViewDelegate

//- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
//
//    for (YLAnnotation *view in self.mapView.annotations) {
//        if ([view.messageAnnoIsBig isEqualToString:@"yes"]) {
//            //把放大过的大头针缩小
//            [self.mapView deselectAnnotation:view animated:NO];
//        }
//    }
//}

- (void)mapView:(BMKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    self.zoomValue = mapView.zoomLevel;
    self.oldCoor = mapView.centerCoordinate;
    NSLog(@"之前的比例尺：%f",mapView.zoomLevel);
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    NSLog(@"更改了区域");
    NSLog(@"当前比例尺%f，过去比例尺：%f",mapView.zoomLevel,self.zoomValue);
    if (mapView.zoomLevel > self.zoomValue) {
        NSLog(@"地图放大了");
    }else if (mapView.zoomLevel < self.zoomValue){
        NSLog(@"地图缩小了");
    }
    
    if (mapView.zoomLevel > 14) {
        //请求小区
        //当没有放大缩小 计算平移的距离。当距离小于2千米。不再进行计算  避免过度消耗
        float distance = [self distanceBetweenFromCoor:self.oldCoor toCoor:mapView.centerCoordinate];
        if (distance <= 1000 && mapView.zoomLevel == self.zoomValue) {
            return;
        }
        [self loadCityAreaHouseWithScale:@"1000"
                             andLatitude:[NSString stringWithFormat:@"%f",mapView.centerCoordinate.latitude]
                            andLongitude:[NSString stringWithFormat:@"%f",mapView.centerCoordinate.longitude]
                                andBlock:^{
            
        }];

    }else if(mapView.zoomLevel <= 14) {
        if (mapView.zoomLevel == self.zoomValue) {//当平移地图。大区不再重复请求
            return;
        }
        //请求大区
        [self loadCityAreaHouseWithScale:@"3000"
                             andLatitude:@"32.041544"
                            andLongitude:@"118.767413"
                                andBlock:^{
            
        }];
    }
}

//请求城市区域内的房源组

- (void)loadCityAreaHouseWithScale:(NSString *)scale
                       andLatitude:(NSString *)latitude
                      andLongitude:(NSString *)longitude
                          andBlock:(void(^)(void))block {
    WeakSelf
    [MapFindViewModel loadDataWithLatitude:latitude
                                       andLongitude:longitude
                                           andScale:scale
                                           andBlock:^(id result) {
        NSArray *dataArray = result;
        
        if (dataArray.count > 0) {
            [weakSelf.bMapView removeAnnotations:weakSelf.bMapView.annotations];
            
            if ([scale isEqualToString:@"3000"]) {//请求大区
                for (NSDictionary *dic in dataArray) {
                    BDAnnotation *an = [[BDAnnotation alloc] init];
                    CLLocationCoordinate2D coor;
                    coor.latitude = [dic[@"latitude"] floatValue];
                    coor.longitude = [dic[@"longitude"] floatValue];
                    an.type = 1;
                    an.coordinate = coor;
                    an.title = dic[@"title"];
                    an.subtitle = [NSString stringWithFormat:@"%@个",dic[@"count"]];
                    an.Id = dic[@"id"];
                    [weakSelf.bMapView addAnnotation:an];
                }

            }else if([scale isEqualToString:@"1000"]) {//请求小区
                for (NSDictionary *dic in dataArray) {
                    BDAnnotation *an = [[BDAnnotation alloc] init];
                    CLLocationCoordinate2D coor;
                    coor.latitude = [dic[@"latitude"] floatValue];
                    coor.longitude = [dic[@"longitude"] floatValue];
                    an.type = 2;
                    an.coordinate = coor;
                    an.title = @"具体显示xx电站名称";
                    an.minPrice = dic[@"minfee"];
                    [weakSelf.bMapView addAnnotation:an];
                }
            }
            block();
        }else {

            
            NSLog(@"无房源！");
        }
    }];
}
//使用苹果原生库计算两个经纬度直接的距离

- (double)distanceBetweenFromCoor:(CLLocationCoordinate2D)coor1 toCoor:(CLLocationCoordinate2D)coor2 {
    CLLocation *curLocation = [[CLLocation alloc] initWithLatitude:coor1.latitude longitude:coor1.longitude];
    CLLocation *otherLocation = [[CLLocation alloc] initWithLatitude:coor2.latitude longitude:coor2.longitude];
    double distance  = [curLocation distanceFromLocation:otherLocation];
    return distance;
}


/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.bMapView updateLocationData:userLocation];
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    [self.bMapView updateLocationData:userLocation];
}
//地图渲染完毕
- (void)mapViewDidFinishRendering:(BMKMapView *)mapView {
    
    //避免屏幕内没有房源-->计算屏幕右上角、左下角经纬度-->获取这个区域内所有的大头针-->判断有没有大头针-->若屏幕内没有，但整个地图中存在大头针-->移动中心点到这个大头针
    BMKCoordinateBounds coorbBound;
    CLLocationCoordinate2D northEast;
    CLLocationCoordinate2D southWest;
    northEast = [mapView convertPoint:CGPointMake(kScreenWidth, 0) toCoordinateFromView:mapView];
    southWest = [mapView convertPoint:CGPointMake(0, kScreenHeight) toCoordinateFromView:mapView];
    coorbBound.northEast = northEast;
    coorbBound.southWest = southWest;
    NSArray *annotations = [mapView annotationsInCoordinateBounds:coorbBound];
    if (annotations.count == 0 && mapView.annotations.count > 0 && mapView.zoomLevel != self.zoomValue) {
        BDAnnotation *firstAnno = mapView.annotations.firstObject;
        //如果是个人位置的大头针。那么如果地图中大头针个数又大于1.取最后一个；否则return
        if (firstAnno.coordinate.latitude == self.locService.userLocation.location.coordinate.latitude) {
            NSLog(@"这是个个人位置大头针");
            if (mapView.annotations.count > 1) {
                firstAnno = mapView.annotations.lastObject;
            }else {
                return;
            }
        }
        [mapView setCenterCoordinate:firstAnno.coordinate animated:NO];
    }
    
}


- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation {
    BDAnnotation *anno = (BDAnnotation *)annotation;
    
    if (anno.type == 1) {
        // 检查是否有重用的缓存
        RoundAnnotationView *annotationView = (RoundAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:@"round"];
        
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[RoundAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"round"];
            annotationView.paopaoView = nil;
        }

        
        annotationView.title = anno.title;
        annotationView.subTitle = anno.subtitle;

        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        
        return annotationView;
        
    }else {
        
        NSString *AnnotationViewID = @"message";
        // 检查是否有重用的缓存
        RectangleAnnotationView *annotationView = (RectangleAnnotationView *)[view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
        // 缓存没有命中，自己构造一个，一般首次添加annotation代码会运行到此处
        if (annotationView == nil) {
            annotationView = [[RectangleAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
            annotationView.paopaoView = nil;
        }
        // 设置偏移位置--->向上左偏移
        annotationView.centerOffset = CGPointMake(annotationView.frame.size.width * 0.5, -(annotationView.frame.size.height * 0.5));
        annotationView.title = anno.title;
        annotationView.annotation = anno;
        annotationView.canShowCallout = NO;
        return annotationView;
    }
}

//点击了大头针
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    if (view.annotation.coordinate.latitude == self.locService.userLocation.location.coordinate.latitude) {//个人位置特殊处理，否则类型不匹配崩溃
        NSLog(@"点击了个人位置");
        return;
    }
    
    BDAnnotation *annotation = (BDAnnotation *)view.annotation;

    if (annotation.type == 2) {
        
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        
        //让点击的大头针放大效果
        [messageAnno didSelectedAnnotation:messageAnno];
        
        self.messageA = messageAnno;
        annotation.messageAnnoIsBig = @"yes";
        //取消大头针的选中状态，否则下次再点击同一个则无法响应事件
//        [mapView deselectAnnotation:annotationView animated:NO];
        //计算距离 --> 请求列表数据 --> 完成 --> 展示表格
//        self.communityId = annotationView.Id;

    }else {
        //点击了区域--->进入小区
        //拿到大头针经纬度，放大地图。然后重新计算小区
        [mapView setCenterCoordinate:annotation.coordinate animated:NO];
        [mapView setZoomLevel:16];
    }
}

- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    BDAnnotation *annotationView = (BDAnnotation *)view.annotation;
    if (annotationView.type == 2) {
        RectangleAnnotationView *messageAnno = (RectangleAnnotationView *)view;
        annotationView.messageAnnoIsBig = @"no";
        [messageAnno didDeSelectedAnnotation:messageAnno];
        [mapView mapForceRefresh];
    }
}

@end
