//
//  HttpBase.m
//
//  Created by taojinroad on 12-8-20.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#define HTTP_DELEGATE_KEY  @"http_delegate_key"

#define ISDEBUG            YES

#import "HttpBase.h"
#import "TJRBaseViewController.h"
#import "TJRBaseTabBarController.h"
#import "TJRBaseView.h"
#import "TJRBaseTableView.h"
#import "TJRBaseObj.h"
#import "TTCacheManager.h"
#import "CommonUtil.h"
#import "RootController.h"

#import "AFNetworking.h"
#import "URLParser.h"
#import "BasicNameValuePair.h"
#import "LanguageManager.h"
@implementation HttpBase

/**
 *    @brief POST方式请求JSON数据
 *
 *    @param url            路径
 *    @param params         参数
 *    @param delegate       接口回调请求源
 *    @param httpFinish     回调函数
 *    @param httpFaild      回调函数
 */
- (void)doHttpPOSTForJson:(NSString *)url params:(NSString *)params delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild {

    NSString* urlString = [NSString stringWithFormat:@"%@?%@",url,params];
    
    if (ISDEBUG) NSLog(@"%@",urlString);
    
    TTBaseHttpDelegate *httpDelegate = [[[TTBaseHttpDelegate alloc] initWithDelegate:delegate httpFinish:httpFinish httpFaild:httpFaild]autorelease];
    
    NSDictionary* parameters = [[[[URLParser alloc]initWithURLString:[BasicNameValuePair decodeURLString:urlString]]autorelease] valueToDictionary];
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    
    /** 缓存机制*/
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    NSURLSessionDataTask * task = [manager POST:url parameters:parameters  headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestDidFinishLoad:task responseObject:responseObject httpDelegate:httpDelegate];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self request:task didFailLoadWithError:error httpDelegate:httpDelegate];
    }];
    httpDelegate.task = task;
    
    if ([delegate isKindOfClass:[TJRBaseViewController class]]) {
        [(TJRBaseViewController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTabBarController class]]) {
        [(TJRBaseTabBarController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseView class]]) {
        [(TJRBaseView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTableView class]]) {
        [(TJRBaseTableView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseObj class]]) {
        [(TJRBaseObj *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    }
}

/**
 *    @brief GET方式请求JSON数据
 *
 *    @param url            路径
 *    @param params         参数,GET默认进行encode
 *    @param delegate       接口回调请求源
 *    @param httpFinish     回调函数
 *    @param httpFaild      回调函数
 */
- (void)doHttpGETForJson:(NSString *)url params:(NSString *)params delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild {

    NSString* urlString = [NSString stringWithFormat:@"%@?%@",url,params];
    
    NSLog(@"urlString ： %@",urlString);
    
    TTBaseHttpDelegate *httpDelegate = [[[TTBaseHttpDelegate alloc] initWithDelegate:delegate httpFinish:httpFinish httpFaild:httpFaild]autorelease];
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    /** 网络请求设置，设置了信任所有证书，同时不检查域名可靠性，以后有了权威证书，可以去掉保证安全性*/
//    manager.securityPolicy.allowInvalidCertificates = YES;
//    manager.securityPolicy.validatesDomainName = NO;
    
    /** 缓存机制*/
    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];

    NSURLSessionDataTask * task = [manager GET:urlString parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestDidFinishLoad:task responseObject:responseObject httpDelegate:httpDelegate];
        NSLog(@"%@",responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self request:task didFailLoadWithError:error httpDelegate:httpDelegate];
    }];
    httpDelegate.task = task;
    
    if ([delegate isKindOfClass:[TJRBaseViewController class]]) {
        [(TJRBaseViewController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTabBarController class]]) {
        [(TJRBaseTabBarController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseView class]]) {
        [(TJRBaseView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTableView class]]) {
        [(TJRBaseTableView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseObj class]]) {
        [(TJRBaseObj *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    }
}

/**
 *	@brief	上传文件
 *
 *	@param 	url 	上传路径
 *	@param 	params 	上传参数
 *  @param  files   上传的文件名合集,（字符串，数组)
 */
- (void)uploadFileToServer:(NSString *)url params:(NSString *)params files:(NSDictionary *)files delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild{
    
    TTBaseHttpDelegate *httpDelegate = [[TTBaseHttpDelegate alloc] initWithDelegate:delegate httpFinish:httpFinish httpFaild:httpFaild];
    
    NSString* urlString = [NSString stringWithFormat:@"%@?%@",url,params];
    
    NSDictionary* parameters = [[[[URLParser alloc]initWithURLString:[BasicNameValuePair decodeURLString:urlString]]autorelease] valueToDictionary];
    
    AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];
    
    [manager.requestSerializer setValue:[LanguageManager abridgeCode] forHTTPHeaderField:@"lang"];
    NSURLSessionDataTask * task = [manager POST:url parameters:parameters headers:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        for (NSString* paramsKey in files.allKeys) {
            
            id value = [files objectForKey:paramsKey];
            
            if([value isKindOfClass:[NSString class]]){
                
                NSString* fileName = (NSString*)value;
                NSString *fileLocalUrl = [NSString stringWithFormat:@"%@", fileName];
                NSData *fileData = [self loadFileFromDocuments:fileLocalUrl];
                [formData appendPartWithFileData:fileData name:paramsKey fileName:fileName mimeType:@"application/form-data"];
                
            }else if([value isKindOfClass:[NSArray class]]){
                
                NSArray* fileNameArray = (NSArray*)value;
                for (NSString* fileName in fileNameArray) {
                    NSString *fileLocalUrl = [NSString stringWithFormat:@"%@", fileName];
                    NSData *fileData = [self loadFileFromDocuments:fileLocalUrl];
                    if (!fileData) continue;
                    [formData appendPartWithFileData:fileData name:paramsKey fileName:fileName mimeType:@"application/form-data"];
                }
            }
        }

    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        [self requestDidFinishLoad:task responseObject:responseObject httpDelegate:httpDelegate];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self request:task didFailLoadWithError:error httpDelegate:httpDelegate];
    }];
    httpDelegate.task = task;
    
    if ([delegate isKindOfClass:[TJRBaseViewController class]]) {
        [(TJRBaseViewController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTabBarController class]]) {
        [(TJRBaseTabBarController *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseView class]]) {
        [(TJRBaseView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseTableView class]]) {
        [(TJRBaseTableView *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    } else if ([delegate isKindOfClass:[TJRBaseObj class]]) {
        [(TJRBaseObj *)delegate recordHttpRequest:[NSString stringWithFormat:@"%p",task] httpRequest:httpDelegate];
    }
}

/**
 *	@brief	按文件名将文件转化为NSData
 *
 *	@param 	fileName 	文件名
 *
 *	@return
 */
- (NSData*)loadFileFromDocuments:(NSString*)fileName {
    NSString *path = [CommonUtil TTPathForDocumentsResourceEtag:fileName];
    return [NSData dataWithContentsOfFile:path];
}


/**
 *	@brief	网络成功回传
 *
 *	@param 	request
 */
- (void)requestDidFinishLoad:(NSURLSessionDataTask *)task responseObject:(id)responseObject httpDelegate:(TTBaseHttpDelegate *)httpDelegate{
    
    NSDictionary* feed = nil;
    if([responseObject isKindOfClass:[NSDictionary class]] || [responseObject isKindOfClass:[NSArray class]]){
        feed = responseObject;
    }
    
    id delegate = httpDelegate.delegate;
    if (httpDelegate && !httpDelegate.bFinish && delegate) {
        
        if (httpDelegate && delegate) {
            if ([delegate isKindOfClass:[TJRBaseViewController class]]) {
                [(TJRBaseViewController *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseTabBarController class]]) {
                [(TJRBaseTabBarController *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseView class]]) {
                [(TJRBaseView *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseTableView class]]) {
                [(TJRBaseTableView *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseObj class]]) {
                [(TJRBaseObj *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            }
        }
        if (httpDelegate.requestDidFinishSelector && [delegate respondsToSelector:httpDelegate.requestDidFinishSelector]) {
            if([ROOTCONTROLLER rootCheckJson:responseObject]){
                [ROOTCONTROLLER logout];
                [delegate performSelector:httpDelegate.requestDidFinishSelector withObject:feed];
            }else{
                [delegate performSelector:httpDelegate.requestDidFinishSelector withObject:feed];
            }
        }
        
    }
}

/**
 *	@brief	网络失败
 *
 *	@param 	request
 *	@param 	error
 */
- (void)request:(NSURLSessionDataTask *)task didFailLoadWithError:(NSError *)error httpDelegate:(TTBaseHttpDelegate *)httpDelegate {
    
    id delegate = httpDelegate.delegate;
    if (httpDelegate && delegate && (error.code != -999) && [delegate respondsToSelector:httpDelegate.requestDidFailSelector]) {
        [delegate performSelector:httpDelegate.requestDidFailSelector withObject:error];
        NSLog(@"%@", error);
        if (httpDelegate && delegate) {
            if ([delegate isKindOfClass:[TJRBaseViewController class]]) {
                [(TJRBaseViewController *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseTabBarController class]]) {
                [(TJRBaseTabBarController *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseView class]]) {
                [(TJRBaseView *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            } else if ([delegate isKindOfClass:[TJRBaseTableView class]]) {
                [(TJRBaseTableView *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            }else if ([delegate isKindOfClass:[TJRBaseObj class]]) {
                [(TJRBaseObj *)delegate removeHttpRequestFromDictionary:[NSString stringWithFormat:@"%p",task]];
            }
        }
    }
}

@end


@implementation TTBaseHttpDelegate
@synthesize delegate;
@synthesize requestDidFinishSelector;
@synthesize requestDidFailSelector;
@synthesize bFinish;

- (id)initWithDelegate:(id)delegate_ httpFinish:(SEL)finish httpFaild:(SEL)faild{
    self = [super init];
    
    if (self) {
        self.delegate = delegate_;
        [self setRequestDidFinishSelector:finish];
        [self setRequestDidFailSelector:faild];
        self.classIsa = [CommonUtil getDelegateIsa:delegate_];
    }
    return self;
}

- (void)clean {
    [_task cancel];
    self.delegate = nil;
    self.bFinish = YES;
    self.requestDidFinishSelector = nil;
    self.requestDidFailSelector = nil;
}

- (void)dealloc{
    [_task release];
    [super dealloc];
}

@end
