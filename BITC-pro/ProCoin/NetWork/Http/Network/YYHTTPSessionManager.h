//
//  YYHTTPSessionManager.h
//  yunyue
//
//  Created by LiuQingying on 2016/12/17.
//  Copyright © 2016年 zhanlijun. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@interface YYHTTPSessionManager : AFHTTPSessionManager
+ (instancetype)shareInstance;
@end
