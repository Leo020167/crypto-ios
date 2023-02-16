//
//  StoreTransferConfigModel.h
//  BYY
//
//  Created by Hay on 2019/12/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"


@interface StoreTransferConfigModel : TJRBaseEntity

@property (nonatomic, copy) NSString *amount;           //剩余数量
@property (nonatomic, copy) NSString *minInAmount;      //最小充值数量
@property (nonatomic, copy) NSString *storeSymbol;      //symobl


@end


