//
//  KBTAnnouceEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTAnnouceEntity.h"



@implementation KBTAnnouceEntity


- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.articleId = [self stringParser:@"articleId" json:json];
        self.createTime = [self stringParser:@"createTime" json:json];
        self.isTop = [self integerParser:@"isTop" json:json];
        self.title = [self stringParser:@"title" json:json];
        self.url = [self stringParser:@"url" json:json];
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
