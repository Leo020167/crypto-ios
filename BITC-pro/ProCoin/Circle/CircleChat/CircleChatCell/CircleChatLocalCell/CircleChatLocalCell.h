//
//  CircleChatSystemCell.h
//  TJRtaojinroad
//
//  Created by taojinroad on 4/20/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CircleChatExtendEntity;

@interface CircleChatLocalCell : UITableViewCell

+ (float)getHeightOfCell;

- (void)setLocalCell:(CircleChatExtendEntity*)entity;
@end
