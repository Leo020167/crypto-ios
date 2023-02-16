//
//  CoinIntroEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/3.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "CoinIntroEntity.h"

@implementation CoinIntroEntity

//@property (copy, nonatomic) NSString *blockUrl;             //区块链查询
//@property (copy, nonatomic) NSString *circulateAmount;      //流通量
//@property (copy, nonatomic) NSString *crowdfundPrice;       //众筹
//@property (copy, nonatomic) NSString *desc;                 //描述
//@property (copy, nonatomic) NSString *issueAmount;          //发行数量
//@property (copy, nonatomic) NSString *issueDate;            //发行时间
//@property (copy, nonatomic) NSString *officialWebUrl;       //官方网站
//@property (copy, nonatomic) NSString *whitePaperUrl;        //白皮书
//@property (copy, nonatomic) NSString *name;                 //名称

- (id)initWithJson:(NSDictionary *)json
{
    if(self = [super initWithJson:json]){
        self.blockUrl = [self stringParser:@"blockUrl" json:json];
        self.circulateAmount = [self stringParser:@"circulateAmount" json:json];
        self.crowdfundPrice = [self stringParser:@"crowdfundPrice" json:json];
        self.desc = [self stringParser:@"desc" json:json];
        self.issueAmount = [self stringParser:@"issueAmount" json:json];
        self.issueDate = [self stringParser:@"issueDate" json:json];
        self.officialWebUrl = [self stringParser:@"officialWebUrl" json:json];
        self.whitePaperUrl = [self stringParser:@"whitePaperUrl" json:json];
        self.name = [self stringParser:@"name" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_blockUrl release];
    [_circulateAmount release];
    [_crowdfundPrice release];
    [_desc release];
    [_issueAmount release];
    [_issueDate release];
    [_officialWebUrl release];
    [_whitePaperUrl release];
    [_name release];
    [super dealloc];
}

@end
