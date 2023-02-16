//
//  KBTPoolEntity.h
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KBTPoolEntity : TJRBaseEntity

@property (copy, nonatomic) NSString *destroyAmount;            //已销毁数量
@property (copy, nonatomic) NSString *produceAmount;            //已产出数量
@property (copy, nonatomic) NSString *repoPrice;                //回收价格
@property (copy, nonatomic) NSString *repoPriceCny;             //回收价格描述

@end

