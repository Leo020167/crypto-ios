//
//  CDBaseInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/8.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"


@interface CDBaseInfoEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *predictProfitShare;       //预计跟单分成
@property (copy, nonatomic) NSString *totalFollowBalance;       //总跟单金额
@property (copy, nonatomic) NSString *totalProfitShare;         //累计跟单净分成

@end


