//
//  SearchDataSQL.m
//  Redz
//
//  Created by Hay on 2018/12/19.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "SearchDataSQL.h"
#import "TJRDatabase.h"
#import "VeDateUtil.h"
@implementation SearchDataSQL

/** 插入数据*/
+ (void)updateSearchDataToTable:(SearchDataEntity *)entity
{
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO SearchUserDataTable(headUrl,name,userId,updateTime)  VALUES('%@','%@','%@','%@')",entity.headUrl,entity.name,entity.userId,[VeDateUtil getNowTime]];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"更新搜索数据出错:%@",sql);
        }
    }];
    
}
/** 查找表中的搜索数据*/
+ (NSArray<SearchDataEntity *> *)querySearchDataFromTable
{
    NSMutableArray<SearchDataEntity *> *searchDataArr = [NSMutableArray array];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        //查询
        NSString *sql = [NSString stringWithFormat:@"select * from SearchUserDataTable order by updateTime desc"];
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]){
            SearchDataEntity *entity = [[[SearchDataEntity alloc] init] autorelease];
            entity.headUrl = [rs stringForColumn:@"headUrl"];
            entity.name = [rs stringForColumn:@"name"];
            entity.userId = [rs stringForColumn:@"userId"];
            [searchDataArr addObject:entity];
        }
        [rs close];
    }];
    
    return searchDataArr;
}

/** 删除数据*/
+ (void)deleteSearchDataFromTable:(SearchDataEntity *)entity;
{
    NSString *sql = [NSString stringWithFormat:@"delete from SearchUserDataTable WHERE userId='%@'",entity.userId];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"删除搜索数据出错:%@",sql);
        }
    }];
}
@end
