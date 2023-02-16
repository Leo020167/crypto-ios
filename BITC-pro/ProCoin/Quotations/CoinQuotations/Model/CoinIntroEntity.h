//
//  CoinIntroEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/3.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface CoinIntroEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *blockUrl;             //区块链查询
@property (copy, nonatomic) NSString *circulateAmount;      //流通量
@property (copy, nonatomic) NSString *crowdfundPrice;       //众筹
@property (copy, nonatomic) NSString *desc;                 //描述
@property (copy, nonatomic) NSString *issueAmount;          //发行数量
@property (copy, nonatomic) NSString *issueDate;            //发行时间
@property (copy, nonatomic) NSString *officialWebUrl;       //官方网站
@property (copy, nonatomic) NSString *whitePaperUrl;        //白皮书
@property (copy, nonatomic) NSString *name;                 //名称

@end


