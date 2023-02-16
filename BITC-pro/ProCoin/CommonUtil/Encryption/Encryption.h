//
//  Encryption.h
//  MD5
//
//  Created by zhengmj on 11-8-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Encryption : NSObject{
    
}

-(NSString *)toMd5Str : (NSString *) Str;

-(NSString *)md5 :(NSString *) Str;

-(NSString *)createKL :(NSString *)inStr;

-(NSString *)toUpperStr : (NSString *) Str;

-(NSString *)toLowerStr:(NSString *)Str;

-(NSString *)calcMD5 :(NSString *) Str;

void str2blks_MD5 (NSString *Str , int md5x[]);// 和 a[]的写法是一样的，这个是指针的概念

-(NSString *) rhex :(int) num;


long long add(long long x, long long y);
int rol(int num, int cnt);
long long cmn(long long q, long long a, long long b, int x, int s, long long t);
long long ff(long long a, long long b, long long c, long long d, int x, int s, long long t);
long long gg(long long a, long long b, long long c, long long d, int x, int s, long long t);
long long hh(long long a, long long b, long long c, long long d, int x, int s, long long t);
long long ii(long long a, long long b, long long c, long long d, int x, int s, long long t);

@end
