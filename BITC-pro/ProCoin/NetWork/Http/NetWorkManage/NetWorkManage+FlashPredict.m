//
//  NetWorkManage+FlashPredict.m
//  Cropyme
//
//  Created by Hay on 2019/8/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage+FlashPredict.h"

#define URL_API_PREDICT_RECORD      @"predict/record"

@implementation NetWorkManage (FlashPredict)


#pragma mark - 获取预测记录
- (void)reqFlashPredictRecordData:(id)delegate baseFlashPredictApi:(NSString *)baseFlashPredictApi pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed
{
    [taojinHttpBase doHttpGETForJson:[NSString stringWithFormat:@"%@%@.do", baseFlashPredictApi, URL_API_PREDICT_RECORD]
                              params:[self fetchUrlParam:
                                      [BasicNameValuePair setName:@"pageNo" value:pageNo], nil]
                            delegate:delegate httpFinish:cbFinished httpFaild:cbFailed];
}

@end
