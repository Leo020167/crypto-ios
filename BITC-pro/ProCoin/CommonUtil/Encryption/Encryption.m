//
//  Encryption.m
//  MD5
//
//  Created by zhengmj on 11-8-6.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "Encryption.h"
#import <CommonCrypto/CommonDigest.h>
#import <string.h>

@implementation Encryption

-(NSString *) rhex:(int)num {
    NSString *hex =@"0123456789aBcDeF";
    NSMutableString *teststr = [[NSMutableString alloc]initWithCapacity:2];
    for (int j = 0 ; j <= 3; j++) {
        [teststr appendString:[NSString stringWithFormat:@"%c",[hex characterAtIndex:((num >> (j * 8 + 4)) & 0x0F)]]];
        [teststr appendString:[NSString stringWithFormat:@"%c",[hex characterAtIndex:((num >> (j * 8)) & 0x0F)]]];
    }
    [hex release];
    NSString* str = [NSString stringWithString:teststr];
    TT_RELEASE_SAFELY(teststr);
    return str;
}

long long add(long long x, long long y) {
    return ((x & 0x7FFFFFFF) + (y & 0x7FFFFFFF)) ^ (x & 0x80000000)^ (y & 0x80000000);
}
int rol(int num, int cnt) {
    // >>> 修改成 >>
    unsigned int unint= (unsigned)num >> (32 - cnt) ;
    return (num << cnt) | unint;
}

long long cmn(long long q, long long a, long long b, int x, int s, long long t) {
    return add(rol((int)add(add(a, q), add(x, t)), s), b);
}

long long ff(long long a, long long b, long long c, long long d, int x, int s, long long t) {
    return cmn((b & c) | ((~b) & d), a, b, x, s, t);
}

long long gg(long long a, long long b, long long c, long long d, int x, int s, long long t) {
    return cmn((b & d) | (c & (~d)), a, b, x, s, t);
}

long long hh(long long a, long long b, long long c, long long d, int x, int s, long long t) {
    return cmn(b ^ c ^ d, a, b, x, s, t);
}

long long ii(long long a, long long b, long long c, long long d, int x, int s, long long t) {
    return cmn(c ^ (b | (~d)), a, b, x, s, t);
}

void str2blks_MD5(NSString *Str , int md5x[]) {
    int nblk = (((int)[Str length]+8) >> 6)+1;
    int i = 0;
    for (i = 0; i < nblk * 16; i++) {
        md5x[i] =0;
    }
    for (i = 0; i < [Str length]; i++) {
        md5x[i >> 2] |=[Str characterAtIndex:i] << ((i % 4) *8);
    }
    md5x[i >> 2] |=  0x80 << ((i%4) *8);
    md5x[nblk * 16 -2 ]= (int)[Str length] * 8;
}

//重新计算md5的位置
-(NSString *) calcMD5:(NSString *)Str {
    int nblk = (((int)[Str length]+8) >> 6)+1;
    int x[nblk * 16];
    str2blks_MD5(Str, x);
    long long a = 0x67452301;
    long long b = 0xEFCDAB89;
    long long c = 0x98BADCFE;
    long long d = 0x10325476;
    for (int i = 0; i < (sizeof(x)/sizeof(int)); i += 16){
        long long olda = a;
        long long oldb = b;
        long long oldc = c;
        long long oldd = d;
        a = ff(a, b, c, d, x[i + 0], 7, 0xD76AA478);
        d = ff(d, a, b, c, x[i + 1], 12, 0xE8C7B756);
        c = ff(c, d, a, b, x[i + 2], 17, 0x242070DB);
        b = ff(b, c, d, a, x[i + 3], 22, 0xC1BDCEEE);
        a = ff(a, b, c, d, x[i + 4], 7, 0xF57C0FAF);
        d = ff(d, a, b, c, x[i + 5], 12, 0x4787C62A);
        c = ff(c, d, a, b, x[i + 6], 17, 0xA8304613);
        b = ff(b, c, d, a, x[i + 7], 22, 0xFD469501);
        a = ff(a, b, c, d, x[i + 8], 7, 0x698098D8);
        d = ff(d, a, b, c, x[i + 9], 12, 0x8B44F7AF);
        c = ff(c, d, a, b, x[i + 10], 17, 0xFFFF5BB1);
        b = ff(b, c, d, a, x[i + 11], 22, 0x895CD7BE);
        a = ff(a, b, c, d, x[i + 12], 7, 0x6B901122);
        d = ff(d, a, b, c, x[i + 13], 12, 0xFD987193);
        c = ff(c, d, a, b, x[i + 14], 17, 0xA679438E);
        b = ff(b, c, d, a, x[i + 15], 22, 0x49B40821);
        
        a = gg(a, b, c, d, x[i + 1], 5, 0xF61E2562);
        d = gg(d, a, b, c, x[i + 6], 9, 0xC040B340);
        c = gg(c, d, a, b, x[i + 11], 14, 0x265E5A51);
        b = gg(b, c, d, a, x[i + 0], 20, 0xE9B6C7AA);
        a = gg(a, b, c, d, x[i + 5], 5, 0xD62F105D);
        d = gg(d, a, b, c, x[i + 10], 9, 0x02441453);
        c = gg(c, d, a, b, x[i + 15], 14, 0xD8A1E681);
        b = gg(b, c, d, a, x[i + 4], 20, 0xE7D3FBC8);
        a = gg(a, b, c, d, x[i + 9], 5, 0x21E1CDE6);
        d = gg(d, a, b, c, x[i + 14], 9, 0xC33707D6);
        c = gg(c, d, a, b, x[i + 3], 14, 0xF4D50D87);
        b = gg(b, c, d, a, x[i + 8], 20, 0x455A14ED);
        a = gg(a, b, c, d, x[i + 13], 5, 0xA9E3E905);
        d = gg(d, a, b, c, x[i + 2], 9, 0xFCEFA3F8);
        c = gg(c, d, a, b, x[i + 7], 14, 0x676F02D9);
        b = gg(b, c, d, a, x[i + 12], 20, 0x8D2A4C8A);
        
        a = hh(a, b, c, d, x[i + 5], 4, 0xFFFA3942);
        d = hh(d, a, b, c, x[i + 8], 11, 0x8771F681);
        c = hh(c, d, a, b, x[i + 11], 16, 0x6D9D6122);
        b = hh(b, c, d, a, x[i + 14], 23, 0xFDE5380C);
        a = hh(a, b, c, d, x[i + 1], 4, 0xA4BEEA44);
        d = hh(d, a, b, c, x[i + 4], 11, 0x4BDECFA9);
        c = hh(c, d, a, b, x[i + 7], 16, 0xF6BB4B60);
        b = hh(b, c, d, a, x[i + 10], 23, 0xBEBFBC70);
        a = hh(a, b, c, d, x[i + 13], 4, 0x289B7EC6);
        d = hh(d, a, b, c, x[i + 0], 11, 0xEAA127FA);
        c = hh(c, d, a, b, x[i + 3], 16, 0xD4EF3085);
        b = hh(b, c, d, a, x[i + 6], 23, 0x04881D05);
        a = hh(a, b, c, d, x[i + 9], 4, 0xD9D4D039);
        d = hh(d, a, b, c, x[i + 12], 11, 0xE6DB99E5);
        c = hh(c, d, a, b, x[i + 15], 16, 0x1FA27CF8);
        b = hh(b, c, d, a, x[i + 2], 23, 0xC4AC5665);
        
        a = ii(a, b, c, d, x[i + 0], 6, 0xF4292244);
        d = ii(d, a, b, c, x[i + 7], 10, 0x432AFF97);
        c = ii(c, d, a, b, x[i + 14], 15, 0xAB9423A7);
        b = ii(b, c, d, a, x[i + 5], 21, 0xFC93A039);
        a = ii(a, b, c, d, x[i + 12], 6, 0x655B59C3);
        d = ii(d, a, b, c, x[i + 3], 10, 0x8F0CCC92);
        c = ii(c, d, a, b, x[i + 10], 15, 0xFFEFF47D);
        b = ii(b, c, d, a, x[i + 1], 21, 0x85845DD1);
        a = ii(a, b, c, d, x[i + 8], 6, 0x6FA87E4F);
        d = ii(d, a, b, c, x[i + 15], 10, 0xFE2CE6E0);
        c = ii(c, d, a, b, x[i + 6], 15, 0xA3014314);
        b = ii(b, c, d, a, x[i + 13], 21, 0x4E0811A1);
        a = ii(a, b, c, d, x[i + 4], 6, 0xF7537E82);
        d = ii(d, a, b, c, x[i + 11], 10, 0xBD3AF235);
        c = ii(c, d, a, b, x[i + 2], 15, 0x2AD7D2BB);
        b = ii(b, c, d, a, x[i + 9], 21, 0xEB86D391);
        a = add(a, olda);
        b = add(b, oldb);
        c = add(c, oldc);
        d = add(d, oldd);
    }
    NSMutableString *reStr = [[NSMutableString alloc]initWithCapacity:2];
    
    [reStr appendFormat:@"%@",[self rhex:(int)a]];
    [reStr appendFormat:@"%@",[self rhex:(int)b]];
    [reStr appendFormat:@"%@",[self rhex:(int)c]];
    [reStr appendFormat:@"%@",[self rhex:(int)d]];

    NSString* str = [NSString stringWithString:reStr];
    TT_RELEASE_SAFELY(reStr);
    return str;
}

-(NSString *) toUpperStr:(NSString *)Str {
    if (Str.length<2)return @"";
    NSString *reStr;
    NSMutableString *sendStr= [[[NSMutableString alloc] initWithCapacity:2]autorelease];
    reStr = [[[Str substringFromIndex:2] uppercaseString]copy];
    [sendStr appendFormat:@"%@",[Str substringToIndex:2]];
    [sendStr appendFormat:@"%@",reStr];
    [reStr release];
    return sendStr;
}

-(NSString *) toLowerStr:(NSString *)Str {
    NSString *reStr;
    NSMutableString *sendStr= [[[NSMutableString alloc] initWithCapacity:2]autorelease];
    reStr = [[Str lowercaseString] copy];
    [sendStr appendFormat:@"%@",reStr];
    [reStr release];
    return sendStr;
}

-(NSString *)createKL:(NSString *)inStr {
    if (inStr == nil) {
        return @"";
    }
    int len = (int)[inStr length];
    int minlen = len -1;
    char a[len];
    char b[minlen];
    strcpy(a, (char *) [inStr UTF8String]);
    if ([inStr length] >1 ) {
        char t =a[0];
        for (int i = 0; i < minlen; i++) {
            int j = i+1;
            char temp = (char)(a[j] & t);
            b[i] = (int)temp;
        }
        unsigned char result[32];
        CC_MD5( b, (CC_LONG)sizeof(b), result );
        return [NSString stringWithFormat:
                @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                result[0], result[1], result[2], result[3],
                result[4], result[5], result[6], result[7],
                result[8], result[9], result[10], result[11],
                result[12], result[13], result[14], result[15]
                ];
    }else {
        return @"";
    }
    
}

/**
 * Redz专用MD5加密，特殊移位处理
 *
 *  @param Str 需加密字符串
 *
 *  @return 返回加密字符串
 */
-(NSString *)toMd5Str:(NSString *)Str {
    NSString * ss = [self md5:Str].uppercaseString;
    return  ss;
}

/**
 *  网上通用MD5加密
 *
 *  @param str 需加密字符串
 *
 *  @return 返回加密字符串
 */
-(NSString *)md5:(NSString *)str {
    
    const char *ptr = [str UTF8String];
    
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    CC_MD5(ptr, (CC_LONG)strlen(ptr), md5Buffer);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}


@end
