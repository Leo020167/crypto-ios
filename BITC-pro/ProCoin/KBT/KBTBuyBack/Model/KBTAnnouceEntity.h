//
//  KBTAnnouceEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBTAnnouceEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *articleId;
@property (copy, nonatomic) NSString *createTime;
@property (assign, nonatomic) NSInteger isTop;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *url;


@end


