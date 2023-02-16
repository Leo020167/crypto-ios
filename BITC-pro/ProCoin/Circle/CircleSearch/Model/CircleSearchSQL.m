//
//  CircleSearchSQL.m
//  Redz
//
//  Created by Hay on 2018/12/19.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "CircleSearchSQL.h"
#import "TJRDatabase.h"
#import "VeDateUtil.h"

@implementation CircleSearchSQL

/** 插入数据*/
+ (void)updateSearchDataToTable:(CircleSearchEntity *)entity
{
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO circle_search(circle_name,circle_id,create_user_id,circle_logo,search_time)  VALUES('%@','%@','%@','%@','%@')",entity.circleName,entity.circleId,entity.createUserId,entity.circleLogo,[VeDateUtil getNowTime]];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"更新搜索数据出错:%@",sql);
        }
    }];
    
}
/** 查找表中的搜索数据*/
+ (NSArray<CircleSearchEntity *> *)querySearchDataFromTable
{
    NSMutableArray<CircleSearchEntity *> *searchDataArr = [NSMutableArray array];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        //查询
        NSString *sql = [NSString stringWithFormat:@"select * from circle_search order by search_time desc"];
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]){
            CircleSearchEntity *entity = [[[CircleSearchEntity alloc] init] autorelease];
            entity.circleId = [rs stringForColumn:@"circle_id"];
            entity.circleName = [rs stringForColumn:@"circle_name"];
            entity.circleLogo = [rs stringForColumn:@"circle_logo"];
            entity.createUserId = [rs stringForColumn:@"create_user_id"];
            [searchDataArr addObject:entity];
        }
        [rs close];
    }];
    
    return searchDataArr;
}

/** 删除数据*/
+ (void)deleteSearchDataFromTable:(CircleSearchEntity *)entity;
{
    NSString *sql = [NSString stringWithFormat:@"delete from circle_search WHERE circle_id='%@'",entity.circleId];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"删除搜索数据出错:%@",sql);
        }
    }];
}
@end
