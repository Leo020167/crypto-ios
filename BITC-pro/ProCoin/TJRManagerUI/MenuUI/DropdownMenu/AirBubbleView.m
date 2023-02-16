//
//  AirBubbleView.m
//  taojinroad
//
//  Created by hh hh on 2/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AirBubbleView.h"

@implementation AirBubbleView

@synthesize handleSize;
@synthesize handleImgView;
@synthesize roundRectImgView;
@synthesize airBubbleStyle;

- (id)initWithFrame:(CGRect)frame style:(enum handleStyle)style {
    self = [super initWithFrame:frame];
    if(self) {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.backgroundColor = [UIColor clearColor];
        
        airBubbleStyle = style;
        
        handleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        handleImgView.image = [UIImage imageNamed:@"air_bubble_left_arrow.png"];
        [self addSubview:handleImgView];
        
        roundRectImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        roundRectImgView.image = [[UIImage imageNamed:@"air_bubble_round_rectangle.png"] stretchableImageWithLeftCapWidth:30 topCapHeight:30];
        roundRectImgView.backgroundColor = [UIColor clearColor];
        [self addSubview:roundRectImgView];
        roundRectImgView.userInteractionEnabled = YES;
        roundRectImgView.multipleTouchEnabled = YES;        
        [self setHandleSize:CGSizeMake(kHandleWidth, kHandleHeight)];
    }    
    return self;
}

- (void)dealloc {
    [handleImgView release];
    [roundRectImgView release];
    
    [super dealloc];
}

- (void)rotateHandleImgView:(float)degree {
    CGAffineTransform transform = CGAffineTransformMakeRotation(degree * 3.14 / 180);
    handleImgView.transform = transform;
}

- (void)setHandleSize:(CGSize)size {
    int pos;
    CGRect handleImgVwFrame = CGRectZero;
    CGRect ctrlFrame = CGRectZero;
    CGRect roundRectFrame = CGRectZero;
    
    handleSize = size;
    ctrlFrame = self.frame;
    if(airBubbleStyle == topSideLeftAlign) {
        handleImgVwFrame = CGRectMake(kHandleMargin, 0, size.height, size.width);
    } else if(airBubbleStyle == topSideMiddleAlign) {
        pos = (ctrlFrame.size.width - size.height) / 2;
        handleImgVwFrame = CGRectMake(pos, 0, size.height, size.width);
    } else if(airBubbleStyle == topSideRightAlign) {
        pos = ctrlFrame.size.width - size.height - kHandleMargin;
        handleImgVwFrame = CGRectMake(pos, 0, size.height, size.width); 
    } else if(airBubbleStyle == rightSideTopAlign) {
        handleImgVwFrame = CGRectMake(ctrlFrame.size.width - size.width, kHandleMargin, size.width, size.height); 
    } else if(airBubbleStyle == topSideMiddleAlign) {
        pos = (ctrlFrame.size.height - size.height) / 2;
        handleImgVwFrame = CGRectMake(ctrlFrame.size.width - size.width, pos, size.width, size.height); 
    } else if(airBubbleStyle == topSideRightAlign) {
        pos = ctrlFrame.size.height - size.height - kHandleMargin;
        handleImgVwFrame = CGRectMake(ctrlFrame.size.width - size.width, pos, size.width, size.height);  
    } else if(airBubbleStyle == bottomSideLeftAlign) {
        handleImgVwFrame = CGRectMake(kHandleMargin, ctrlFrame.size.height - size.width, size.height, size.width);
    } else if(airBubbleStyle == bottomSideMiddleAlign) {
        pos = (ctrlFrame.size.width - size.height) / 2;
        handleImgVwFrame = CGRectMake(pos, ctrlFrame.size.height - size.width, size.height, size.width);  
    } else if(airBubbleStyle == bottomSideRightAlign) {
        pos = ctrlFrame.size.width - size.height - kHandleMargin;
        handleImgVwFrame = CGRectMake(pos, ctrlFrame.size.height - size.width, size.height, size.width); 
    } else if(airBubbleStyle == leftSideTopAlign) {
        handleImgVwFrame = CGRectMake(0, kHandleMargin, size.width, size.height); 
    } else if(airBubbleStyle == leftSideMiddleAlign) {
        pos = (ctrlFrame.size.height - size.height) / 2;
        handleImgVwFrame = CGRectMake(0, pos, size.width, size.height); 
    } else if(airBubbleStyle == leftSideBottomAlign) {
        pos = ctrlFrame.size.height - size.height - kHandleMargin;
        handleImgVwFrame = CGRectMake(0, pos, size.width, size.height); 
    } else if(airBubbleStyle == noHandle) {
        handleImgVwFrame = CGRectMake(0, 0, 0, 0); 
    }
    handleImgView.frame = handleImgVwFrame;
       
    
    if(airBubbleStyle == topSideLeftAlign || airBubbleStyle == topSideMiddleAlign || airBubbleStyle == topSideRightAlign) {   
        roundRectFrame = CGRectMake(0, handleSize.width, ctrlFrame.size.width, ctrlFrame.size.height - handleSize.width); 
        [self rotateHandleImgView:90];
    } else if(airBubbleStyle == rightSideTopAlign || airBubbleStyle == topSideMiddleAlign || airBubbleStyle == topSideRightAlign) {
        pos = ctrlFrame.size.width - handleSize.width;
        roundRectFrame = CGRectMake(0, 0, pos, ctrlFrame.size.height); 
        [self rotateHandleImgView:180];
    } else if(airBubbleStyle == bottomSideLeftAlign || airBubbleStyle == bottomSideMiddleAlign || airBubbleStyle == bottomSideRightAlign) {
        pos = ctrlFrame.size.height - handleSize.width;
        roundRectFrame = CGRectMake(0, 0, ctrlFrame.size.width, pos); 
        [self rotateHandleImgView:270];
    } else if(airBubbleStyle == leftSideTopAlign || airBubbleStyle == leftSideMiddleAlign || airBubbleStyle == leftSideBottomAlign) {
        pos = ctrlFrame.size.width - handleSize.width;
        roundRectFrame = CGRectMake(handleSize.width, 0, pos, ctrlFrame.size.height); 
    } else if(airBubbleStyle == noHandle) {
        roundRectFrame = CGRectMake(0, 0, ctrlFrame.size.width, ctrlFrame.size.height); 
    }
    
    roundRectImgVwRect = roundRectFrame;
//    //handleImgView.frame = handleImgVwFrame;
    roundRectImgView.frame = roundRectFrame;
}

- (void)setCrlFrame:(CGRect)frame {
    self.frame = frame;
    [self setHandleSize:CGSizeMake(kHandleWidth, kHandleHeight)];
}

- (CGRect)getRoundRectImgVwRect {
    return roundRectImgVwRect;
}

@end
