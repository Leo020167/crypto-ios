//
//  CircleChatJsonCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 4/21/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatExtendEntity;
@class CircleChatJsonCell;
@class CircleChatBubbleView;

@protocol CircleChatJsonCellDelegate <NSObject>

- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer;
- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell headViewLongPressed:(NSString *)userId name:(NSString*)name;
- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell contentCellTouched:(UIView *)touchView pview:(NSString*)pview params:(NSString*)params;
- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell buttonErrorClicked:(id)sender;
- (void)circleChatJsonCell:(CircleChatJsonCell *)stockCell headViewClicked:(NSString *)userId name:(NSString*)name;
@end

@interface CircleChatJsonCell : UITableViewCell{
}

@property (retain, nonatomic) IBOutlet CircleChatBubbleView *bubbleView;
@property (assign, nonatomic) id<CircleChatJsonCellDelegate> delegate;

- (void)setJsonCell:(CircleChatExtendEntity*)entity;
+ (float)getHeightOfCell:(BOOL)isMine timeFormat:(NSString*)timeFormat say:(NSString*)say;
@end
