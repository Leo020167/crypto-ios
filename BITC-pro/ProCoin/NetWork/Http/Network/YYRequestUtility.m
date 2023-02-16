//
//  YYRequestUtility.m
//  yunyue
//
//  Created by LiuQingying on 2016/12/17.
//  Copyright © 2016年 zhanlijun. All rights reserved.
//

#import "YYRequestUtility.h"
#import "YYHTTPSessionManager.h"
#import "LanguageManager.h"
#import "CommonUtil.h"
#import "RootController.h"
#import "URLParser.h"
@implementation YYRequestUtility
- (void)start{
    
    if (self.sessionTask) {
        [self.sessionTask resume];
    }
}
- (void)stop{
    if (self.sessionTask) {
        [self.sessionTask cancel];
    }
}
+ (void)cancleAllRequest{
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
    [manager.operationQueue cancelAllOperations];
}
+ (YYRequestUtility *)get:(NSString *)urlString
               parameters:(NSDictionary *)parameters
                 progress:(requestProgressHandleBlock)progress
                  success:(requestSuccessHandleBlock)sucess
                  failure:(requestFailedHandleBlock)failure{
    
    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/plain", @"text/html", @"application/json", @"text/json", @"text/javascript", nil];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    
    requestProxy.sessionTask = [manager GET:urlString parameters:parameters headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
        
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if (sucess) {
                sucess(dict);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"%@",error.description);
        }
    }];
    
    return requestProxy;
}
+ (YYRequestUtility *)Get:(NSString *)urlString
            addParameters:(NSDictionary *)parameters
                 progress:(requestProgressHandleBlock)progress
                  success:(requestSuccessHandleBlock)sucess
                  failure:(requestFailedHandleBlock)failure{
         
    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    manager.requestSerializer.timeoutInterval = 15;
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json" ,@"text/javascript", nil];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    
    NSString *driverUUID = [TJRBaseManager createDriverUUID];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (parameters) {
        [dict addEntriesFromDictionary:parameters];
    }
    if (TTIsStringWithAnyText(driverUUID)) {
        [dict setObject:driverUUID forKey:@"uniqkeyid"];
        [dict setObject:@"iphone" forKey:@"platform"];
        [dict setObject:TJRAppVersion forKey:@"version"];
        [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] forKey:@"bundleId"];
        [dict setObject:RedzAPIKey forKey:@"apiKey"];
        //[dict setObject: [LanguageManager abridgeCode] forKey:@"lang"];
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId) && ![parameters.allKeys containsObject:@"userId"]) {
            [dict setObject:ROOTCONTROLLER_USER.userId forKey:@"userId"];
        }
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.token)) {
            [dict setObject:ROOTCONTROLLER_USER.token forKey:@"token"];
        }
    }
    
    NSArray *keys = [dict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *values = [[[NSMutableString alloc] init]autorelease];
    for (NSString *key in sortedArray) {
        NSString* value = [NSString stringWithFormat:@"%@", dict[key]];
        [values appendString:value];
    }
    NSString* sign = [CommonUtil getMD5:[NSString stringWithFormat:@"%@%@",values,RedzAPISecret]];
    [dict setObject:[NSString stringWithFormat:@"%@", sign.uppercaseString] forKey:@"sign"];
    
    requestProxy.sessionTask = [manager GET:[NSString stringWithFormat:@"%@%@", urlApi, urlString] parameters:dict headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            
            if (sucess) {
                sucess(dict);
                
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"%@",error.description);
        }
        
    }];
    
    return requestProxy;
    
}
+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure{
    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json" ,@"text/javascript", nil];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    requestProxy.sessionTask = [manager POST:urlString parameters:parameters  headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if (sucess) {
                sucess(dict);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"%@",error.description);
        }
        
    }];
    return requestProxy;
}
+ (YYRequestUtility *)Post:(NSString *)urlString
             addParameters:(NSDictionary *)parameters
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure{

    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
   
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    
    
    NSString *ip = [[NSUserDefaults standardUserDefaults] objectForKey:@"ipInfo"];
    NSString *urlApi = [NSString stringWithFormat:@"http://api.%@/procoin/", ip];
    if ([urlString containsString:@"quote/homePage.do"] || [urlString containsString:@"quote/marketData.do"] || [urlString containsString:@"quote/cloutData"]) {
        urlApi = [NSString stringWithFormat:@"http://market.%@/procoin-market/", ip];
    }
    
    NSString *driverUUID = [TJRBaseManager createDriverUUID];
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (parameters) {
        [dict addEntriesFromDictionary:parameters];
    }
    if (TTIsStringWithAnyText(driverUUID)) {
        [dict setObject:driverUUID forKey:@"uniqkeyid"];
        [dict setObject:@"iphone" forKey:@"platform"];
        [dict setObject:TJRAppVersion forKey:@"version"];
        [dict setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"] forKey:@"bundleId"];
        [dict setObject:RedzAPIKey forKey:@"apiKey"];
        //[dict setObject: [LanguageManager abridgeCode] forKey:@"lang"];
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.userId) && ![parameters.allKeys containsObject:@"userId"]) {
            [dict setObject:ROOTCONTROLLER_USER.userId forKey:@"userId"];
        }
        if (TTIsStringWithAnyText(ROOTCONTROLLER_USER.token)) {
            [dict setObject:ROOTCONTROLLER_USER.token forKey:@"token"];
        }
        
    }
    
    NSArray *keys = [dict allKeys];
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *values = [[NSMutableString alloc] init];
    for (NSString *key in sortedArray) {
        NSString *value = [NSString stringWithFormat:@"%@", dict[key]];
        [values appendString:value];
    }
    NSString* sign = [CommonUtil getMD5:[NSString stringWithFormat:@"%@%@",values,RedzAPISecret]];
    [dict setObject:sign.uppercaseString forKey:@"sign"];
    
    NSLog(@"请求地址：%@%@\n 请求参数：%@", urlApi, urlString, dict);
    requestProxy.sessionTask = [manager POST:[NSString stringWithFormat:@"%@%@", urlApi, urlString] parameters:dict headers:nil progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
       
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            NSString *code = [NSString stringWithFormat:@"%@", responseObject[@"code"]];
            if ([code isEqualToString:@"40008"] || [code isEqualToString:@"40009"]) {
                [ROOTCONTROLLER logout];
            }
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            NSString *code = [NSString stringWithFormat:@"%@", dict[@"code"]];
            if ([code isEqualToString:@"40008"] || [code isEqualToString:@"40009"]) {
                [ROOTCONTROLLER logout];
            }
            if (sucess) {
                sucess(dict);
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"error ： %@",error);
        }
        
    }];
    return requestProxy;
    
}
+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                imageArray:(NSArray *)imageArray
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure{
    
    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 60;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    
    requestProxy.sessionTask = [manager POST:urlString parameters:parameters  headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        int i = 0;
        for (UIImage *image in imageArray) {
            
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyYSJJddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *fileName = [NSString stringWithFormat:@"%@.jpg", str];
            
            NSData *imageData = UIImageJPEGRepresentation(image, 0.6f);
            if(imageData!=nil){
                NSString *name = [NSString stringWithFormat:@"photo%d",i];
                [formData appendPartWithFileData:imageData name:name fileName:fileName mimeType:@"multipart/form-data"];
                
            }
            i++;
        }
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];

            if (sucess) {
                sucess(dict);
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"%@",error.description);
        }
    }];
    return requestProxy;
}

+ (NSString *)fetchUrlParam:(NSDictionary *)statement {
//    BasicNameValuePair *arg = nil;
//    va_list argList;
    NSMutableString *params = nil;
    
    if (statement) {
        for (NSString *key in statement.allKeys) {
            
            if([statement[key] isKindOfClass:[NSString class]]){
//                va_start(argList, statement);
                NSString *value = [NSString stringWithString:statement[key]];
                params = [[[NSMutableString alloc] initWithFormat:@"%@=%@", key, value]autorelease];
                
//                while ((arg = va_arg(argList, BasicNameValuePair *))) {
//                    if (!arg) break;
//                    NSString *val = [NSString stringWithString:arg.value];
//                    [params appendFormat:@"&%@=%@", arg.name, val];
//                }
//
//                va_end(argList);
            }
        }
    }else{
        params = [[[NSMutableString alloc] init] autorelease];
    }
    return [TJRBaseManager createParams:params];
}

+ (YYRequestUtility *)post:(NSString *)urlString
                parameters:(NSDictionary *)parameters
                    header: (NSDictionary *)header
                  progress:(requestProgressHandleBlock)progress
                   success:(requestSuccessHandleBlock)sucess
                   failure:(requestFailedHandleBlock)failure{
    YYRequestUtility *requestProxy = [[YYRequestUtility alloc] init];
    YYHTTPSessionManager *manager = [YYHTTPSessionManager shareInstance];
    
    manager.requestSerializer =  [AFJSONRequestSerializer serializer];//[AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/json;charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    manager.requestSerializer.timeoutInterval = 15;
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"application/json", @"text/json" ,@"text/javascript", nil];
    
    requestProxy.sessionTask = [manager POST:urlString parameters:parameters  headers:header progress:^(NSProgress * _Nonnull uploadProgress) {
        if (progress) {
            progress(uploadProgress);
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if (sucess) {
                sucess(responseObject);
            }
        }else{
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
            if (sucess) {
                sucess(dict);
            }
        }
        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failure) {
            failure(error);
            NSLog(@"%@",error.description);
        }
        
    }];
    return requestProxy;
}

@end

