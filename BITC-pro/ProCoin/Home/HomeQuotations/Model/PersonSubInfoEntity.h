//
//  PersonSubInfoEntity.h
//  Cropyme
//
//  Created by Hay on 2019/9/16.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface PersonSubInfoEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *holdAmount;       //持有数量
@property (copy, nonatomic) NSString *myEquityLevel;    //权益等级
@property (copy, nonatomic) NSString *myEquityTip;      //权益提示
@property (copy, nonatomic) NSString *repoAmount;       //可认购数量
@property (copy, nonatomic) NSString *subUrl;           //权益说明url
@property (assign, nonatomic) BOOL isOpenBuy;           //是否能认购
@property (assign, nonatomic) BOOL isOpenTrade;         //是否能交易
@property (copy, nonatomic) NSString *timeTips;         //时间提示语
@property (copy, nonatomic) NSString *countDownTimestamp;   //结束时间
@property (copy, nonatomic) NSString *coinSubState;          //tabBar提示
@property (copy, nonatomic) NSString *btnText;              //按钮文字

@end


