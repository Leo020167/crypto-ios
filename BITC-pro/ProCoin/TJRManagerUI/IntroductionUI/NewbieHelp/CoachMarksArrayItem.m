//
//  CoachMarksArrayItem.m
//  TJRtaojinroad
//
//  Created by Hay on 14-10-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "CoachMarksArrayItem.h"

@implementation CoachMarksArrayItem

@synthesize guideImage,guideImagePos,cutoutShape,cutoutFrame,captionText,captionTextFrame;

- (void)dealloc
{
    [guideImage release];
    [captionText release];
    [super dealloc];
}

+ (instancetype)coachMarksArrayItem
{
    return [[[CoachMarksArrayItem alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if(self){
        self.guideImage = nil;
        self.guideImagePos = CGPointZero;
        self.cutoutShape = NHCutoutShape_RoundedRect;
        self.cutoutFrame = CGRectZero;
        self.captionText = @"";
        self.captionTextFrame = CGRectZero;
    }
    return self;
}

@end
