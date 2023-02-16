//
//  MyMessageEntity.h
//  Perval
//
//  Created by Hay on 2017/6/28.
//  Copyright © 2017年 BPerval. All rights reserved.
//

#import "TJRBaseEntity.h"

@interface MyMessageEntity : TJRBaseEntity


@property (copy, nonatomic) NSString  *content;
@property (copy, nonatomic) NSString  *createTime;
@property (copy, nonatomic) NSString  *msgId;
@property (copy, nonatomic) NSString  *userId;
@property (copy, nonatomic) NSString  *pview;
@property (copy, nonatomic) NSString  *params;
@property (copy, nonatomic) NSString  *title;
@property (copy, nonatomic) NSString  *userName;
@property (copy, nonatomic) NSString  *headUrl;
@property (copy, nonatomic) NSString  *extra;
@property (copy, nonatomic) NSString  *extraTitle;
@end
