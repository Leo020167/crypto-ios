//
//  PCAnnounceModel.h
//  ProCoin
//
//  Created by Hay on 2020/3/30.
//  Copyright © 2020 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"



@interface PCAnnounceModel : TJRBaseEntity


@property (copy, nonatomic) NSString *articleId;
@property (copy, nonatomic) NSString *createTime;
@property (assign, nonatomic) BOOL isTop;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;
@property (assign, nonatomic) NSInteger type;


@end


