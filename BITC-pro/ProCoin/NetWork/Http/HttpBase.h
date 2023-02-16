//
//  HttpBase.h
//
//  Created by taojinroad on 12-8-20.
//  Copyright (c) 2012年 Taojinroad. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpBase : NSObject

- (void)doHttpPOSTForJson:(NSString *)url params:(NSString *)params delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild;
- (void)doHttpGETForJson:(NSString *)url params:(NSString *)params delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild;
- (void)uploadFileToServer:(NSString *)url params:(NSString *)params files:(NSDictionary *)files delegate:(id)delegate httpFinish:(SEL)httpFinish httpFaild:(SEL)httpFaild;
@end

/**
 *    一个http请求所包含内容，用于记录回调函数
 */
@interface TTBaseHttpDelegate : NSObject {
    id _delegate;
    BOOL bFinish;
    int _classIsa;  //用于标识传入的delegate的ISA码，如被释放ISA将会改变
    
    SEL requestDidFinishSelector;
    SEL requestDidFailSelector;
}
@property (nonatomic, assign) BOOL bFinish;
@property (nonatomic, assign) id delegate;
@property (nonatomic, assign) int classIsa;

@property (assign) SEL requestDidFinishSelector;
@property (assign) SEL requestDidFailSelector;

@property (nonatomic, retain) NSURLSessionDataTask * task;

- (id)initWithDelegate:(id)delegate_ httpFinish:(SEL)finish httpFaild:(SEL)faild;
- (void)clean;
@end
