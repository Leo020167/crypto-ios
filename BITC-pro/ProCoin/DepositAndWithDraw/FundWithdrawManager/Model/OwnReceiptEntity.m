//
//  OwnReceiptEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/7.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "OwnReceiptEntity.h"

//@property (copy, nonatomic) NSString *receiptId;
//@property (copy, nonatomic) NSString *receiptName;
//@property (copy, nonatomic) NSString *receiptNo;
//@property (copy, nonatomic) NSString *receiptType;
//@property (copy, nonatomic) NSString *receiptTypeLogo;
//@property (copy, nonatomic) NSString *receiptTypeValue;
//@property (copy, nonatomic) NSString *bankName;
//@property (assign, nonatomic) BOOL isDefault;

@implementation OwnReceiptEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.receiptId = [self stringParser:@"receiptId" json:json];
        self.receiptName = [self stringParser:@"receiptName" json:json];
        self.receiptNo = [self stringParser:@"receiptNo" json:json];
        self.receiptType = [self integerParser:@"receiptType" json:json];
        self.receiptTypeLogo = [self stringParser:@"receiptTypeLogo" json:json];
        self.receiptTypeValue = [self stringParser:@"receiptTypeValue" json:json];
        self.bankName = [self stringParser:@"bankName" json:json];
        self.isDefault = [self boolParser:@"isDefault" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_receiptId release];
    [_receiptName release];
    [_receiptNo release];
    [_receiptTypeLogo release];
    [_receiptTypeValue release];
    [_bankName release];
    [super dealloc];
}

@end
