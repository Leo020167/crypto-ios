//
//  CMShareTimeBaseData.h
//  Cropyme
//
//  Created by Hay on 2019/7/1.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CMShareTimeBaseData : TJRBaseEntity
//1561964640,0.08442300,108937.85364740

@property (copy, nonatomic) NSString *time;             //时间,格式为yyyyMMddHHmmss
@property (copy, nonatomic) NSString *last;             //当前价格
@property (copy, nonatomic) NSString *currentVolume;    //当前成交量

@end


