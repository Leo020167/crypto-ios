//
//  PCTradeConfigModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/25.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCTradeConfigModel.h"

@implementation PCTradeConfigModel



- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.accountName = [self stringParser:@"accountName" json:json];
        self.accountType = [self stringParser:@"accountType" json:json];
        self.openFeeScale = [self stringParser:@"openFeeScale" json:json];
        self.priceDecimals = [self integerParser:@"priceDecimals" json:json];
        self.usdtRate = [self stringParser:@"usdtRate" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        
        NSArray *initHandList = [json objectForKey:@"initHandList"];
        if(initHandList && [initHandList isKindOfClass:[NSArray class]]){
            NSMutableArray *dataArr = [NSMutableArray array];
            for(id item in initHandList){
                [dataArr addObject:[NSString stringWithFormat:@"%@",item]];
            }
            self.handList = [NSArray arrayWithArray:dataArr];
        }
        NSArray *multiNumList = [json objectForKey:@"multiNumList"];
        if(multiNumList && [multiNumList isKindOfClass:[NSArray class]]){
            NSMutableArray *dataArr = [NSMutableArray array];
            for(id item in multiNumList){
                [dataArr addObject:[NSString stringWithFormat:@"%@",item]];
            }
            self.multiNumList = [NSArray arrayWithArray:dataArr];
        }
        
        NSArray *openRateList = [json objectForKey:@"openRateList"];
        if(openRateList && [openRateList isKindOfClass:[NSArray class]]){
            NSMutableArray *dataArr = [NSMutableArray array];
            for(id item in openRateList){
                [dataArr addObject:item];
            }
            self.openRateList = [NSArray arrayWithArray:dataArr];
        }
    }
    return self;
}

- (void)dealloc
{
    [_accountName release];
    [_accountType release];
    [_openFeeScale release];
    [_usdtRate release];
    [_handList release];
    [_multiNumList release];
    [_openRateList release];
    [super dealloc];
}

@end
