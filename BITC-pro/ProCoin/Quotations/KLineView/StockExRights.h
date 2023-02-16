//
//  StockExRights.h
//  TJRtaojinroad
//
//  Created by 影孤清 on 14-6-23.
//  Copyright (c) 2014年 淘金路. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TJRBaseEntity.h"

/**
 *   除权信息数据
 *   @author 影孤清
 */
@interface StockExRights : TJRBaseEntity
@property (assign, nonatomic) double fenHong;	/* 分红 */
@property (assign, nonatomic) double peiGu;/* 配股 */
@property (assign, nonatomic) double peiJia;	/* 配价 */
@property (assign, nonatomic) double songGu;	/* 送股 */
@property (copy, nonatomic) NSString *fdm;	/* 代码 */
@property (assign, nonatomic) NSInteger stockDate;	/* 日期 */

- (NSComparisonResult)compareKeysByDes:(id)otherObject;
- (NSComparisonResult)compareKeysByAsc:(id)otherObject;
@end

