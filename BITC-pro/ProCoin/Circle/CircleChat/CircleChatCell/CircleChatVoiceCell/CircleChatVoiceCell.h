//
//  CircleChatVoiceCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 12/8/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "TJRBaseObj.h"

@class CircleChatExtendEntity;
@class CircleChatVoiceCell;
@class TJRVoicePlayView;

@protocol CircleChatVoiceCellDelegate <NSObject>

- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell handleLongPressed:(UILongPressGestureRecognizer *)recognizer;
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell headViewLongPressed:(NSString *)userId name:(NSString*)name;
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell buttonErrorClicked:(id)sender;
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell voiceClicked:(NSString*)url;
- (void)circleChatVoiceCell:(CircleChatVoiceCell *)voiceCell headViewClicked:(NSString *)userId name:(NSString*)name;
@end

@interface CircleChatVoiceCell : UITableViewCell

@property (assign, nonatomic) id<CircleChatVoiceCellDelegate> delegate;

@property (retain, nonatomic) IBOutlet TJRVoicePlayView *voicePlayView;

- (void)setVoiceCell:(CircleChatExtendEntity*)entity;
- (void)setPlayView:(CircleChatExtendEntity*)entity;
+ (float)getHeightOfCell:(NSString*)content isMine:(BOOL)isMine timeFormat:(NSString*)timeFormat;
- (void)playVoice:(NSString*)url voiceLength:(NSString *)voiceLength;
@end
