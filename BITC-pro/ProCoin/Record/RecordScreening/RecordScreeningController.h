//
//  RecordScreeningController.h
//  Cropyme
//
//  Created by Hay on 2019/9/4.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseViewController.h"

typedef enum{
    RecordScreeningBuySellStateType = 0,
    RecordScreeningOrderStateType,
}RecordScreeningType;

typedef enum{
    RecordScreeningButtonType_WithoutChoose = 0,
    RecordScreeningButtonType_Buy,
    RecordScreeningButtonType_Sell,
    RecordScreeningButtonType_AllDone,
    RecordScreeningButtonType_PartDone,
    RecordScreeningButtonType_Cancel,
}RecordScreeningButtonType;

@protocol RecordScreeningControllerDelegate <NSObject>

@optional
- (void)recordScreeningDidSubmitWithType:(RecordScreeningType)type screeningSymbol:(NSString *)screeningSymbol buttonType:(RecordScreeningButtonType)buttonType;

@end


@interface RecordScreeningController : TJRBaseViewController

@property (assign, nonatomic) id<RecordScreeningControllerDelegate> delegate;

- (void)addSelfToParentViewController:(UIViewController *)controller viewType:(RecordScreeningType)type inputSymbol:(NSString *)inputSymbol buttonType:(RecordScreeningButtonType)buttonType;

@end


