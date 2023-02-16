//
//  ChatBubbleView.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-19.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "CircleChatBubbleView.h"
#import <QuartzCore/QuartzCore.h>

#define leftCheckImage      [[UIImage imageNamed:@"circleChat_bubble_bg_left_b"] stretchableImageWithLeftCapWidth:30 topCapHeight:20]
#define leftUnCheckImage    [[UIImage imageNamed:@"circleChat_bubble_bg_left"] stretchableImageWithLeftCapWidth:30 topCapHeight:20]
#define rightCheckImage     [[UIImage imageNamed:@"circleChat_bubble_bg_right_b"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]
#define rightUnCheckImage   [[UIImage imageNamed:@"circleChat_bubble_bg_right"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]
#define rightCheckContentImage     [[UIImage imageNamed:@"circleChat_bubble_bg_right_b"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]
#define rightUnCheckContentImage   [[UIImage imageNamed:@"circleChat_bubble_bg_right"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]

#define imageLeftCheckImage      [[UIImage imageNamed:@"circleChat_bubble_bg_left_b"] stretchableImageWithLeftCapWidth:30 topCapHeight:20]
#define imageLeftUnCheckImage    [[UIImage imageNamed:@"circleChat_bubble_bg_left"] stretchableImageWithLeftCapWidth:30 topCapHeight:20]
#define imageRightCheckImage     [[UIImage imageNamed:@"circleChat_bubble_bg_right_b"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]
#define imageRightUnCheckImage   [[UIImage imageNamed:@"circleChat_bubble_bg_right"] stretchableImageWithLeftCapWidth:25 topCapHeight:25]

@implementation CircleChatBubbleView
@synthesize bubbleContentView;
@synthesize orientation;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization{
    
    self.backgroundColor = [UIColor clearColor];

    bubbleContentView = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [bubbleContentView setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin];

    [bubbleContentView setBackgroundImage:leftUnCheckImage forState:UIControlStateNormal];
    [bubbleContentView setBackgroundImage:leftCheckImage forState:UIControlStateHighlighted];
    bubbleContentView.userInteractionEnabled = NO;

    
    [self addSubview:bubbleContentView];
    [self sendSubviewToBack:bubbleContentView];

}

- (void)dealloc{
    [bubbleContentView release];
    [super dealloc];
}

- (void)setBubbleDelegate:(id)bubbleDelegate Side:(Orientation)side{
    orientation = side;
    //不选中
    [self unCheckBubbleView];
}

- (void)checkBubbleView{
    
    switch (_bubbleType) {
            
        case bubbleText:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:leftCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:leftCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:rightCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:rightCheckImage forState:UIControlStateHighlighted];
            }
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        case bubbleImage:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:imageLeftCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:imageLeftCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:imageRightCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:imageRightCheckImage forState:UIControlStateHighlighted];
            }
//            包含尖角
//            bubbleContentView.frame = CGRectMake( -1, -1, self.frame.size.width + 2, self.frame.size.height + 2);
//            [self bringSubviewToFront:bubbleContentView];
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        case bubbleContent:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:leftCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:leftCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:rightCheckContentImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:rightCheckContentImage forState:UIControlStateHighlighted];
            }
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        default:
            break;
    }
}

//不选中
- (void)unCheckBubbleView{

    switch (_bubbleType) {
            
        case bubbleText:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:leftUnCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:leftUnCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:rightUnCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:rightUnCheckImage forState:UIControlStateHighlighted];
            }
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        case bubbleImage:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:imageLeftUnCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:imageLeftUnCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:imageRightUnCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:imageRightUnCheckImage forState:UIControlStateHighlighted];
            }
//            包含尖角
//            bubbleContentView.frame = CGRectMake( -1, -1, self.frame.size.width + 2, self.frame.size.height + 2);
//            [self bringSubviewToFront:bubbleContentView];
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        case bubbleContent:
        {
            if (orientation == leftOrientation) {
                [bubbleContentView setBackgroundImage:leftUnCheckImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:leftUnCheckImage forState:UIControlStateHighlighted];
            }else{
                [bubbleContentView setBackgroundImage:rightUnCheckContentImage forState:UIControlStateNormal];
                [bubbleContentView setBackgroundImage:rightUnCheckContentImage forState:UIControlStateHighlighted];
            }
            bubbleContentView.frame = CGRectMake( 0, 0, self.frame.size.width, self.frame.size.height);
            [self sendSubviewToBack:bubbleContentView];
            break;
        }
        default:
            break;
    }
}


@end
