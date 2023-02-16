//
//  CCLocationManager.h
//  MMLocationManager
//
//  Created by WangZeKeJi on 14-12-10.
//  Copyright (c) 2014年 Chen Yaoqiang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

#define  CCLastSaveTime     @"CCLastSaveTime"
#define  CCLastLongitude	@"CCLastLongitude"
#define  CCLastLatitude		@"CCLastLatitude"
#define  CCLastCity			@"CCLastCity"
#define  CCLastAddress		@"CCLastAddress"
#define  CCLastAddressArray @"CCLastAddressArray"

typedef void (^ LocationBlock)(CLLocationCoordinate2D locationCorrrdinate);
typedef void (^ LocationErrorBlock) (NSError *error);
typedef void (^ NSStringBlock)(NSString *cityString);
typedef void (^ NSArrayBlock)(NSArray *addressArray);

@interface CCLocationManager : NSObject <CLLocationManagerDelegate>
@property (nonatomic, assign) CLLocationCoordinate2D lastCoordinate;
@property (nonatomic, copy) NSString *lastCity;
@property (nonatomic, copy) NSString *lastAddress;
@property (nonatomic, retain) NSMutableArray *lastAddressArray;

@property(nonatomic, assign) CGFloat latitude;
@property(nonatomic, assign) CGFloat longitude;
@property (nonatomic, copy) NSString *saveTime;

+ (CCLocationManager *)shareLocation;

+ (BOOL)locationServicesCanEnabled;

/**
 *  通过坐标获取详细的地址信息
 *
 *  @param latitude     latitude description
 *  @param longitude    longitude description
 *  @param addressBlock
 */
+ (void)getAddressWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude addressBlock:(NSArrayBlock)addressBlock;

/**
 *  获取位置没有权限的警告框
 */
- (void)locationServiceNOCompetence;

/**
 *  获取坐标,一天内只获取一次
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param time          获取坐标的间隔时间,以秒为单位
 *
 *  @return true为获取当前位置,false为获取保存的上次位置
 */
- (BOOL)getLocationCoordinate:(LocationBlock)locaiontBlock withTime:(NSInteger)time;

/**
 *  获取坐标,一天内只获取一次
 *
 *  @param locaiontBlock
 */
- (void)getLocationCoordinateForDay:(LocationBlock)locaiontBlock;

/**
 *  获取坐标
 *
 *  @param locaiontBlock locaiontBlock description
 */
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock;

/**
 *  获取坐标和详细地址(如果有多个就返回多个)
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param addressBlock  addressBlock description
 */
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withAddress:(NSArrayBlock)addressBlock;

/**
 *  获取坐标和详细地址(只一个地址)
 *
 *  @param locaiontBlock locaiontBlock description
 *  @param addressBlock  addressBlock description
 */
- (void)getLocationCoordinate:(LocationBlock)locaiontBlock withOneAddress:(NSStringBlock)addressBlock;

/**
 *  获取详细地址
 *
 *  @param addressBlock addressBlock description
 */
- (void)getAddress:(NSStringBlock)addressBlock;

/**
 *  获取城市
 *
 *  @param cityBlock cityBlock description
 */
- (void)getCity:(NSStringBlock)cityBlock;

/**
 *  停止获取位置信息
 */
- (void)stopLocation;

@end
