//
//  SearchCoinSQL.m
//  Cropyme
//
//  Created by Hay on 2019/8/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "SearchCoinSQL.h"
#import "TJRDatabase.h"
#import "VeDateUtil.h"

@implementation SearchCoinSQL

/** 插入数据*/
+ (void)updateSearchCoinDataToTable:(SearchCoinDataEntity *)entity
{
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO SearchCoinDataTable(symbol,price,createTime,marketType)  VALUES('%@','%@','%@','%@')",entity.symbol,entity.price,[VeDateUtil getNowTime],entity.marketType];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"更新搜索数据出错:%@",sql);
        }
    }];
}

/** 查找表中的搜索数据*/
+ (NSArray<SearchCoinDataEntity *> *)querySearchCoinDataFromTable
{
    NSMutableArray<SearchCoinDataEntity *> *searchDataArr = [NSMutableArray array];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        //查询
        NSString *sql = [NSString stringWithFormat:@"select * from SearchCoinDataTable order by createTime desc"];
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]){
            SearchCoinDataEntity *entity = [[[SearchCoinDataEntity alloc] init] autorelease];
            entity.symbol = [rs stringForColumn:@"symbol"];
            entity.price = [rs stringForColumn:@"price"];
            entity.marketType = [rs stringForColumn:@"marketType"];
            [searchDataArr addObject:entity];
        }
        [rs close];
    }];
    
    return searchDataArr;
}

/** 删除数据*/
+ (void)deleteSearchCoinDataFromTable:(SearchCoinDataEntity *)entity
{
    NSString *sql = [NSString stringWithFormat:@"delete from SearchCoinDataTable WHERE symbol='%@'",entity.symbol];
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        BOOL success = [db executeUpdate:sql];
        if (!success) {
            NSLog(@"删除搜索数据出错:%@",sql);
        }
    }];
}

@end
