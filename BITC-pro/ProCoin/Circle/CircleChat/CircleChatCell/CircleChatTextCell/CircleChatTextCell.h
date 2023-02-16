//
//  CircleChatTextCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12/3/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatExtendEntity;
@class CircleChatTextCell;
@class CircleChatBubbleView;

@protocol CircleChatTextCellDelegate <NSObject>

- (void)circleChatTextCell:(CircleChatTextCell *)textCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell headViewLongPressed:(NSString *)userId name:(NSString*)name;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell linkClicked:(NSString *)url;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell fullcodeClicked:(NSString *)fullcode;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell paramsClicked:(NSString *)params;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell buttonErrorClicked:(id)sender;
- (void)circleChatTextCell:(CircleChatTextCell *)textCell headViewClicked:(NSString *)userId name:(NSString*)name;
@end

@interface CircleChatTextCell : UITableViewCell

@property (assign, nonatomic) id<CircleChatTextCellDelegate> delegate;
@property (retain, nonatomic) IBOutlet CircleChatBubbleView *bubbleView;

- (void)setTextCell:(CircleChatExtendEntity*)entity;
+ (float)getHeightOfCell:(NSString*)content isMine:(BOOL)isMine timeFormat:(NSString*)timeFormat;
- (void)willDispayTableViewCell:(BOOL)isMine;
@end
