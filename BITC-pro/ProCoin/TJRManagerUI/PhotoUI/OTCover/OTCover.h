//
//  OTCover.h
//  OTMediumCover
//
//  Created by yechunxiao on 14-9-21.
//  Copyright (c) 2014年 yechunxiao. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define OTCoverViewHeight 200
#import "TJRImageAndDownFile.h"

@class OTCover;

@protocol OTCoverDelagate <NSObject>

@optional
- (void)otCoverDidScrollingContentOffset:(OTCover *)otCover tableViewOffSet:(CGPoint)offSet;

@end

@interface OTCover : UIView

@property (assign, nonatomic) id<OTCoverDelagate> delegate;
@property (nonatomic, retain) TJRImageAndDownFile* headerImageView;
@property (nonatomic, retain) UITableView* tableView;

+ (OTCover*)initWithTableViewWithHeaderImageUrl:(NSString *)headerImageUrl withOTCoverHeight:(CGFloat)height;

- (void)setHeaderImageUrl:(NSString *)headerImageUrl;

@end


@interface UIImage (Blur)
-(UIImage *)boxblurImageWithBlur:(CGFloat)blur;
@end

