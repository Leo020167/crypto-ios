//
//  TJRCheckBox.m
//  taojinroad
//
//  Created by mac on 12-3-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TJRCheckBox.h"

#define kCBCIconMargin              4

@implementation TJRCheckBox

@synthesize checkboxIcon;
@synthesize textLabel;
@synthesize bChecked;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        checkedImg = [[UIImage imageNamed:@"blue_check"] retain];
        uncheckedImg = [[UIImage imageNamed:@"blue_uncheck"] retain];
        
        bChecked = NO;
        self.backgroundColor = [UIColor clearColor];
        
        checkboxIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        checkboxIcon.image = uncheckedImg;
        [self addSubview:checkboxIcon];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height, 3, self.frame.size.width - self.frame.size.height, 21)];
        textLabel.font = [UIFont systemFontOfSize:14.0f];
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        checkedImg = [[UIImage imageNamed:@"blue_check"] retain];
        uncheckedImg = [[UIImage imageNamed:@"blue_uncheck"] retain];
        
        bChecked = NO;
        self.backgroundColor = [UIColor clearColor];
        
        checkboxIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
        checkboxIcon.image = uncheckedImg;
        [self addSubview:checkboxIcon];
        
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.height, 3, self.frame.size.width - self.frame.size.height, 21)];
        textLabel.font = [UIFont systemFontOfSize:14.0f];
        textLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:textLabel];
    }
    
    return self;
}

- (void)dealloc
{
    [checkedImg release];
    [uncheckedImg release];
    [checkboxIcon release];
    [textLabel release];
    
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    bChecked = !bChecked;
    if(bChecked)
    {
        checkboxIcon.image = checkedImg;
    }
    else
    {
        checkboxIcon.image = uncheckedImg;
    }
    
    if([delegate respondsToSelector:@selector(checkBoxControlClicked:)])
    {
        [delegate performSelector:@selector(checkBoxControlClicked:) withObject:self];
    }
    [super touchesBegan:touches withEvent:event];
}

@end
