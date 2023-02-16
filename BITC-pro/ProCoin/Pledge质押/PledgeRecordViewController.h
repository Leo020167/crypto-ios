//
//  PledgeRecordViewController.h
//  ProCoin
//
//  Created by Luo Chun on 2022/11/8.
//  Copyright © 2022 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TJRBaseViewController.h"
#import "JXCategoryListContainerView.h"

NS_ASSUME_NONNULL_BEGIN

@interface PledgeRecordViewController :UIViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, assign) NSInteger index;

@end



@interface PledgeRecordBaseViewController :TJRBaseViewController


@end


NS_ASSUME_NONNULL_END
