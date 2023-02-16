//
//  TJRCustomPushBar.m
//  TJRCustomPushBar
//
//  Created by Jason Lee on 12-3-12.
//  Copyright (c) 2012年 Taobao. All rights reserved.
//

#import "TJRCustomPushBar.h"
#import "CommonUtil.h"
#import "VeDateUtil.h"

#define StatusBarClickedBlock @"StatusBarClickedBlock"

@interface TJRCustomPushBar (){
}
@property (retain, nonatomic) IBOutlet UIView *baseView;
@property (retain, nonatomic) IBOutlet UILabel *lbStatusMsg;
@property (retain, nonatomic) IBOutlet UIImageView *ivLogo;
@property (retain, nonatomic) IBOutlet UILabel *lbTime;
@property (retain, nonatomic) IBOutlet UILabel *lbTitle;
@end

static TJRCustomPushBar *statusBar;

@implementation TJRCustomPushBar


+ (TJRCustomPushBar *)shareStatusBar {
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        if (statusBar == nil) {
            statusBar = [[TJRCustomPushBar alloc]init];
        }
    });
    
    return statusBar;
}

- (void)dealloc {
    [self removeClickedCallback];
    [_lbStatusMsg release];
    [_baseView release];
    [_ivLogo release];
    [_lbTime release];
    [_lbTitle release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self initView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self initView];
    }
    
    return self;
}

- (void)initView{
    
    [[NSBundle mainBundle] loadNibNamed:@"TJRCustomPushBar" owner:self options:nil];
    CGRect frame = self.baseView.frame;
    frame.origin = CGPointZero;
    frame.size = self.frame.size;
    self.baseView.frame = frame;
    [self addSubview:_baseView];
    
    _ivLogo.image = [UIImage imageNamed:@"AppIcon40x40"];
    self.backgroundColor = [UIColor clearColor];
}

- (void)showStatusMessage:(NSString *)message head:(NSString *)head didClicked:(void (^)(void))didClicked{
	self.hidden = NO;
	self.alpha = 1.0f;
    [ROOTCONTROLLER.navigationController.topViewController.view addSubview:self];
    
	_lbStatusMsg.text = message;
    _lbTitle.text = head;
    
    CGSize totalSize = [CommonUtil getPerfectSizeByText:message andFontSize:15 andWidth:[[UIScreen mainScreen] bounds].size.width - 40];
    
	CGRect rect = self.frame;
    rect.size.width = [[UIScreen mainScreen] bounds].size.width;
	rect.size.height = MAX(totalSize.height + 42 + 10, 80) ;
    self.baseView.frame = rect;
    
    rect.origin.y = - rect.size.height;
	self.frame = rect;

	[UIView animateWithDuration:0.5f animations:^{

        self.frame = CGRectMake(rect.origin.x, 10 + IPHONEX_TOP_HEIGHT, rect.size.width, rect.size.height);
        self.baseView.frame = self.frame;
	} completion:^(BOOL finished) {
		
        _lbTime.text = [VeDateUtil getAnyTimeFromDateFormat:[VeDateUtil getNowTime]];
        if (didClicked) {
            [self setClickedCallback:didClicked];
        }
	}];

	[self performSelector:@selector(hide) withObject:nil afterDelay:7];
}

- (void)hide {
	self.alpha = 1.0f;
	[UIView animateWithDuration:0.5f animations:^{
		CGRect rect = self.frame;
		rect.origin.y =  - self.frame.size.height;
		self.frame = rect;
	} completion:^(BOOL finished) {
		self.hidden = YES;
        [self removeFromSuperview];
	}];
}

- (IBAction)buttonClicked:(id)sender {
    
    id block = [self clickedCallback];
    if (block) {
        ((void (^)(void))block)();
    }
    [self removeClickedCallback];
    [self hide];
}

- (void (^)(void))clickedCallback {
    return objc_getAssociatedObject(self, StatusBarClickedBlock);
}

- (void)setClickedCallback:(void (^)(void))clickedCallback {
    objc_setAssociatedObject(self, StatusBarClickedBlock, clickedCallback, OBJC_ASSOCIATION_COPY);
}

- (void)removeClickedCallback{
    objc_setAssociatedObject(self, StatusBarClickedBlock, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end
