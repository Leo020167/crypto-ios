//
//  PersonalRadarChartEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/24.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

//copyBalance = 0;
//copyBalanceRank = 8;
//copyNum = 0;
//copyNumRank = 8;
//copyRate = 0;
//profitShare = 0;
//score = "31.5";
//scoreData =                 {
//    copyBalanceScore = "1.00";
//    copyNumScore = "100.00";
//    copyRateScore = "1.00";
//    profitShareScore = "1.00";
//    tolIncomeScore = "1.00";
//};
//time = 1561305600;
//tolIncomeRate = "138858.01";
//tolRadar = 100;
//userId = 13;

@interface PersonalRadarChartEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *tolIncomeRate;        //高手实盘收益率
@property (assign, nonatomic) CGFloat tolIncomeScore;       //高手实盘收益率雷达图占比
@property (copy, nonatomic) NSString *followRate;           //用户跟单收益率
@property (assign, nonatomic) CGFloat followRateScore;      //用户跟单收益率雷达图占比
@property (copy, nonatomic) NSString *profitShare;          //跟单盈利率
@property (assign, nonatomic) CGFloat profitShareScore;     //跟单盈利率雷达图占比
@property (copy, nonatomic) NSString *followNum;            //当前跟单人数
@property (assign, nonatomic) CGFloat followNumScore;       //当前跟单人数雷达图占比
@property (copy, nonatomic) NSString *followBalance;        //用户跟单收益额
@property (assign, nonatomic) CGFloat followBalanceScore;   //用户跟单收益额雷达图占比


@end

