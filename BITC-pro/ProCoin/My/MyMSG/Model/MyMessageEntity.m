//
//  MyMessageEntity.m
//  Perval
//
//  Created by Hay on 2017/6/28.
//  Copyright © 2017年 BPerval. All rights reserved.
//

#import "MyMessageEntity.h"
#import "CommonUtil.h"

@implementation MyMessageEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.content = [self stringParser:@"content" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.msgId = [self stringParser:@"msgId" json:json];
        self.userId = [self stringParser:@"userId" json:json];
        self.headUrl = [self stringParser:@"headUrl" json:json];
        self.title = [self stringParser:@"title" json:json];
        self.userName = [self stringParser:@"userName" json:json];
        self.extra = [self stringParser:@"extra" json:json];
        if (TTIsStringWithAnyText(_extra)) {
            NSDictionary* dic = [CommonUtil jsonValue:_extra];
            if (dic && dic.count>0) {
                self.extraTitle = [self stringParser:@"title" json:dic];
                self.params = [self stringParser:@"params" json:dic];
                self.pview = [self stringParser:@"pview" json:dic];
            }
        }

    }
    return self;
}

- (void)dealloc
{
    [_extra release];
    [_extraTitle release];
    [_headUrl release];
    [_title release];
    [_userName release];
    [_content release];
    [_createTime release];
    [_msgId release];
    [_userId release];
    [_pview release];
    [_params release];
    [super dealloc];
    
}

@end
