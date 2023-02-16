//
//  ProgressView.m
//  taojinroad
//
//  Created by Jeans Huang on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ProgressView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ProgressView
@synthesize leftNum;
@synthesize rightNum;
@synthesize leftLabel;
@synthesize rightLabel;
@synthesize leftImageView;
@synthesize rightImageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    self.backgroundColor = [UIColor clearColor];
//    self.layer.cornerRadius = self.frame.size.height / 2;
    self.layer.masksToBounds = YES;
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    leftNum = 0;
    rightNum = 0;
    leftImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width / 2, self.frame.size.height)];
    rightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.frame.size.width / 2, 0, self.frame.size.width / 2, self.frame.size.height)];

    leftImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    rightImageView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    
    
//    leftImageView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:144.0f/255.0f blue:182.0f/255.0f alpha:1.0f];
//    rightImageView.backgroundColor = [UIColor colorWithRed:157.0f/255.0f green:80.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
    [self addSubview:leftImageView];
    [self addSubview:rightImageView];
    [self setLeftNum:leftNum andRightNum:rightNum andIsAnimated:NO];
}

- (void)dealloc{
    [leftImageView release];
    [rightImageView release];
    [leftLabel release];
    [rightLabel release];
    [super dealloc];
}

- (void)setLeftNum:(CGFloat)_leftNum andRightNum:(CGFloat)_rightNum andIsAnimated:(BOOL)animated{
    rightNum = _rightNum;
    leftNum = _leftNum;
    
    CGFloat sumWidth = self.frame.size.width;
    CGFloat leftWidth = sumWidth / 2;
    CGFloat rightWidth = leftWidth;
    
    if (_leftNum != _rightNum) {
        leftWidth = sumWidth * ((CGFloat)_leftNum / (_leftNum + _rightNum));
        rightWidth = sumWidth - leftWidth;
    }

    if (animated) {
        [UIView animateWithDuration:1.2 animations:^{
            leftImageView.frame = CGRectMake(leftImageView.frame.origin.x, leftImageView.frame.origin.y, leftWidth, leftImageView.frame.size.height);
            rightImageView.frame = CGRectMake(leftImageView.frame.origin.x + leftWidth, rightImageView.frame.origin.y, rightWidth, rightImageView.frame.size.height);
        }];
    }else {
        leftImageView.frame = CGRectMake(leftImageView.frame.origin.x, leftImageView.frame.origin.y, leftWidth, leftImageView.frame.size.height);
        rightImageView.frame = CGRectMake(leftImageView.frame.origin.x + leftWidth, rightImageView.frame.origin.y, rightWidth, rightImageView.frame.size.height);
    }
}

- (void)setLeftImage:(UIImage *)leftImage andRightImage:(UIImage *)rightImage{
    leftImageView.image = leftImage;
    rightImageView.image = rightImage;
}

- (void)refreshPercentLabel{
    if (leftLabel == nil) {
        leftLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, self.frame.size.height / 2 - 15, self.frame.size.width / 3, 30)];
        leftLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:leftLabel];
    }
    if (rightLabel == nil) {
        rightLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.frame.size.width - 10 - 50, self.frame.size.height / 2 - 15, self.frame.size.width / 3, 30)];
        rightLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:rightLabel];
        rightLabel.textAlignment = NSTextAlignmentRight;
    }
    leftLabel.text = [NSString stringWithFormat:@"%.2f%%",(float)leftNum/(leftNum+rightNum)*100];
    rightLabel.text = [NSString stringWithFormat:@"%.2f%%",(float)rightNum/(leftNum+rightNum)*100];
}

@end
