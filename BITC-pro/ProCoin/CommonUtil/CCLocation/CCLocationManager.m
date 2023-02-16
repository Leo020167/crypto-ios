//
//  CCLocationManager.m
//  MMLocationManager
//
//  Created by WangZeKeJi on 14-12-10.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import "CCLocationManager.h"
#import "CLLocation+YCLocation.h"
#import "VeDateUtil.h"
@interface CCLocationManager ()<UIAlertViewDelegate> {
	CLLocationManager *_manager;
}
@property (nonatomic, copy) LocationBlock locationBlock;
@property (nonatomic, copy) NSStringBlock cityBlock;
@property (nonatomic, copy) NSStringBlock addressBlock;
@property (nonatomic, copy) NSArrayBlock addressArrayBlock;
@property (nonatomic, copy) LocationErrorBlock errorBlock;

@end

@implementation CCLocationManager

+ (CCLocationManager *)shareLocation {
	static dispatch_once_t pred = 0;
	static id _sharedObject = nil;

	dispatch_once(&pred, ^{
		_sharedObject = [[self alloc] init];
	});
	return _sharedObject;
}

- (id)init {
	self = [super init];

	if (self) {
		NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];

		float longitude = [standard floatForKey:CCLastLongitude];
		float latitude = [standard floatForKey:CCLastLatitude];
		self.longitude = longitude;
		self.latitude = latitude;
        self.saveTime = [standard stringForKey:CCLastSaveTime];
		self.lastCoordinate = CLLocationCoordinate2DMake(longitude, latitude);
		self.lastCity = [standard objectForKey:CCLastCity];
		self.lastAddress = [standard objectForKey:CCLastAddress];
        _lastAddressArray = [NSMutableArray new];
        [self.lastAddressArray addObjectsFromArray:[standard arrayForKey:CCLastAddressArray]];
	}
	return self;
}

/**
 *  获取坐标,一天内只获取一次
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param time          获取坐标的间隔时间,以秒为单位
 *
 *  @return true为获取当前位置,false为获取保存的上次位置
 */
- (BOOL)getLocationCoordinate:(LocationBlock)locaiontBlock withTime:(NSInteger)time {
    if (([VeDateUtil currentNowTimeIntervalWithKey:CCLastSaveTime]/1000) >= time) {
        [self getLocationCoordinate:locaiontBlock];
        return true;
    } else {
        if (locaiontBlock) {
            locaiontBlock(_lastCoordinate);
        }
        return false;
    }
}

/**
 *  获取坐标,一天内只获取一次
 *
 *  @param locaiontBlock
 */
- (void)getLocationCoordinateForDay:(LocationBlock)locaiontBlock {
    [self getLocationCoordinate:locaiontBlock withTime:86400];
}

// 获取经纬度
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock {
	self.locationBlock = locaiontBlock;
	[self startLocation];
}

- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withAddress:(NSArrayBlock)addressBlock {
	self.locationBlock = locaiontBlock;
	self.addressArrayBlock = addressBlock;
	[self startLocation];
}

- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withOneAddress:(NSStringBlock)addressBlock {
	self.locationBlock = locaiontBlock;
	self.addressBlock = addressBlock;
	[self startLocation];
}

- (void)getAddress:(NSStringBlock)addressBlock {
	self.addressBlock = addressBlock;
	[self startLocation];
}

// 获取省市
- (void)getCity:(NSStringBlock)cityBlock {
	self.cityBlock = cityBlock;
	[self startLocation];
}

#pragma mark CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
	NSUserDefaults *standard = [NSUserDefaults standardUserDefaults];
	CLLocation *location = [[CLLocation alloc] initWithLatitude:newLocation.coordinate.latitude longitude:newLocation.coordinate.longitude];
	CLLocation *marsLoction = [location locationMarsFromEarth];

	CLGeocoder *geocoder = [[CLGeocoder alloc]init];

	[geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks, NSError *error) {
        [self.lastAddressArray removeAllObjects];
        if (placemarks.count > 0) {
            NSUInteger i = 0;
            for (CLPlacemark *placemark in placemarks) {
                NSString *city = placemark.locality;
                NSString *address = placemark.name;
                [self.lastAddressArray addObject:address];
                if (TTIsStringWithAnyText(address)) {
                    [standard setObject:city forKey:CCLastCity];// 省市地址
                    self.lastCity = city;
                    self.lastAddress = address;
                    break;
                }
                i++;
            }
		}

		if (_cityBlock) {
			_cityBlock(_lastCity);
            RELEASE(_cityBlock);
		}

		if (_addressBlock) {
            _addressBlock(_lastAddress);
            RELEASE(_addressBlock);
		}
        
        if (_addressArrayBlock) {
            _addressArrayBlock(_lastAddressArray);
            RELEASE(_addressArrayBlock);
        }
	}];
    
#if TARGET_IPHONE_SIMULATOR//模拟器
    _lastCoordinate = CLLocationCoordinate2DMake(23.118791, 113.355816);
#elif TARGET_OS_IPHONE//真机
    _lastCoordinate = CLLocationCoordinate2DMake(marsLoction.coordinate.latitude, marsLoction.coordinate.longitude);
#endif

	if (_locationBlock) {
        _locationBlock(_lastCoordinate);
        RELEASE(_locationBlock);
	}

    self.longitude = _lastCoordinate.longitude;
    self.latitude = _lastCoordinate.latitude;
    self.saveTime = [VeDateUtil currentDateTimeIntervalToString];
	NSLog(@"%f--%f", _lastCoordinate.latitude, _lastCoordinate.longitude);
    if (self.longitude != 0 && self.latitude != 0) {
        [standard setObject:@(self.latitude) forKey:CCLastLatitude];
        [standard setObject:@(self.longitude) forKey:CCLastLongitude];
        [standard setObject:self.saveTime forKey:CCLastSaveTime];
        [standard synchronize];
    }
    
	[manager stopUpdatingLocation];
    RELEASE(location);
    RELEASE(geocoder);
}

/**
 *  通过坐标获取详细的地址信息
 *
 *  @param latitude     latitude description
 *  @param longitude    longitude description
 *  @param addressBlock
 */
+ (void)getAddressWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude addressBlock:(NSArrayBlock)addressBlock {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    CLLocation *marsLoction = [location locationMarsFromEarth];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:marsLoction completionHandler:^(NSArray *placemarks, NSError *error) {
        NSMutableArray *array = [NSMutableArray array];
        for (CLPlacemark *placemark in placemarks) {
            NSString *address = placemark.name;
            if (TTIsStringWithAnyText(address)) {
                [array addObject:address];
            }
        }
        if (addressBlock) {
            addressBlock(array);
        }
    }];
    RELEASE(location);
    RELEASE(geocoder);
}

+ (BOOL)locationServicesCanEnabled {
    return ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied));
}

- (void)startLocation {
	if ([CCLocationManager locationServicesCanEnabled]) {
		_manager = [[CLLocationManager alloc]init];
		_manager.delegate = self;
		_manager.desiredAccuracy = kCLLocationAccuracyBest;
        if (CURRENT_DEVICE_VERSION>=8.0) {
//            [_manager requestAlwaysAuthorization];
          [_manager requestWhenInUseAuthorization];
        }
		_manager.distanceFilter = 100;
        _manager.pausesLocationUpdatesAutomatically = true;
		[_manager startUpdatingLocation];
	} else {
        [self locationServiceNOCompetence];
	}
}

- (void)locationServiceNOCompetence {
    UIAlertView *alvertView = [[UIAlertView alloc]initWithTitle:NSLocalizedStringForKey(@"提示") message:@"需要开启定位服务,请到设置->隐私,打开定位服务,并允许Redz 使用定位服务" delegate:nil cancelButtonTitle:NSLocalizedStringForKey(@"取消") otherButtonTitles:NSLocalizedStringForKey(@"设置"),nil];
    alvertView.delegate = self;
    [alvertView show];
    RELEASE(alvertView);
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == alertView.firstOtherButtonIndex) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
	[self stopLocation];
}

- (void)stopLocation {
    if (_manager)[_manager stopUpdatingLocation];
    RELEASE(_manager);
    RELEASE(_lastCity);
    RELEASE(_lastAddress);
    RELEASE(_locationBlock);
    RELEASE(_cityBlock);
    RELEASE(_addressBlock);
    RELEASE(_errorBlock);
    [_lastAddressArray removeAllObjects];
    RELEASE(_addressArrayBlock);
}

- (void)dealloc {
    RELEASE(_saveTime);
    [_lastAddressArray removeAllObjects];
    RELEASE(_lastAddressArray);
    RELEASE(_manager);
    RELEASE(_lastCity);
    RELEASE(_lastAddress);
    RELEASE(_locationBlock);
    RELEASE(_cityBlock);
    RELEASE(_addressBlock);
    RELEASE(_errorBlock);
    [super dealloc];
}

@end
