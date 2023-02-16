//
//  OverlapButton.m
//  TJRtaojinroad
//
//  Created by taojinroad on 14-10-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "OverlapButton.h"

@implementation OverlapButton

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initButtonView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initButtonView];
    }
    return self;
}

- (void)dealloc{
    self.baseView = nil;
    [super dealloc];
}

- (void)initButtonView {
    
    self.baseView = [[[NSBundle mainBundle] loadNibNamed:@"OverlapButton" owner:self options:nil]lastObject];
    [self addSubview:self.baseView];
    

}

- (void)start{
    UIImageView* iv1 = (UIImageView*)[_baseView viewWithTag:50];
    UIImageView* iv2 = (UIImageView*)[_baseView viewWithTag:51];
    UIImageView* iv3 = (UIImageView*)[_baseView viewWithTag:52];
    UIImageView* iv4 = (UIImageView*)[_baseView viewWithTag:53];
    
//    iv1.center = CGPointMake(iv4.center.x, iv4.center.y);
//    iv2.center = CGPointMake(iv4.center.x, iv4.center.y);
//    iv3.center = CGPointMake(iv4.center.x, iv4.center.y);
    
    [UIView animateWithDuration:0.6 animations:^{
        iv1.center = CGPointMake(iv4.center.x, iv4.center.y - 5);
    } completion:^(BOOL finish) {
        [UIView animateWithDuration:0.4 animations:^{
            iv1.center = CGPointMake(iv4.center.x, iv4.center.y);
        } completion:^(BOOL finish) {}];
    }];
    
    [UIView animateWithDuration:0.4 animations:^{
        iv2.center = CGPointMake(iv4.center.x - 5, iv4.center.y + 5);
    } completion:^(BOOL finish) {
        [UIView animateWithDuration:0.4 animations:^{
            iv2.center = CGPointMake(iv4.center.x, iv4.center.y);
        } completion:^(BOOL finish) {}];
    }];
    
    [UIView animateWithDuration:0.7 animations:^{
        iv3.center = CGPointMake(iv4.center.x + 5, iv4.center.y);
    } completion:^(BOOL finish) {
        [UIView animateWithDuration:0.4 animations:^{
            iv3.center = CGPointMake(iv4.center.x, iv4.center.y);
        } completion:^(BOOL finish) {}];
    }];
}

@end
