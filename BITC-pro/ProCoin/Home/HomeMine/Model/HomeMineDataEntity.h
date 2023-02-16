//
//  HomeMineDataEntity.h
//  Cropyme
//
//  Created by Hay on 2019/7/19.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface HomeMineDataEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *fansCount;                    //粉丝人数
@property (copy, nonatomic) NSString *followCount;                  //关注人数
@property (copy, nonatomic) NSString *followNum;                    //跟单人数
@property (copy, nonatomic) NSString *byyAmount;                    //byy资产
@property (copy, nonatomic) NSString *usdtBalance;                  //USDT余额
@property (copy, nonatomic) NSString *abilityValue;                 //能力
@property (assign,  nonatomic) NSInteger openFollow;                //是否开通cropyme,0未开通，1为已开通
@property (copy, nonatomic) NSString *predictProfitShare;           //预计跟单分成
@property (copy, nonatomic) NSString *totalProfitShare;             //跟单总净分成
@property (copy, nonatomic) NSString *score;                        //得分
@property (copy, nonatomic) NSString *shareUrl;                     //分享链接
@property (copy, nonatomic) NSString *latestMsgTitle;               //最新一条消息

/// 未读消息数量
@property (nonatomic, assign) NSInteger msgCount;
@property (copy, nonatomic) NSString *helpCenterUrl;                //帮助中心
@property (copy, nonatomic) NSString *aboutUsUrl;                //关于我们
@property (copy, nonatomic) NSString *symbol;                       //币种
@property (copy, nonatomic) NSString *applyCoinUrl;                 //上币链接
@property (copy, nonatomic) NSString *equityLevel;                  //权益说明
@property (copy, nonatomic) NSString *coinApplyTip;                 //申请币说明提示

@end


