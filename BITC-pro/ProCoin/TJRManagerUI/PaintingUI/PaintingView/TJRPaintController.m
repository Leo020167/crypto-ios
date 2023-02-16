//
//  TJRPaintController.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-20.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRPaintController.h"
#import "MBProgressHUD.h"

@interface TJRPaintController ()

@end

@implementation TJRPaintController
@synthesize leftBtn;
@synthesize rightBtn;
@synthesize titleLabel=_titleLabel;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidUnload
{
    [self setRightBtn:nil];
    [self setLeftBtn:nil];
    [self setTitleLabel:nil];
    [super viewDidUnload];
    
}

- (void) dealloc
{
    [rightBtn release];
    [leftBtn release];
    [_titleLabel release];
    [_paintView release];
	[super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.canDragBack = NO;
    
}

- (void)setImageContentMode:(UIViewContentMode)mode
{
    _paintView.imageView.contentMode = mode;
}

- (void)setFinalImage:(UIImage *)image
{
    [_paintView setImage:image];
}

- (void)setPaintSuperView
{
    bReqFinished = YES;
    [_paintView setSuperView:self.view];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (IBAction)leftButtonClicked:(id)sender
{
    [_paintView cleanPaint];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rightButtonClicked:(id)sender
{

    if (bReqFinished) {
        
        NSData *dataObj = UIImageJPEGRepresentation([_paintView getPaintViewImage], 1.0);

        BOOL bSend = NO;
        if ([delegate respondsToSelector:@selector(TJRPaintNeedSend:)]) {
            bSend = [delegate TJRPaintNeedSend:dataObj];
        }
        bReqFinished = NO;
        if (bSend) {
            [self showProgress:@"正在发送图片.." detailsText:@"请稍后.."];
            rightBtn.enabled = NO;
        }else{
            [self finish];
        }
        
        
    }
    
}

- (void)finish
{
    rightBtn.enabled = YES;
    bReqFinished = YES;
    [self dismissProgress];
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
