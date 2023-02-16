//
//  PCAnnounceModel.m
//  ProCoin
//
//  Created by Hay on 2020/3/30.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "PCAnnounceModel.h"

@implementation PCAnnounceModel


- (instancetype)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.articleId = [self stringParser:@"articleId" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.isTop = [self boolParser:@"title" json:json];
        self.title = [self stringParser:@"title" json:json];
        self.url = [self stringParser:@"url" json:json];
        self.type = [self integerParser:@"type" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_articleId release];
    [_createTime release];
    [_title release];
    [_url release];
    [super dealloc];
}

@end
