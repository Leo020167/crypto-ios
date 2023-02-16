//
//  MyOauthPicAlertView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 8/3/16.
//  Copyright © 2016 Redz. All rights reserved.
//

#import "MyOauthPicAlertView.h"
#import "TJRBaseViewController.h"
#import "CommonUtil.h"
#import "LewPopupViewAnimationSpring.h"
#import "RZWebImageView.h"

#define UIAlertViewTAG 6000

@interface MyOauthPicAlertView () <UIGestureRecognizerDelegate>{

    TJRBaseViewController* ctr;
}

@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet UIView *alertView;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet RZWebImageView *imageView;


@property (copy, nonatomic) NSString* updateTime;

@end

@implementation MyOauthPicAlertView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initAlertView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initAlertView];
    }
    
    return self;
}

- (void)initAlertView{
    self.frame = CGRectMake(0, 0, 300, 300);
    
    [[NSBundle mainBundle] loadNibNamed:@"MyOauthPicAlertView" owner:self options:nil];
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    [self addSubview:_baseView];
    
    
}

- (void)backgroundTouched:(UIGestureRecognizer*)recognizer{
    [self hide];
}

- (void)show:(UIView*)superView title:(NSString*)title imageUrl:(NSString*)imageUrl
{
    ctr = (TJRBaseViewController*)[CommonUtil getControllerWithContainView:superView];

    _lbTitle.text = title;
    [_imageView showImageWithUrl:imageUrl];

    [ctr lew_presentPopupView:self animation:[[LewPopupViewAnimationSpring alloc]autorelease] backgroundClickable:^{
        
        [self hide];
        
    } dismissed:^{

    }];
}

- (void)hide
{
    [ctr lew_dismissPopupView];
}


- (IBAction)closeButtonClicked:(id)sender {
    [self hide];
}

- (void)dealloc {
    [_baseView release];
    [_alertView release];
    [_lbTitle release];
    [_imageView release];
    [super dealloc];
}
@end
