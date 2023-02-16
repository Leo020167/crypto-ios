//
//  PCPersonalInfoModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/22.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"

NS_ASSUME_NONNULL_BEGIN

@interface PCPersonalInfoModel : TJRBaseEntity

@property (copy, nonatomic) NSString *headUrl;          //头像
@property (copy, nonatomic) NSString *userId;           //用户id
@property (copy, nonatomic) NSString *userName;         //用户名称
@property (copy, nonatomic) NSString *days;             //入驻天数
@property (copy, nonatomic) NSString *fanNum;           //粉丝数量
@property (copy, nonatomic) NSString *attentionNum;     //关注数量
@property (copy, nonatomic) NSString *radarFollowNum;   //跟单人数
@property (assign, nonatomic) BOOL myIsAttention;    //是否已订阅
@property (assign, nonatomic) BOOL myIsFollow;       //是否已绑定大v
@property (copy, nonatomic) NSString *correctRate;      //准确率
@property (copy, nonatomic) NSString *totalProfit;      //总收益
@property (copy, nonatomic) NSString *monthProfit;      //上月收益
@property (copy, nonatomic) NSString *describes;        //个人简介
@property (assign, nonatomic) CGFloat tolRadarWeight ;  //雷达图每一项总分
@property (assign, nonatomic) CGFloat radarFollowBalanceWeight; //跟单盈利分数
@property (assign, nonatomic) CGFloat radarProfitRateWeight;    //盈利能力分数
@property (assign, nonatomic) CGFloat radarFollowProfitRateWeight;  //跟单收益率分数
@property (assign, nonatomic) CGFloat radarFollowWinRateWeight; //跟单胜率分数
@property (assign, nonatomic) CGFloat radarFollowNumWeight;     //人气指数分数
@property (copy, nonatomic) NSString *radarFollowBalance;       //跟单盈利额
@property (copy, nonatomic) NSString *radarProfitRate;          //跟单盈利能力
@property (copy, nonatomic) NSString *radarFollowProfitRate;    //跟单收益率
@property (copy, nonatomic) NSString *radarFollowWinRate;       //跟单胜率
@property (copy, nonatomic) NSString *recommend;                //推荐简介
@property (assign, nonatomic) BOOL isExpireTime;                //是否订阅过期
@property (copy, nonatomic) NSString *expireTime;               //订阅过期时间
@property (copy, nonatomic) NSString *subFee;                   //订阅价格
@property (copy, nonatomic) NSString *subFeeTypeName;           //订阅价格描述
@property (copy, nonatomic) NSString *subNotice;                //订阅注意
@property (copy, nonatomic) NSString *subFeeTypeUnit;           //单位
@property (copy, nonatomic) NSString *followNotice;             //跟单绑定提示
@property (assign, nonatomic) BOOL subIsFee;                    //是否收费订阅

@end

NS_ASSUME_NONNULL_END
