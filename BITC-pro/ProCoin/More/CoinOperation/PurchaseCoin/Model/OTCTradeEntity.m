//
//  OTCTradeEntity.m
//  Cropyme
//
//  Created by Hay on 2019/9/10.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "OTCTradeEntity.h"
#import "CommonUtil.h"

@implementation OTCTradeEntity

//@property (copy, nonatomic) NSString *headUrl;
//@property (copy, nonatomic) NSString *maxCny;
//@property (copy, nonatomic) NSString *minCny;
//@property (copy, nonatomic) NSString *price;
//@property (copy, nonatomic) NSString *symbol;
//@property (copy, nonatomic) NSString *userId;
//@property (copy, nonatomic) NSString *userName;

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.maxCny = [self stringParser:@"maxCny" json:json];
        self.minCny = [self stringParser:@"minCny" json:json];
        self.price = [self stringParser:@"price" json:json];
        self.symbol = [self stringParser:@"symbol" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        NSMutableArray *array = [NSMutableArray array];
        NSArray *receiptList = [json objectForKey:@"receiptList"];
        for(NSDictionary *dic in receiptList){
            OTCReceiptEntity *receiptEntity = [[[OTCReceiptEntity alloc] initWithJson:dic] autorelease];
            [array addObject:receiptEntity];
        }
        self.receiptTypeArr = [NSArray arrayWithArray:array];
        
    }
    return self;
}

- (void)dealloc
{
    [_headUrl release];
    [_maxCny release];
    [_minCny release];
    [_price release];
    [_symbol release];
    [_userId release];
    [_userName release];
    [_receiptTypeArr release];
    [super dealloc];
}

@end


@implementation OTCReceiptEntity




- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.receiptTypeLogo = [self stringParser:@"receiptTypeLogo" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.receiptType = [self stringParser:@"receiptType" json:json];
        self.receiptId = [self stringParser:@"receiptId" json:json];
        self.receiptDesc = [self stringParser:@"receiptDesc" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_receiptTypeLogo release];
    [_receiptTypeValue release];
    [_receiptType release];
    [_receiptId release];
    [_receiptDesc release];
    [super dealloc];
}

@end
