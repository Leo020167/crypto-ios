//
//  YYRequestUtility.h
//  yunyue
//
//  Created by LiuQingying on 2016/12/17.
//  Copyright © 2016年 zhanlijun. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BasicNameValuePair.h"
#import "TJRBaseManager.h"
#import "TJRDefineManage.h"
@class YYRequestUtility;
typedef void (^requestSuccessHandleBlock)(NSDictionary *responseDict);
typedef void (^requestProgressHandleBlock)(NSProgress *progress);
typedef void (^requestFailedHandleBlock)(NSError *error);

@interface YYRequestUtility : NSObject
/**
 请求任务
 */
@property (nonatomic, strong) NSURLSessionTask *sessionTask;
- (void)start;
- (void)stop;
+ (void)cancleAllRequest;

/**
 get 常规请求
 */
+ (YYRequestUtility *)get:(NSString *)urlString
               parameters:(NSDictionary *)parameters
                 progress:(requestProgressHandleBlock)progress
                  success:(requestSuccessHandleBlock)sucess
                  failure:(requestFailedHandleBlock)failure;
/**
 Get 请求默认带 version、timestamp、nonce、token、sign五个参数
 */
+ (YYRequestUtility *)Get:(NSString *)urlString
            addParameters:(NSDictionary *)parameters
                 progress:(requestProgressHandleBlock)progress
                  success:(requestSuccessHandleBlock)sucess
                  failure:(requestFailedHandleBlock)failure;
/**
 post 常规请求
 */
+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure;
/**
 Post 请求默认带 version、timestamp、nonce、token、sign五个参数
 */
+ (YYRequestUtility *)Post:(NSString *)urlString
                addParameters:(NSDictionary *)parameters
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure;
+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                imageArray:(NSArray *)imageArray
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure;

/**
 post 常规请求
 */
+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                    header:(NSDictionary *)header
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure;
@end
