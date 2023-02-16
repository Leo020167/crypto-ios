//
//  FollowOrderDetailEntity.m
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "FollowOrderDetailEntity.h"

//@property (copy, nonatomic) NSString *balance;                      //余额
//@property (copy, nonatomic) NSString *followHeadUrl;                //跟随者头像
//@property (copy, nonatomic) NSString *followName;                   //跟随者名字
//@property (copy, nonatomic) NSString *followUid;                    //跟随者UID
//@property (copy, nonatomic) NSString *fansCount;                    //粉丝数量
//@property (copy, nonatomic) NSString *holdMarketValue;              //持仓市值
//@property (assign, nonatomic) BOOL isDone;                          //订单状态 0运行中 1已取消
//@property (copy, nonatomic) NSString *maxFollowBalance;             //每次跟单最大金额
//@property (copy, nonatomic) NSString *orderId;                      //订单id
//@property (copy, nonatomic) NSString *profitCash;                   //持有盈亏额
//@property (copy, nonatomic) NSString *profitRate;                   //盈亏比例
//@property (copy, nonatomic) NSString *score;                        //得分
//@property (assign, nonatomic) CGFloat stopLoss;                     //止损百分比 区间0-1 0为不设置
//@property (copy, nonatomic) NSString *stopLossValue;                //止损描述
//@property (assign, nonatomic) CGFloat stopWin;                      //止盈百分比 区间0-1 0为不设置
//@property (copy, nonatomic) NSString *stopWinValue;                 //止盈描述
//@property (copy, nonatomic) NSString *tolBalance;                   //总额
//@property (copy, nonatomic) NSString *userId;                       //userId

@implementation FollowOrderDetailEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.balance = [self stringParser:@"balance" json:json];
        self.followHeadUrl = [self stringParser:@"copyHeadUrl" json:json];
        self.followName = [self stringParser:@"copyName" json:json];
        self.followUid = [self stringParser:@"copyUid" json:json];
        self.fansCount = [self stringParser:@"fansCount" json:json];
        self.holdMarketValue = [self stringParser:@"holdMarketValue" json:json];
        self.isDone = [self integerParser:@"isDone" json:json];
        self.doneDegree = [self floatParser:@"doneDegree" json:json];
        self.maxFollowBalance = [self stringParser:@"maxCopyBalance" json:json];
        self.orderId = [self stringParser:@"orderId" json:json];
        self.profitCash = [self stringParser:@"profitCash" json:json];
        self.profitRate = [self stringParser:@"profitRate" json:json];
        self.score = [self stringParser:@"score" json:json];
        self.stopLoss = [self doubleParser:@"stopLoss" json:json];
        self.stopLossValue = [self stringParser:@"stopLossValue" json:json];
        self.stopWin = [self doubleParser:@"stopWin" json:json];
        self.stopWinValue = [self stringParser:@"stopWinValue" json:json];
        self.tolBalance = [self stringParser:@"tolBalance" json:json];
        self.userId = [self stringParser:@"userId" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_balance release];
    [_followHeadUrl release];
    [_followName release];
    [_followUid release];
    [_fansCount release];
    [_holdMarketValue release];
    [_maxFollowBalance release];
    [_orderId release];
    [_profitCash release];
    [_profitRate release];
    [_score release];
    [_stopLossValue release];
    [_stopWinValue release];
    [_tolBalance release];
    [_userId release];  
    [super dealloc];
}


@end
