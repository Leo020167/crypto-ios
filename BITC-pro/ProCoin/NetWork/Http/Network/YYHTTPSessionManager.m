//
//  YYHTTPSessionManager.m
//  yunyue
//
//  Created by LiuQingying on 2016/12/17.
//  Copyright © 2016年 zhanlijun. All rights reserved.
//

#import "YYHTTPSessionManager.h"

@implementation YYHTTPSessionManager
+ (instancetype)shareInstance{
    static YYHTTPSessionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [YYHTTPSessionManager manager];
    });
    return instance;
}

@end
