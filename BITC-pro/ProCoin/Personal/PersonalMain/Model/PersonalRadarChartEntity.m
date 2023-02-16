//
//  PersonalRadarChartEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/24.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "PersonalRadarChartEntity.h"

@implementation PersonalRadarChartEntity



- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.tolIncomeRate = [self stringParser:@"tolIncomeRate" json:json];
        if(!checkIsStringWithAnyText(_tolIncomeRate)){
            self.tolIncomeRate = @"--";
        }
        self.followRate = [self stringParser:@"copyRate" json:json];
        if(!checkIsStringWithAnyText(_followRate)){
            self.followRate = @"--";
        }
        self.profitShare = [self stringParser:@"profitShare" json:json];
        if(!checkIsStringWithAnyText(_profitShare)){
            self.profitShare = @"--";
        }
        self.followNum = [self stringParser:@"copyNum" json:json];
        if(!checkIsStringWithAnyText(_followNum)){
            self.followNum = @"--";
        }
        self.followBalance = [self stringParser:@"copyBalance" json:json];
        if(!checkIsStringWithAnyText(_followBalance)){
            self.followBalance = @"--";
        }
        
        NSDictionary *scoreDataDic = [json objectForKey:@"scoreData"];
        self.tolIncomeScore = [self floatParser:@"tolIncomeScore" json:scoreDataDic];
        self.followRateScore = [self floatParser:@"copyRateScore" json:scoreDataDic];
        self.profitShareScore = [self floatParser:@"profitShareScore" json:scoreDataDic];
        self.followNumScore = [self floatParser:@"copyNumScore" json:scoreDataDic];
        self.followBalanceScore = [self floatParser:@"copyBalanceScore" json:scoreDataDic];
    }
    return self;
}

- (void)dealloc
{
    [_tolIncomeRate release];
    [_followRate release];
    [_profitShare release];
    [_followNum release];
    [_followBalance release];
    [super dealloc];
}

@end
