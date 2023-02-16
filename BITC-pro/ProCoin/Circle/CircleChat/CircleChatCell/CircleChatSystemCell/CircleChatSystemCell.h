//
//  CircleChatSystemCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 4/20/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatExtendEntity;
@class CircleChatSystemCell;

@protocol CircleChatSystemCellDelegate <NSObject>

- (void)circleChatSystemCell:(CircleChatSystemCell *)systemCell fullcodeClicked:(NSString *)fullcode;
- (void)circleChatSystemCell:(CircleChatSystemCell *)systemCell paramsClicked:(NSString *)params;
@end

@interface CircleChatSystemCell : UITableViewCell

@property (assign, nonatomic) id<CircleChatSystemCellDelegate> delegate;

+ (float)getHeightOfCell:(NSString*)timeFormat say:(NSString*)say;

- (void)setSystemCell:(CircleChatExtendEntity*)entity;
@end
