//
//  ShareBase.m
//  Perval
//
//  Created by taojinroad on 27/09/2017.
//  Copyright © 2018 BPerval. All rights reserved.
//

#import "ShareBase.h"
#import "TJRBaseViewController.h"
#import "ShareToWeixin.h"
#import "CommonUtil.h"
#import "TTCacheManager.h"
#import <AFNetworking.h>

@interface ShareBase ()
{
    BOOL bReqFinished;
    TJRBaseViewController* ctr;
}

@property (copy, nonatomic) NSString *chatShareJson;
@end

@implementation ShareBase

- (instancetype)init {
    if (self = [super init]) {
        bReqFinished = YES;
    }
    return self;
}

- (void)dealloc {
    [_shareParams release];
    [super dealloc];
}

- (void)share:(UIView*)superView{
    ctr = (TJRBaseViewController*)[CommonUtil getControllerWithContainView:superView];
    bReqFinished = YES;
    
    [self reqGetShareTypeByInfo];
}

- (void)reqGetShareTypeByInfo {
    if (bReqFinished) {
        bReqFinished = YES;
        
        [ctr showProgressDefaultText];
        self.chatShareJson = nil;
        [[NetWorkManage shareSingleNetWork] reqShareData:self shareType:_shareType params:_shareParams  finishedCallback:@selector(reqGetShareTypeByInfoFinished:) failedCallback:@selector(reqGetShareTypeByInfoFalid:)];
    }
}

- (void)reqGetShareTypeByInfoFinished:(NSDictionary *)json {
    bReqFinished = YES;
    [ctr dismissProgress];
    
    if ([ctr showProgressHUDWithMsg:json]) {
        NSDictionary *dic = [json objectForKey:@"data"];
        NSString* shareURL = [NSString stringWithFormat:@"%@", dic[@"shareUrl"]];
        NSString* shareTitle = [NSString stringWithFormat:@"%@", dic[@"title"]];
        NSString* descText = [NSString stringWithFormat:@"%@", dic[@"content"]];
        NSString* logo = [NSString stringWithFormat:@"%@", dic[@"logo"]];
        
        NSURL *url = [NSURL URLWithString:logo];
        
        NSData *data = [TTCacheManager dataForURL:logo];
        if (data != nil){
            if (shareURL.length > 0) {
                [ShareToWeixin sendNewsContentWithTitle:shareTitle description:descText newsImageName:logo webpageUrl:shareURL isSession:_isSession];
            }
        }else{
            // 本地无缓存，开始下载
            AFHTTPSessionManager* manager = [AFHTTPSessionManager manager];
            
            NSURLRequest* request = [NSURLRequest requestWithURL:url];
            
            __block NSURLSessionDownloadTask * task = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
                
            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                
                return [NSURL fileURLWithPath:[TTCacheManager cachePathForPath:logo]];
                
            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                
                if (shareURL.length > 0) {
                    [ShareToWeixin sendNewsContentWithTitle:shareTitle description:descText newsImageName:logo webpageUrl:shareURL isSession:_isSession];
                }
            }];
            [task resume];
        }
    }
}

- (void)reqGetShareTypeByInfoFalid:(NSDictionary *)json {
    bReqFinished = YES;
    [ctr dismissProgress];
    [ctr showToast:@"分享失败"];
    
}

@end
