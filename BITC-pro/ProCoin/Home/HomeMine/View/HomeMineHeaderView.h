//
//  HomeMineHeaderView.h
//  Cropyme
//
//  Created by Hay on 2019/7/18.
//  Copyright © 2019 Toka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    MineHeaderViewEditInfoEvent = 0,            //编辑资料事件
    MineHeaderViewPersonalMainEvent,            //个人主页
    MineHeaderViewChargeCoinEvent,              //转入
    MineHeaderViewExtractCoinEvent,             //转出
    MineHeaderViewTransferCoinEvent,            //划转
    MineHeaderViewP2PInOutEvent,            //法币买卖
}MineHeaderViewEvent;

@protocol HomeMineHeaderViewDelegate <NSObject>

@optional
- (void)mineHeaderViewEventDidSeleted:(MineHeaderViewEvent)event;

@end

@interface HomeMineHeaderView : UIView

@property (assign, nonatomic) id<HomeMineHeaderViewDelegate> delegate;

/** 返回当前需要的高度*/



#pragma mark - reload更新数据
- (void)reloadHeaderViewBaseData;

@end


