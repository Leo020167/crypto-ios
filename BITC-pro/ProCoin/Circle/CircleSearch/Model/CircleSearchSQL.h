//
//  SearchDataSQL.h
//  Redz
//
//  Created by Hay on 2018/12/19.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CircleSearchEntity.h"


@interface CircleSearchSQL : NSObject
//
/** 插入数据*/
+ (void)updateSearchDataToTable:(CircleSearchEntity *)entity;
/** 查找表中的搜索数据*/
+ (NSArray<CircleSearchEntity *> *)querySearchDataFromTable;
/** 删除数据*/
+ (void)deleteSearchDataFromTable:(CircleSearchEntity *)entity;

@end


