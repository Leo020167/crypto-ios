//
//  LoginSQLModel.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-4.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "LoginSQLModel.h"
#import "TJRDatabase.h"
#import "UserInfoSQL.h"

@implementation LoginSQLModel

//存储登陆信息
+ (BOOL) insertLoginInfo:(TJRUser*)user{

    __block BOOL success = NO;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *deleteStr = @"delete from user";
        [db executeUpdate:deleteStr];
    }];
    
    //插入用户的具体个人信息，vip等
    [UserInfoSQL insertOrUpdateUserInfo:user,nil];
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {

        NSString *insertStr = [NSString stringWithFormat:@"insert into USER (userAccount,userName,userPwd,userId,logintype,headurl,sex,selfDescription,birthday,token,otcCertify,idCertify,userRealName,ethAddress,payPass,openCopy,countryCode,email) values ('%@','%@','%@','%@','%@','%@','%@','%@','%@','%@','%d','%@','%@','%@','%@','%@','%@','%@')",user.userAccount,user.name,user.password,user.userId,user.type,user.headurl,user.sex,user.selfDescription,user.birthday,user.token,user.otcCertify,@(user.idCertify),user.userRealName,user.ethAddress,user.payPass,@(user.openFollow),user.countryCode,user.email];
        success = [db executeUpdate:insertStr];
    }];
    
    return success;
}

//更新数据库登陆信息
+ (BOOL) updateLoginInfo:(TJRUser*)user{
    
    //插入用户的具体个人信息
    [UserInfoSQL insertOrUpdateUserInfo:user,nil];
    
    __block BOOL success = NO;

    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *updateStr = [NSString stringWithFormat:@"update USER set userName='%@',headurl='%@',sex='%@',selfDescription='%@',birthday='%@',token = '%@',otcCertify = '%d',idCertify = '%@',userRealName = '%@',ethAddress = '%@',payPass = '%@',openCopy = '%@',countryCode = '%@',email = '%@' where userId ='%@' and logintype = '%@'",user.name,user.headurl,user.sex,user.selfDescription,user.birthday,user.token,user.otcCertify,@(user.idCertify),user.userRealName,user.ethAddress,user.payPass,@(user.openFollow),user.countryCode,user.email,user.userId,user.type];
        success = [db executeUpdate:updateStr];
    }];
    return success;
}



//获取登陆信息
+ (TJRUser*) selectLoginInfo{

    __block TJRUser *user = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        //联表查询，返回用户的具体个人信息
        NSString *sql = [UserInfoSQL createSqlWithResult:@"*" userIdName:@"userId" tableName:@"USER" condition:nil];
        TJRFMResultSet *rs = [db executeQuery:sql];
        
        while ([rs next]){
            user = [[[TJRUser alloc]init] autorelease];
            user.userAccount = [rs stringForColumn:@"userAccount"];
            user.password = [rs stringForColumn:@"userPwd"];
            user.userId = [rs stringForColumn:@"userId"];
            user.type = [rs stringForColumn:@"logintype"];
            user.sex = [rs stringForColumn:@"sex"];
            user.selfDescription = [rs stringForColumn:@"selfDescription"];
            user.birthday = [rs stringForColumn:@"birthday"];
            user.token = [rs stringForColumn:@"token"];
            user.idCertify = [rs intForColumn:@"idCertify"];
            user.otcCertify = [rs boolForColumn:@"otcCertify"];
            user.ethAddress = [rs stringForColumn:@"ethAddress"];
            user.userRealName = [rs stringForColumn:@"userRealName"];
            user.payPass = [rs stringForColumn:@"payPass"];
            user.openFollow = [rs intForColumn:@"openCopy"];
            user.userLevel = [UserInfoSQL getUserLevelFromUserInfo:rs];
            user.name = [UserInfoSQL getUserNameFromUserInfo:rs oldUserName:@"userName"];
            user.headurl = [UserInfoSQL getHeaderUrlFromUserInfo:rs oldHeaderUrl:@"headurl"];
            user.countryCode = [rs stringForColumn:@"countryCode"];
            user.email = [rs stringForColumn:@"email"];
        }
        [rs close];
    }];
    
    return user;
}

//清除登陆信息
+ (BOOL) deleteLoginInfo{
    __block BOOL success = NO;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *deleteStr = @"delete from USER";
        success = [db executeUpdate:deleteStr];
    }];
    return success;
}

//更新新浪登陆的token
+ (BOOL)updateSinaToken:(NSString*)token{
    __block BOOL success = NO;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        success = [db executeUpdate:[NSString stringWithFormat:@"update USER set userPwd='%@'",token]];
    }];
    
    return success;
}
@end
