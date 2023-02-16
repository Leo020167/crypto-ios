//
//  CircleSettingRemindEntity.h
//  TJRtaojinroad
//
//  Created by Hay on 16/1/12.
//  Copyright © 2016年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

@class TJRFMResultSet;

@interface CircleSettingRemindEntity : TJRBaseEntity

@property (nonatomic, copy) NSString *circleId;    // 圈号
@property (assign, nonatomic) NSInteger chatRemind;             //0为开提醒，1为是关提醒
@property (assign, nonatomic) NSInteger talkPermission;         //成员发言，0关闭，1开放


@end
