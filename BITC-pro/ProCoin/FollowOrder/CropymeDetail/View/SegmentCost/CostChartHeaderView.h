//
//  CostChartHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/8/13.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "TJRBaseEntity.h"
#import "CDCostBaseEntity.h"



@interface CostChartHeaderView : UIView

- (void)reloadChartHeaderViewWithCostEntity:(CDCostBaseEntity *)costEntity chartDataArr:(NSArray *)chartDataArr;

@end

