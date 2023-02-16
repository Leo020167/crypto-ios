//
//  SearchCoinSQL.h
//  Cropyme
//
//  Created by Hay on 2019/8/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchCoinDataEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface SearchCoinSQL : NSObject

/** 插入数据*/
+ (void)updateSearchCoinDataToTable:(SearchCoinDataEntity *)entity;
/** 查找表中的搜索数据*/
+ (NSArray<SearchCoinDataEntity *> *)querySearchCoinDataFromTable;
/** 删除数据*/
+ (void)deleteSearchCoinDataFromTable:(SearchCoinDataEntity *)entity;

@end

NS_ASSUME_NONNULL_END
