//
//  P2PMenuView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 3/29/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#import "P2PMenuView.h"
#import "LewPopupViewAnimationSpring.h"
#import "TJRBaseViewController.h"

@interface P2PMenuView () <UIGestureRecognizerDelegate> {
    TJRBaseViewController* ctr;
}

@property (retain, nonatomic) IBOutlet UIView *bgView;
@property (retain, nonatomic) IBOutlet UIView *menuView;
@property (retain, nonatomic) IBOutlet UIView *baseView;

@end

@implementation P2PMenuView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initMenuView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initMenuView];
    }
    
    return self;
}

- (void)initMenuView{
    
    self.frame = CGRectMake(0, 0, phoneRectScreen.size.width, phoneRectScreen.size.height);
    
    [[NSBundle mainBundle] loadNibNamed:@"P2PMenuView" owner:self options:nil];
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    [self addSubview:_baseView];
    
    _menuView.alpha = 0;
    
    CALayer *layer = [_menuView layer];
    layer.shadowOffset = CGSizeMake(0, 3);
    layer.shadowRadius = 5.0;
    layer.shadowColor = [UIColor blackColor].CGColor;
    layer.shadowOpacity = 0.8;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    [tapGestureRecognizer setDelegate:self];
    [_bgView addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (void)backgroundTouched:(UIGestureRecognizer*) recognizer{
    [self hide];
}

- (void)show:(UIView*)superView
{
    [superView addSubview:self];
    _bgView.alpha = 0;
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         _menuView.alpha = 1;
                         _bgView.alpha = 0.2;
                     } completion:^(BOOL finished) {
                         
                     }];
}

- (void)hide
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         _menuView.alpha = 0;
                         _bgView.alpha = 0;
                     } completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}




- (IBAction)adButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pMenuView:adButtonClicked:)]) {
        [_delegate p2pMenuView:self adButtonClicked:sender];
    }
}

- (IBAction)customerButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pMenuView:customerButtonClicked:)]) {
        [_delegate p2pMenuView:self customerButtonClicked:sender];
    }
}

- (IBAction)moneyButtonClicked:(id)sender {
    [self hide];
    if (_delegate && [_delegate respondsToSelector:@selector(p2pMenuView:moneyButtonClicked:)]) {
        [_delegate p2pMenuView:self moneyButtonClicked:sender];
    }
}

- (void)dealloc{
    [_bgView release];
    [_menuView release];
    [_baseView release];

    [super dealloc];
}

@end
