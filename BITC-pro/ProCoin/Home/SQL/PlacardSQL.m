//
//  PlacardSQL.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-3-21.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "PlacardSQL.h"
#import "TJRDatabase.h"

@implementation PlacardSQL

- (BOOL)replacePlacardSQl:(NSString*)placardTime content:(NSString*)content title:(NSString*)title{
    __block BOOL isok = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        isok = [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO placard (placardTime,content,title) VALUES('%@','%@','%@')",placardTime,content,title]];
    }];
    return isok;
}

- (BOOL)replacePlacardSQl:(TJRPlacard*)item{
    if (!item) return NO;
    
    __block BOOL isok = NO;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        isok = [db executeUpdate:[NSString stringWithFormat:@"REPLACE INTO placard (placardTime,content,title) VALUES('%@','%@','%@')",item.placardTime,item.content,item.title]];
    }];
    return isok;
}

- (TJRPlacard*)selectPlacardSQl{
    __block TJRPlacard* item = nil;
    
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        TJRFMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"select * from placard ORDER BY placardTime DESC limit 1"]];
        
        while ([rs next]) {
            item = [[[TJRPlacard alloc]init] autorelease];
            item.placardTime = [rs stringForColumn:@"placardTime"];
            item.content = [rs stringForColumn:@"content"];
            item.title = [rs stringForColumn:@"title"];
        }
    }];
    return item;
}



@end
