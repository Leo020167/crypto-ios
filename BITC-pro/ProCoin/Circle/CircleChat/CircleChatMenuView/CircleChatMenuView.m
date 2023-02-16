//
//  CircleChatMenuView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatMenuView.h"
#import "CircleBaseDataEntity.h"
#import "UIButton+NewNum.h"

@interface CircleChatMenuView () <UIGestureRecognizerDelegate> {
    
    NSMutableArray* container;
    float animationDuration;
}

@property (retain, nonatomic) IBOutlet UIView *menuView;
@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet UIView *masterView;
@property (retain, nonatomic) IBOutlet NSLayoutConstraint *topConstraint;
@property (retain, nonatomic) IBOutlet UIButton *btnNewStock;
@property (retain, nonatomic) IBOutlet UIButton *btnNewGold;
@property (retain, nonatomic) IBOutlet UIView *stockView;
@property (retain, nonatomic) IBOutlet UIView *goldView;

@end

@implementation CircleChatMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initChatMenuView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initChatMenuView];
    }
    
    return self;
}

- (void)initChatMenuView{
    
    [[NSBundle mainBundle] loadNibNamed:@"CircleChatMenuView" owner:self options:nil];
    
    self.frame = CGRectMake(phoneRectScreen.size.width - 80, 84, 80, 175);
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    [self addSubview:_baseView];

    CALayer *layer = [_masterView layer];
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 5.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    
    
    container = [[NSMutableArray alloc] init];
    [container addObject:_stockView];
    [container addObject:_goldView];

    animationDuration = 0.2;
    
}

- (void)showSysMsgWithCircleNum:(CircleBaseDataEntity *)item {

}

- (void)backgroundTouched:(UIGestureRecognizer*) recognizer{
    [self hide];
}

- (void)show:(UIView*)superView
{
    [superView addSubview:self];
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatMenuViewOn:)]) {
        [_delegate chatMenuViewOn:self];
    }
    
    _masterView.alpha = 0;
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         _masterView.alpha = 0.2;
                     } completion:^(BOOL finished) {
                         [self showSysMsgWithCircleNum:_entity];
                     }];
    [CATransaction begin];
    [CATransaction setAnimationDuration:animationDuration];
    [CATransaction setCompletionBlock:^{
        for (UIButton *button in container) {
            button.transform = CGAffineTransformIdentity;
        }
        self.userInteractionEnabled = YES;
    }];
    
    for (int i = 0; i < container.count; i++) {
        int index = (int)container.count - (i + 1);
        
        UIView *button = [container objectAtIndex:index];
        button.hidden = NO;
        
        // position animation
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        
        CGPoint originPosition = CGPointZero;
        CGPoint finalPosition = CGPointZero;
        
        originPosition = CGPointMake(_menuView.frame.size.width/2.f, 0);
        finalPosition = CGPointMake(_menuView.frame.size.width/2.f,
                                    50 + 10 + button.frame.size.height/2.f
                                    + ((button.frame.size.height + 10) * index));
        
        positionAnimation.duration = animationDuration;
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        positionAnimation.fromValue = [NSValue valueWithCGPoint:originPosition];
        positionAnimation.toValue = [NSValue valueWithCGPoint:finalPosition];
        positionAnimation.beginTime = CACurrentMediaTime() + (animationDuration/(float)container.count * (float)i);
        positionAnimation.fillMode = kCAFillModeForwards;
        positionAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:positionAnimation forKey:@"positionAnimation"];
        
        button.layer.position = finalPosition;
        
        // scale animation
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.duration =animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:0.01f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:1.f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (animationDuration/(float)container.count * (float)i) + 0.03f;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        button.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    }
    
    [CATransaction commit];

}

- (void)hide
{
    
    if (_delegate && [_delegate respondsToSelector:@selector(chatMenuViewOff:)]) {
        [_delegate chatMenuViewOff:self];
    }
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _masterView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
    
    self.userInteractionEnabled = NO;
    
    [CATransaction begin];
    [CATransaction setAnimationDuration:animationDuration];
    [CATransaction setCompletionBlock:^{

        for (UIButton *button in container) {
            button.transform = CGAffineTransformIdentity;
            button.hidden = YES;
        }
        self.userInteractionEnabled = YES;
    }];
    
    int index = 0;
    for (int i = 0; i < container.count; i++) {
        UIButton *button = [container objectAtIndex:i];

        // scale animation
        CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        
        scaleAnimation.duration = animationDuration;
        scaleAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        scaleAnimation.fromValue = [NSNumber numberWithFloat:1.f];
        scaleAnimation.toValue = [NSNumber numberWithFloat:0.01f];
        scaleAnimation.beginTime = CACurrentMediaTime() + (animationDuration/(float)container.count * (float)index) + 0.03;
        scaleAnimation.fillMode = kCAFillModeForwards;
        scaleAnimation.removedOnCompletion = NO;
        
        [button.layer addAnimation:scaleAnimation forKey:@"scaleAnimation"];
        
        button.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
        index++;
    }
    
    [CATransaction commit];
}

- (IBAction)goldButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(chatMenuView:goldButtonClicked:)]) {
        [_delegate chatMenuView:self goldButtonClicked:sender];
    }
}

- (IBAction)stockButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(chatMenuView:stockButtonClicked:)]) {
        [_delegate chatMenuView:self stockButtonClicked:sender];
    }
}


- (IBAction)masterButtonClicked:(id)sender {
    [self hide];
}

- (void)dealloc{
    [_entity release];
    [container release];
    [_menuView release];
    [_baseView release];
    [_masterView release];
    [_topConstraint release];
    [_btnNewStock release];
    [_stockView release];
    [_goldView release];
    [_btnNewGold release];
    [super dealloc];
}

@end
