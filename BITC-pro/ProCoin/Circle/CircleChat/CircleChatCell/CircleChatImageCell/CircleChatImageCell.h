//
//  CircleChatImageCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12/8/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatExtendEntity;
@class CircleChatImageCell;
@class CircleChatBubbleView;
@class TJRImageAndDownFile;

@protocol CircleChatImageCellDelegate <NSObject>

- (void)circleChatImageCell:(CircleChatImageCell *)imgCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer;
- (void)circleChatImageCell:(CircleChatImageCell *)imgCell headViewLongPressed:(NSString *)userId name:(NSString*)name;
- (void)circleChatImageCell:(CircleChatImageCell *)imgCell imageViewTouched:(UIView *)touchView url:(NSString*)url;
- (void)circleChatImageCell:(CircleChatImageCell *)imgCell buttonErrorClicked:(id)sender;
- (void)circleChatImageCell:(CircleChatImageCell *)imgCell headViewClicked:(NSString *)userId name:(NSString*)name;
@end

@interface CircleChatImageCell : UITableViewCell

@property (assign, nonatomic) id<CircleChatImageCellDelegate> delegate;

@property (retain, nonatomic) IBOutlet CircleChatBubbleView *bubbleView;
@property (retain, nonatomic) IBOutlet TJRImageAndDownFile *imageAndDownFile;

- (void)setImageCell:(CircleChatExtendEntity*)entity;
+ (float)getHeightOfCell:(BOOL)isMine size:(CGSize)size timeFormat:(NSString*)timeFormat;
@end
