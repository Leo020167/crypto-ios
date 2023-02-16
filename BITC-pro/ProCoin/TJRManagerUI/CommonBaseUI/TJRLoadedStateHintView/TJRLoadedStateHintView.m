//
//  TJRLoadedStateHintView.m
//  TJRtaojinroad
//
//  Created by Hay on 15/7/15.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRLoadedStateHintView.h"

#define IconImageViewTag 2000
#define InfoLabelTag    2001

@interface TJRLoadedStateHintView()

@property (copy, nonatomic) NSString *infoText;

@end

@implementation TJRLoadedStateHintView

@synthesize infoText;

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]){
        
    }
    
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}


#pragma mark - 显示loaded不同状态时页面
+ (TJRLoadedStateHintView *)loadedStateHintView:(UIView *)superView loadedState:(TJRLoadedStateType)type declareText:(NSString *)text
{
    TJRLoadedStateHintView *hintView = [[[TJRLoadedStateHintView alloc] initWithFrame:superView.bounds] autorelease];
    hintView.backgroundColor = [UIColor whiteColor];
    
    hintView.infoText = text;
    
    UIImageView *ivIcon = [[[UIImageView alloc] init] autorelease];
    UILabel *infoLabel = [[[UILabel alloc] init] autorelease];
    ivIcon.tag = IconImageViewTag;
    infoLabel.tag = InfoLabelTag;
    
    [hintView setHintViewComponents:ivIcon declareLabel:infoLabel];
    
    [hintView addSubview:ivIcon];
    [hintView addSubview:infoLabel];
    
    [superView addSubview:hintView];
    
    return hintView;
    
}

#pragma mark - 自动调整状态icon和文字的位置
- (void)autoAdjustLoadedStateHintViewCompnentsPos
{
    UIImageView *ivIcon = (UIImageView *)[self viewWithTag:IconImageViewTag];
    UILabel *lbInfo = (UILabel *)[self viewWithTag:InfoLabelTag];
    
    if(ivIcon && lbInfo){
        [self setHintViewComponents:ivIcon declareLabel:lbInfo];
    }
}

#pragma mark - 设置image和text位置
- (void)setHintViewComponents:(UIImageView *)iconImage declareLabel:(UILabel *)infoLabel
{
    //image
    CGSize imageSize = [UIImage imageNamed:@"tjrpublic_load_data_noting"].size;
    CGRect ivIconFrame = CGRectMake((self.frame.size.width - imageSize.width)/2, 30, imageSize.width, imageSize.height);
    [iconImage setFrame:ivIconFrame];
    iconImage.image = [UIImage imageNamed:@"tjrpublic_load_data_noting"];
    
    //text
    CGFloat limitWidth = ivIconFrame.size.width + 50;
    CGSize constraint = CGSizeMake(limitWidth, 20000.0f);
    CGSize textSize = [infoText boundingRectWithSize:constraint options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]} context:nil].size;
    
    [infoLabel setFrame:CGRectMake((self.frame.size.width - limitWidth)/2, iconImage.frame.origin.y + iconImage.frame.size.height + 10 , textSize.width, textSize.height)];
    [infoLabel setNumberOfLines:0];
    [infoLabel setTextAlignment:NSTextAlignmentCenter];
    [infoLabel setFont:[UIFont systemFontOfSize:16]];
    [infoLabel setTextColor:RGBA(204, 204, 204, 1.0)];
    infoLabel.text = infoText;
}

- (void)setLoadedStateHintViewFrame:(CGRect)frame
{
    [self setFrame:frame];
    [self autoAdjustLoadedStateHintViewCompnentsPos];
}


- (void)dismissFromSuperView
{
    [self removeFromSuperview];
}



@end
