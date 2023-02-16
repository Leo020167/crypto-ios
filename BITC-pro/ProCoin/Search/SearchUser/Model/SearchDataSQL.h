//
//  SearchDataSQL.h
//  Redz
//
//  Created by Hay on 2018/12/19.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchDataEntity.h"


@interface SearchDataSQL : NSObject
//
/** 插入数据*/
+ (void)updateSearchDataToTable:(SearchDataEntity *)entity;
/** 查找表中的搜索数据*/
+ (NSArray<SearchDataEntity *> *)querySearchDataFromTable;
/** 删除数据*/
+ (void)deleteSearchDataFromTable:(SearchDataEntity *)entity;

@end


