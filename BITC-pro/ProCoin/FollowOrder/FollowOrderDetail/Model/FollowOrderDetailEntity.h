//
//  FollowOrderDetailEntity.h
//  Cropyme
//
//  Created by Hay on 2019/6/3.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"

//orderDetail =         {
//    balance = "2.1135";
//    copyHeadUrl = "http://192.168.0.223/crpm/images/default_head.png";
//    copyName = inLJ;
//    copyUid = 0;
//    fansCount = 4;
//    holdList =             (
//                            {
//                                amount = "1.85994220";
//                                costPrice = "0.0826";
//                                market = "0.1519";
//                                marketCny = "\U2248\U00a51.06";
//                                price = "0.081689";
//                                profit = "-0.0018";
//                                profitRate = "-1.15";
//                                symbol = ADA;
//                                userId = 5;
//                            }
//                            );
//    holdMarketValue = "2.2655";
//    isDone = 0;
//    maxCopyBalance = "0.5";
//    orderId = 2;
//    profitCash = "0.2655";
//    profitRate = "13.27";
//    score = "10.25";
//    stopLoss = 0;
//    stopLossValue = "\U65e0\U8bbe\U7f6e";
//    stopWin = 0;
//    stopWinValue = "\U65e0\U8bbe\U7f6e";
//    tolBalance = "2.0000";
//    userId = 5;
//};

@interface FollowOrderDetailEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *balance;                      //余额
@property (copy, nonatomic) NSString *followHeadUrl;                //跟随者头像
@property (copy, nonatomic) NSString *followName;                   //跟随者名字
@property (copy, nonatomic) NSString *followUid;                    //跟随者UID
@property (copy, nonatomic) NSString *fansCount;                    //粉丝数量
@property (copy, nonatomic) NSString *holdMarketValue;              //持仓市值
@property (assign, nonatomic) NSInteger isDone;                     //订单状态 0运行中 1正在取消 2已停止跟单
@property (assign, nonatomic) CGFloat doneDegree;                   //停止跟单进度
@property (copy, nonatomic) NSString *maxFollowBalance;             //每次跟单最大金额
@property (copy, nonatomic) NSString *orderId;                      //订单id
@property (copy, nonatomic) NSString *profitCash;                   //持有盈亏额
@property (copy, nonatomic) NSString *profitRate;                   //盈亏比例
@property (copy, nonatomic) NSString *score;                        //得分
@property (assign, nonatomic) CGFloat stopLoss;                     //止损百分比 区间0-1 0为不设置
@property (copy, nonatomic) NSString *stopLossValue;                //止损描述
@property (assign, nonatomic) CGFloat stopWin;                      //止盈百分比 区间0-1 0为不设置
@property (copy, nonatomic) NSString *stopWinValue;                 //止盈描述
@property (copy, nonatomic) NSString *tolBalance;                   //总额
@property (copy, nonatomic) NSString *userId;                       //userId

@end


