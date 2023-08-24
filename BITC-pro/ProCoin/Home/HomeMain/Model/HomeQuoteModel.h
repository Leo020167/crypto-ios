//
//  HomeQuoteModel.h
//  ProCoin
//
//  Created by 李祥翔 on 2021/12/18.
//  Copyright © 2021 Toka. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeQuoteModel : NSObject
@property (nonatomic, copy) NSString *image;

@property (nonatomic, copy) NSString *symbol;

@property (nonatomic, copy) NSString *currency;

@property (nonatomic, copy) NSString *price;

@property (nonatomic, copy) NSString *rate;

@property (nonatomic, copy) NSString *priceCny;

@property (nonatomic, copy) NSString *amount;

@property (nonatomic, copy) NSString *marketType;

@property (nonatomic, copy) NSString *name;

@property (nonatomic, assign) double changedRate; /// 是否已显示动画
@end

NS_ASSUME_NONNULL_END
