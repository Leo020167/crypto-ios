//
//  PlacardSQL.h
//  TJRtaojinroad
//
//  Created by taojinroad on 14-3-21.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRAppInfo.h"

@interface PlacardSQL : NSObject

- (BOOL)replacePlacardSQl:(NSString*)placardTime content:(NSString*)content title:(NSString*)title;

- (BOOL)replacePlacardSQl:(TJRPlacard*)item;

- (TJRPlacard*)selectPlacardSQl;

@end
