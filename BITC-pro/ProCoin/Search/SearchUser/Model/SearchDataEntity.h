//
//  SearchDataEntity.h
//  Redz
//
//  Created by Hay on 2018/12/4.
//  Copyright © 2018年 淘金路. All rights reserved.
//

#import "TJRBaseEntity.h"




//describes = "";
//fansCount = 3;
//headUrl = "http://192.168.0.223/crpm/images/default_head.png";
//isFollow = 0;
//name = nFl6;
//score = "7.75";
//userId = 5;

@interface SearchDataEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *headUrl;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *userId;
@property (assign, nonatomic) NSInteger type;
@property (copy,  nonatomic) NSString *url;

@end

