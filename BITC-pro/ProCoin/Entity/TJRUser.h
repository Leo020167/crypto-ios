//
//  TJRUser.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12-8-28.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

typedef enum
{
    IDCERTIFY_UN_VERIFY = 0,                                   //未认证
    IDCERTIFY_IS_VERIFY,                                       //已认证
    IDCERTIFY_VERIFYING,                                       //认证中
    IDCERTIFY_UNPASS                                           //不通过
    
}IDCERTIFYTYPE;

@interface TJRUser : UserInfo {

}

@property (nonatomic, copy) NSString *userAccount;          // 登录用户账号
@property (nonatomic, copy) NSString *type;                 // 登录方式，mb代表手机
@property (nonatomic, copy) NSString *sex;                  // 性别，0代表女性，1代表男性
@property (nonatomic, copy) NSString *selfDescription;      // 自我描述
@property (nonatomic, copy) NSString *password;             // 密码
@property (nonatomic, assign) NSInteger idCertify;          // 实名认证标识
@property (nonatomic, assign) BOOL  otcCertify;             // OTC认证标识
@property (nonatomic, copy) NSString *token;                // 登录标识
@property (nonatomic, copy) NSString *userRealName;         // 认证姓名
@property (nonatomic, copy) NSString *birthday;             // 生日日期
@property (nonatomic, copy) NSString *ethAddress;           // 以太坊地址
@property (nonatomic, copy) NSString *payPass;              // 支付密码
@property (nonatomic, assign) NSInteger openFollow;         // 0为未开通cropyme，1为开通cropyme
@property (copy, nonatomic) NSString *countryCode;          //手机号码区号
@property (nonatomic, copy) NSString *email;                // 绑定邮箱

@property (nonatomic, copy) NSString *phone;                // 手机号码

@end

