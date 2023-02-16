//
//  LeverageRecordScreening.h
//  BYY
//
//  Created by Hay on 2019/12/28.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

typedef NS_ENUM(NSInteger,LeverageRecordScreeningType){
    LeverageRecordScreeningTypeSell = -1,
    LeverageRecordScreeningTypeBuy = 1,
    LeverageRecordScreeningTypeNothing = 9999,
};

@protocol LeverageRecordScreeningDelegate <NSObject>

@optional

- (void)recordScreeningDidSubmitWithType:(LeverageRecordScreeningType)type screeningSymbol:(NSString *)screeningSymbol;

@end


@interface LeverageRecordScreening : TJRBaseViewController

@property (assign, nonatomic) id<LeverageRecordScreeningDelegate> delegate;

- (void)addSelfToParentViewController:(UIViewController *)controller viewType:(LeverageRecordScreeningType)type inputSymbol:(NSString *)inputSymbol;


@end

