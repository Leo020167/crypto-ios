//
//  HomeNoticeAlertView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 8/3/16.
//  Copyright © 2016 Taojinroad. All rights reserved.
//

#import "HomeNoticeAlertView.h"
#import "TJRBaseViewController.h"
#import "CommonUtil.h"
#import "LewPopupViewAnimationSpring.h"
#import "PlacardSQL.h"

#define UIAlertViewTAG 6000

@interface HomeNoticeAlertView () <UIGestureRecognizerDelegate>{

    TJRBaseViewController* ctr;
}

@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet UIView *alertView;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@property (retain, nonatomic) IBOutlet UITextView *tvContent;


@property (copy, nonatomic) NSString* updateTime;

@end

@implementation HomeNoticeAlertView

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
    self.frame = CGRectMake(0, 0, 300, 350);
    
    [[NSBundle mainBundle] loadNibNamed:@"HomeNoticeAlertView" owner:self options:nil];
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    [self addSubview:_baseView];
    
    
}

- (void)backgroundTouched:(UIGestureRecognizer*)recognizer{
    [self hide];
}

- (void)show:(UIView*)superView title:(NSString*)title content:(NSString*)content updateTime:(NSString*)updateTime
{
    ctr = (TJRBaseViewController*)[CommonUtil getControllerWithContainView:superView];

    _lbTitle.text = title;
    _tvContent.text = content;
    self.updateTime = updateTime;
    
    [ctr lew_presentPopupView:self animation:[[LewPopupViewAnimationSpring alloc]autorelease] backgroundClickable:^{
        
        [self hide];
        
    } dismissed:^{

    }];
}

- (void)hide
{
    PlacardSQL *sql = [PlacardSQL new];
    [sql replacePlacardSQl:_updateTime content:_tvContent.text title:_lbTitle.text];
    RELEASE(sql);
    
    [ctr lew_dismissPopupView];
}


- (IBAction)closeButtonClicked:(id)sender {
    [self hide];
}

- (void)dealloc {
    [_updateTime release];
    [_baseView release];
    [_alertView release];
    [_lbTitle release];
    [_tvContent release];
    [super dealloc];
}
@end
