//
//  PCPersonalInfoModel.m
//  ProCoin
//
//  Created by Hay on 2020/2/22.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCPersonalInfoModel.h"

//@property (copy, nonatomic) NSString *headUrl;          //头像
//@property (copy, nonatomic) NSString *userId;           //用户id
//@property (copy, nonatomic) NSString *userName;         //用户名称
//@property (copy, nonatomic) NSString *days;             //入驻天数
//@property (copy, nonatomic) NSString *fanNum;           //粉丝数量
//@property (copy, nonatomic) NSString *attentionNum;     //关注数量
//@property (copy, nonatomic) NSString *radarFollowNum;   //跟单人数
//@property (assign, nonatomic) BOOL myIsAttention;    //是否已关注
//@property (assign, nonatomic) BOOL myIsFollow;       //是否已绑定大v
//@property (copy, nonatomic) NSString *correctRate;      //准确率
//@property (copy, nonatomic) NSString *totalProfit;      //总收益
//@property (copy, nonatomic) NSString *monthProfit;      //上月收益
//@property (copy, nonatomic) NSString *describes;        //个人简介
//@property (assign, nonatomic) CGFloat tolRadarWeight ;  //雷达图每一项总分
//@property (assign, nonatomic) CGFloat radarFollowBalanceWeight; //跟单盈利分数
//@property (assign, nonatomic) CGFloat radarProfitRateWeight;    //盈利能力分数
//@property (assign, nonatomic) CGFloat radarFollowProfitRateWeight;  //跟单收益率分数
//@property (assign, nonatomic) CGFloat radarFollowWinRateWeight; //跟单胜率分数
//@property (assign, nonatomic) CGFloat radarFollowNumWeight;     //人气指数分数
//@property (copy, nonatomic) NSString *radarFollowBalance;       //跟单盈利额
//@property (copy, nonatomic) NSString *radarProfitRate;          //跟单盈利能力
//@property (copy, nonatomic) NSString *radarFollowProfitRate;    //跟单收益率
//@property (copy, nonatomic) NSString *radarFollowWinRate;       //跟单胜率
//@property (copy, nonatomic) NSString *recommend;                //推荐简介

@implementation PCPersonalInfoModel

- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.days = [self stringParser:@"days" json:json];
        self.fanNum = [self stringParser:@"fanNum" json:json];
        self.attentionNum = [self stringParser:@"attentionNum" json:json];
        self.radarFollowNum = [self stringParser:@"radarFollowNum" json:json];
        self.myIsAttention = [self boolParser:@"myIsAttention" json:json];
        self.myIsFollow = [self boolParser:@"myIsFollow" json:json];
        self.correctRate = [self stringParser:@"correctRate" json:json];
        self.totalProfit = [self stringParser:@"totalProfit" json:json];
        self.monthProfit = [self stringParser:@"monthProfit" json:json];
        self.describes = [self stringParser:@"describes" json:json];
        self.tolRadarWeight = [self floatParser:@"tolRadarWeight" json:json];
        self.radarFollowBalanceWeight = [self floatParser:@"radarFollowBalanceWeight" json:json];
        self.radarProfitRateWeight = [self floatParser:@"radarProfitRateWeight" json:json];
        self.radarFollowProfitRateWeight = [self floatParser:@"radarFollowProfitRateWeight" json:json];
        self.radarFollowWinRateWeight = [self floatParser:@"radarFollowWinRateWeight" json:json];
        self.radarFollowNumWeight = [self floatParser:@"radarFollowNumWeight" json:json];
        self.radarFollowBalance = [self stringParser:@"radarFollowBalance" json:json];
        self.radarProfitRate = [self stringParser:@"radarProfitRate" json:json];
        self.radarFollowProfitRate = [self stringParser:@"radarFollowProfitRate" json:json];
        self.radarFollowWinRate = [self stringParser:@"radarFollowWinRate" json:json];
        self.recommend = [self stringParser:@"recommend" json:json];
        self.isExpireTime = [self boolParser:@"isExpireTime" json:json];
        self.expireTime = [self stringParser:@"expireTime" json:json];
        self.subFee = [self stringParser:@"subFee" json:json];
        self.subFeeTypeName = [self stringParser:@"subFeeTypeName" json:json];
        self.subNotice = [self stringParser:@"subNotice" json:json];
        self.subFeeTypeUnit = [self stringParser:@"subFeeTypeUnit" json:json];
        self.followNotice = [self stringParser:@"followNotice" json:json];
        self.subIsFee = [self boolParser:@"subIsFee" json:json];
    }
    return self;
}
- (void)dealloc
{
    [_headUrl release];
    [_userId release];
    [_userName release];
    [_days release];
    [_fanNum release];
    [_attentionNum release];
    [_radarFollowNum release];
    [_correctRate release];
    [_totalProfit release];
    [_monthProfit release];
    [_describes release];
    [_radarFollowBalance release];
    [_radarProfitRate release];
    [_radarFollowProfitRate release];
    [_radarFollowWinRate release];
    [_recommend release];
    [_expireTime release];
    [_subFee release];
    [_subFeeTypeName release];
    [_subNotice release];
    [_subFeeTypeUnit release];
    [_followNotice release];
    [super dealloc];
}


@end
