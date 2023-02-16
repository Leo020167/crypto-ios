//
//  PurchasesSQL.m
//  TJRtaojinroad
//
//  Created by taojinroad on 15/8/24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "PurchasesSQL.h"
#import "TJRDatabase.h"

@implementation PurchasesSQL

- (BOOL)replaceSql:(NSString*)transactionIdentifier base64EncodedString:(NSString*)base64EncodedString productIdentifier:(NSString*)productIdentifier feedback:(BOOL)feedback transactionDate:(NSString*)transactionDate notifyTime:(NSString*)notifyTime times:(int)times myUserId:(NSString*)myUserId{
    
    __block BOOL isok = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        isok = [db executeUpdate:[NSString stringWithFormat:@"replace into app_purchases(transactionIdentifier,base64EncodedString,productIdentifier,feedback,transactionDate,notifyTime,times,myUserId) VALUES('%@','%@','%@',%d,'%@','%@','%d','%@')",transactionIdentifier,base64EncodedString,productIdentifier,feedback,transactionDate,notifyTime,times,myUserId]];
    }];
    return isok;
}

- (AppPurchases*)selectItemSQl{
    
    __block AppPurchases* item = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from app_purchases where myUserId='%@' and  feedback=%d ORDER BY times asc,transactionDate asc limit 1",ROOTCONTROLLER_USER.userId,0]];
        
        while ([rs next]) {
            item = [[[AppPurchases alloc]init] autorelease];
            item.base64EncodedString = [rs stringForColumn:@"base64EncodedString"];
            item.transactionDate = [rs stringForColumn:@"transactionDate"];
            item.transactionIdentifier = [rs stringForColumn:@"transactionIdentifier"];
            item.productIdentifier = [rs stringForColumn:@"productIdentifier"];
            item.feedback = [rs boolForColumn:@"feedback"];
            item.notifyTime = [rs stringForColumn:@"notifyTime"];
            item.times = [rs intForColumn:@"times"];
        }
        [rs close];
    }];

    return item;
}

- (BOOL)updateSQL:(NSString*)transactionIdentifier feedback:(BOOL)feedback{

    __block BOOL isok = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
         isok = [db executeUpdate:[NSString stringWithFormat:@"update app_purchases set feedback=%d where transactionIdentifier='%@' and myUserId='%@'",feedback,transactionIdentifier,ROOTCONTROLLER_USER.userId]];
    }];
    return isok;
}

- (BOOL)updateNotifyTimeSQL:(NSString*)transactionIdentifier notifyTime:(NSString*)notifyTime times:(int)times{

    __block BOOL isok = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        isok = [db executeUpdate:[NSString stringWithFormat:@"update app_purchases set notifyTime='%@',times='%d' where transactionIdentifier='%@' and myUserId='%@'",notifyTime,times,transactionIdentifier,ROOTCONTROLLER_USER.userId]];
    }];
    return isok;
}

- (void)dealloc {
    [super dealloc];
}

@end
