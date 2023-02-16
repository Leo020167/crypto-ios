//
//  TJRDatabase.h
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRFMDB.h"

extern NSInteger const NewVersion;
//使用替代执行数据库语句时,保存sql和替代对象的Key
extern NSString const *ExecuteSQLKey;
extern NSString const *ArgumentsKey;

@interface TJRDatabase : NSObject

+ (TJRFMDatabase *)shareFMDatabase;
+ (TJRFMDatabaseQueue *)shareFMDatabaseQueue;

@end
