//
//  PCHomeUserFollowOrderInfoModel.h
//  ProCoin
//
//  Created by Hay on 2020/2/27.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface PCHomeUserFollowOrderInfoModel : TJRBaseEntity

@property (copy, nonatomic) NSString *dvUid;            //大vid
@property (assign, nonatomic) BOOL isOpen;              //是否开通跟单
@property (copy, nonatomic) NSString *multiple;         //跟单倍数
@property (copy, nonatomic) NSString *dvUserName;       //大v姓名
@property (copy, nonatomic) NSString *dvHeadUrl;        //大v头像
@property (copy, nonatomic) NSString *userId;           //用户id

/// 1数字  2国际期货 3外汇
@property (nonatomic, assign) NSInteger type;


@end

