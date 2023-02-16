//
//  TJRBaseManager.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-12-26.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicNameValuePair.h"
#import "HttpBase.h"

static NSString *driverUUID;

@interface TJRBaseManager : NSObject {
	HttpBase *taojinHttpBase;    
}
/**
 *    生成用户的UUID
 *    @returns
 */
+ (NSString *)createDriverUUID;

+ (NSString *)createParams:(NSMutableString*)params;

- (NSDictionary *)fetchUrlFiles:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION;

- (NSString *)fetchUrlParam:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION;

+ (NSString *)fetchUrlParamSocket:(NSString *)header statement:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION;

- (NSString *)fetchUrlWithoutParam:(BasicNameValuePair *)statement, ...NS_REQUIRES_NIL_TERMINATION;

/**
 *  没有参数,直接调用url
 *
 *  @param url url description
 *  @param delegate delegate description
 *  @param httpFinish httpFinish description
 *  @param httpFaild httpFaild description
 */
- (void)doHttpGETForUrl:(NSString *)url delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild;

@end

