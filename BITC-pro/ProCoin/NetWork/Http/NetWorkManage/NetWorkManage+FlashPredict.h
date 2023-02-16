//
//  NetWorkManage+FlashPredict.h
//  Cropyme
//
//  Created by Hay on 2019/8/30.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "NetWorkManage.h"



@interface NetWorkManage (FlashPredict)

#pragma mark - 获取预测记录
/**
 * 由于baseFlashPredictApi动态获取，所以区别于之前的网络请求方式，这个方法直接传入
 */
- (void)reqFlashPredictRecordData:(id)delegate baseFlashPredictApi:(NSString *)baseFlashPredictApi pageNo:(NSString *)pageNo finishedCallback:(SEL)cbFinished failedCallback:(SEL)cbFailed;

@end


