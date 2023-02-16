//
//  TJRDatabase.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-8-29.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRDatabase.h"
#import "CommonUtil.h"
#import "CircleEntity.h"
#import "CircleChatEntity.h"
#import "CircleBaseDataEntity.h"
#import "PrivateChatDataEntity.h"

NSInteger const NewVersion         = 1;/* 现在的数据库版本号 */
NSString const *TJRDatabaseVersion = @"version_procoin";

//使用替代执行数据库语句时,保存sql和替代对象的Key
NSString const *ExecuteSQLKey      = @"ExecuteSQLKey";
NSString const *ArgumentsKey       = @"ArgumentsKey";

static TJRFMDatabase *database;
static TJRFMDatabaseQueue *dbQueue;

@implementation TJRDatabase

+ (TJRFMDatabase *)shareFMDatabase {
	@synchronized(self) {
		if (database == nil) {

			TJRDatabase *tjr = [[self alloc] init];
            database = [[TJRFMDatabase databaseWithPath:[CommonUtil TTPathForDocumentsResource:kDatabaseFileName]] retain];
			dbQueue = [[TJRFMDatabaseQueue databaseQueueWithPath:[CommonUtil TTPathForDocumentsResource:kDatabaseFileName]] retain];
			NSLog(@"Is SQLite compiled with it's thread safe options turned on %@!", [TJRFMDatabase isSQLiteThreadSafe] ? @"Yes" : @"No");

			if (!dbQueue || ![database open]) {
				NSLog(@"Could not open db.");
				return 0;
			}
			[database setShouldCacheStatements:YES];
			[tjr checkDataBaseVersion];	/* 检查数据库版本 */
			[tjr release];
            
            NSString *dbVersionPath = [CommonUtil TTPathForDocumentsResource:DatabaseVersion];
            NSLog(@"%@",dbVersionPath);

		}
	}
	return database;
}

+ (TJRFMDatabaseQueue *)shareFMDatabaseQueue {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (dbQueue == nil) {
            [TJRDatabase shareFMDatabase];
        }
    });
    
	return dbQueue;
}

#pragma mark - 检查数据库版本
- (void)checkDataBaseVersion {
    NSInteger oldVersion = [self getDataBaseVision];
    if (oldVersion == 0) {
        [self createVisionTables];//创建数据库版本号表,字段,以后就不用文件保存数据库版本号
        NSString *dbVersionPath = [CommonUtil TTPathForDocumentsResource:DatabaseVersion];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:dbVersionPath];
        oldVersion = [[dict objectForKey:@"OldVersion"] intValue];
        [dict release];
    }

	if (oldVersion >= NewVersion) {
		return;	/* 当前版本一样就不做操作 */
	}

	switch (oldVersion) {
		case 0:
            [self createTables];            /* 版本号:1.0.0 */
 
		default:
			break;
	}

    [self updateDataBaseVersion:NewVersion];//更新数据库版本号表里的版本号

}

- (void)createVisionTables {
    NSString *ctrTableSql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@ INTEGER PRIMARY KEY)",TJRDatabaseVersion,TJRDatabaseVersion];
    [database executeUpdate:ctrTableSql];
    NSString *insertInto = [NSString stringWithFormat:@"insert into %@(%@)values(%@)",TJRDatabaseVersion,TJRDatabaseVersion,@"1"];
    [database executeUpdate:insertInto];
    FMDBQuickCheck(![database hadError]);
}

- (NSUInteger)getDataBaseVision {
    NSString *sql = [NSString stringWithFormat:@"select * from %@",TJRDatabaseVersion];
    TJRFMResultSet *rs = [database executeQuery:sql];
    
    if (!rs) return 0;
    
    @try {
        while ([rs next]) {
            return [rs intForColumn:[NSString stringWithFormat:@"%@",TJRDatabaseVersion]];
        }
        
    } @catch(NSException *exception) {
        NSLog(@"解析Redz数据库出错:%@", exception.debugDescription);
    } @finally {
        if (rs) {
            [rs close];
        }
    }
    
    return 0;
}

- (void)updateDataBaseVersion:(NSInteger)version {
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@=%@;",TJRDatabaseVersion,TJRDatabaseVersion,@(version)];
    [database executeUpdate:sql];
    FMDBQuickCheck(![database hadError]);
}

- (void)createTables {
	/* 用户的登录信息表 */
	NSString *ctrTableSql = @"CREATE TABLE IF NOT EXISTS USER(ID INTEGER PRIMARY KEY AUTOINCREMENT, USERACCOUNT TEXT, USERNAME TEXT, USERPWD TEXT, USERID TEXT, LOGINTYPE TEXT,sex TEXT,headurl TEXT,selfDescription TEXT,birthday TEXT,token TEXT,idCertify INTEGER,otcCertify INTEGER,ethAddress TEXT,userRealName TEXT,payPass TEXT,openCopy TEXT,countryCode TEXT,email TEXT)";

	[database executeUpdate:ctrTableSql];
	FMDBQuickCheck(![database hadError]);

	/* 我的消息表 */
	NSString *createSQLMSGStr = @"CREATE TABLE IF NOT EXISTS mymsg(tableId INTEGER PRIMARY KEY AUTOINCREMENT,userId TEXT,msgId TEXT,msgType TEXT,msgTime TEXT,msgLevel INTEGER,tpType INTEGER,headOrLogo TEXT,title TEXT,content TEXT,params TEXT,view TEXT,flag INTEGER,fromUid text)";
	[database executeUpdate:createSQLMSGStr];
	FMDBQuickCheck(![database hadError]);

    /* 公告表 */
    NSString *placardSql = @"create table IF NOT EXISTS placard (placardTime VARCHAR(50) PRIMARY KEY,title VARCHAR(50),content VARCHAR(50))";
    [database executeUpdate:placardSql];
    FMDBQuickCheck(![database hadError]);
    
    /* 用户信息表.记录头像,id,vip等信息 */
    NSString *userInfo = @"CREATE TABLE IF NOT EXISTS user_info(info_user_id VARCHAR(50) PRIMARY KEY,info_user_name TEXT,info_user_level INTEGER,info_header_url TEXT,info_max_header_url TEXT)";
    
    [database executeUpdate:userInfo];
    FMDBQuickCheck(![database hadError]);
    
    /* 新手指南数据库 */
    NSString *createNewbieGuideSQLStr = @"CREATE TABLE IF NOT EXISTS NewbieGuide(ID INTEGER PRIMARY KEY AUTOINCREMENT, NHType TEXT)";
    [database executeUpdate:createNewbieGuideSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /*圈子基本信息*/
    NSString *createCircleSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS circle(circle_id VARCHAR(16) PRIMARY KEY, create_user_id VARCHAR(16),circle_name VARCHAR(20),brief VARCHAR(256),circle_logo VARCHAR(128),create_time VARCHAR(64),circle_bg TEXT,syn_mark INTEGER DEFAULT(0))"];
    [database executeUpdate:createCircleSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /*记录用户加入的圈子*/
    NSString *createUserInCircleSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS circle_my(circle_id VARCHAR(16), my_user_id VARCHAR(16),circle_user_role integer default 0, chat_news_count integer default 0,circle_chat_name VARCHAR(16),circle_sort_time VARCHAR(16), CONSTRAINT circle_my_key PRIMARY KEY (circle_id,my_user_id))"];
    [database executeUpdate:createUserInCircleSQLStr];
    FMDBQuickCheck(![database hadError]);

    /*圈子聊天数据*/
    NSString *createCircleChatSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS circle_chat(circle_id VARCHAR(16),chat_user_id VARCHAR(16),chat_create_time VARCHAR(16),say TEXT,chat_mark INTEGER DEFAULT(0),say_type VARCHAR(16),my_user_id VARCHAR(16),chat_delete BOOLEAN DEFAULT(0),is_read BOOLEAN DEFAULT(0), role_name VARCHAR(16),CONSTRAINT circle_chat_key PRIMARY KEY (circle_id,chat_mark,my_user_id))"];
    [database executeUpdate:createCircleChatSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /*圈子设置数据*/
    NSString *circleSettingSQLStr = @"CREATE TABLE IF NOT EXISTS circle_setting_remind(ID INTEGER PRIMARY KEY AUTOINCREMENT,my_user_id VARCHAR(16),circle_id VARCHAR(16),chat_remind BOOLEAN DEFAULT(0))";
    [database executeUpdate:circleSettingSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /* 私聊主页中的聊天列表 */
    NSString *privateTopicSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS private_topic(chat_user_id VARCHAR(16),chat_create_time VARCHAR(16),chat_topic TEXT,say TEXT,chat_mark TEXT,chat_news INTEGER DEFAULT(0),isPush BOOLEAN DEFAULT(1),my_user_id VARCHAR(16),CONSTRAINT private_topic_key PRIMARY KEY (chat_topic, my_user_id))"];
    [database executeUpdate:privateTopicSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /* 私聊里面的聊天内容 */
    NSString *createPrivateChatSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS private_chat(chat_topic text,chat_user_id VARCHAR(16),say TEXT,chat_mark INTEGER DEFAULT(0),say_type VARCHAR(16),my_user_id VARCHAR(16),chat_delete BOOLEAN DEFAULT(0),is_push BOOLEAN DEFAULT(0),is_read BOOLEAN DEFAULT(0),chat_create_time VARCHAR(16),CONSTRAINT private_chat_key PRIMARY KEY (chat_topic,chat_mark,my_user_id))"];
    [database executeUpdate:createPrivateChatSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /**搜索圈子记录表*/
    NSString *searchDataSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS circle_search(circle_name TEXT,circle_id TEXT,create_user_id TEXT PRIMARY KEY,circle_logo TEXT,search_time TEXT)"];
    [database executeUpdate:searchDataSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /** 搜索用户记录表*/
    NSString *searchUserSQLStr = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS SearchUserDataTable(headUrl TEXT,name TEXT,userId TEXT PRIMARY KEY,updateTime TEXT)"];
    [database executeUpdate:searchUserSQLStr];
    FMDBQuickCheck(![database hadError]);
    
    /** 搜索币种记录表*/
    NSString *createSearchCoinSQLStr = @"CREATE TABLE IF NOT EXISTS SearchCoinDataTable(symbol TEXT PRIMARY KEY,price TEXT,createTime TEXT,marketType TEXT)";
    [database executeUpdate:createSearchCoinSQLStr];
    FMDBQuickCheck(![database hadError]);
}


@end
