//
//  TJRPaintView.m
//  TJRtaojinroadHD
//
//  Created by taojinroad on 13-2-23.
//  Copyright (c) 2013年 Taojinroad. All rights reserved.
//
//  涂鸦控件类，分 涂鸦层 图标拖动层
//  涂鸦时，涂鸦层与拖动层按需切换

#import "TJRPaintView.h"
#import "DragPhotoView.h"
#import "ACEDrawingView.h"
#import "EditableController.h"
#import "ChatEditPopView.h"
#import "UIImage+Size.h"
#import <QuartzCore/QuartzCore.h>

#define Z0  1
#define Ztop 4
#define ZdrawTouchPointView 3
#define ZdragPhotoView 2


#define ViewTag 1000

@interface TJRPaintView ()<ACEDrawingViewDelegate>
{
    int dragObjTag;
    float phoneHeight;
    NSInteger paintBottomTag;
}
@end

@implementation TJRPaintView
@synthesize paintBottomView;
@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialization];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialization];
    }
    return self;
}

- (void)initialization
{
    historyPaintArray=[[NSMutableArray alloc]init];
    
    phoneRectScreen = [[UIScreen mainScreen]bounds];
    
    phoneHeight = CURRENT_DEVICE_VERSION>=7.0?phoneRectScreen.size.height:phoneRectScreen.size.height-20;
    bottomY=phoneHeight-44;
    
    self.imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height)];
    [self.imageView  setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
    
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self insertSubview:imageView atIndex:Z0];

    self.backgroundColor = RGBA(67, 67, 67, 1);
    imageView.backgroundColor = [UIColor clearColor];
}


- (void) dealloc
{
    [dragView release];
    [editableController release];
    TT_RELEASE_SAFELY(timer);
    [paintDialog release];
    [paintDChoice release];
    [paintColor release];
    [paintGraphic release];
    [historyPaintArray release];
    [drawingView release];
    [imageView release];
    [paintBottomView release];
	[super dealloc];
}

-(void)createPaintBottomView:(UIView*)fView
{
    if (!paintBottomView) {
        paintBottomView=[[[[NSBundle mainBundle]loadNibNamed:@"PaintBottomBar" owner:self options:nil]lastObject]retain];
        paintBottomView.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintBottomView];
        [paintBottomView setFrame:CGRectMake(paintBottomView.frame.origin.x, phoneHeight+paintBottomView.frame.size.height, paintBottomView.frame.size.width, paintBottomView.frame.size.height)];
        for (int i=0; i<5; i++) {
            UIButton* btn=(UIButton*)[paintBottomView viewWithTag:100+i];
            [btn addTarget:self action:@selector(switchMainView:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


-(void)createView:(UIView*)fView
{
    if (!paintColor) {
        paintColor=[[[[NSBundle mainBundle]loadNibNamed:@"PaintColor" owner:self options:nil]lastObject]retain];
        paintColor.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintColor];
        [paintColor setFrame:CGRectMake(paintColor.frame.origin.x, phoneHeight+paintColor.frame.size.height, phoneRectScreen.size.width, paintColor.frame.size.height)];
        for (int i=0; i<7; i++) {
            UIButton* btn=(UIButton*)[paintColor viewWithTag:100+i];
            [btn addTarget:self action:@selector(changeBrushColor:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.cornerRadius = 6;
            btn.layer.masksToBounds = YES;
        }
    }
    
    if (!paintTextColor) {
        paintTextColor=[[[[NSBundle mainBundle]loadNibNamed:@"PaintTextColor" owner:self options:nil]lastObject]retain];
        paintTextColor.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintTextColor];
        [paintTextColor setFrame:CGRectMake(paintTextColor.frame.origin.x, phoneHeight+paintTextColor.frame.size.height, phoneRectScreen.size.width, paintTextColor.frame.size.height)];
        for (int i=0; i<7; i++) {
            UIButton* btn=(UIButton*)[paintTextColor viewWithTag:100+i];
            [btn addTarget:self action:@selector(changeTextColor:) forControlEvents:UIControlEventTouchUpInside];
            btn.layer.cornerRadius = 6;
            btn.layer.masksToBounds = YES;
        }
    }
    
    if (!paintDialog) {
        paintDialog=[[[[NSBundle mainBundle]loadNibNamed:@"PaintDialog" owner:self options:nil]lastObject]retain];
        paintDialog.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintDialog];
        [paintDialog setFrame:CGRectMake(paintDialog.frame.origin.x, phoneHeight+paintDialog.frame.size.height, phoneRectScreen.size.width, paintDialog.frame.size.height)];
        for (int i=0; i<5; i++) {
            UIButton* btn=(UIButton*)[paintDialog viewWithTag:100+i];
            [btn addTarget:self action:@selector(graphicDialogPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (!paintDChoice) {
        paintDChoice=[[[[NSBundle mainBundle]loadNibNamed:@"PaintDChoice" owner:self options:nil]lastObject]retain];
        paintDChoice.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintDChoice];
        [paintDChoice setFrame:CGRectMake(paintDChoice.frame.origin.x, phoneHeight+paintDChoice.frame.size.height, phoneRectScreen.size.width, paintDChoice.frame.size.height)];
        for (int i=0; i<2; i++) {
            UIButton* btn=(UIButton*)[paintDChoice viewWithTag:100+i];
            [btn addTarget:self action:@selector(dChoiceButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    if (!paintGraphic) {
        paintGraphic=[[[[NSBundle mainBundle]loadNibNamed:@"PaintGraphic" owner:self options:nil]lastObject]retain];
        paintGraphic.autoresizingMask =  UIViewAutoresizingFlexibleWidth;
        [fView addSubview:paintGraphic];
        [paintGraphic setFrame:CGRectMake(paintGraphic.frame.origin.x, phoneHeight+paintGraphic.frame.size.height, phoneRectScreen.size.width, paintGraphic.frame.size.height)];
        for (int i=0; i<5; i++) {
            UIButton* btn=(UIButton*)[paintGraphic viewWithTag:100+i];
            [btn addTarget:self action:@selector(graphicButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
}


/**
 *  得到涂鸦的截图
 *
 *  @return image
 */
-(UIImage*)getPaintViewImage{
    
    CGRect imageFrame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    if (imageView.contentMode == UIViewContentModeScaleAspectFit) {
        /* 获取可见图片的区域 */
        CGSize imageSize = imageView.image.size;
        CGFloat imageScale = fminf(CGRectGetWidth(imageView.bounds)/imageSize.width, CGRectGetHeight(imageView.bounds)/imageSize.height);
        CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
        imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(imageView.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(imageView.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));
    }
    return [UIImage screenShotByView:self inRect:imageFrame];
}

-(void)setImage:(UIImage*)img
{
    imageView.image = img;
}

-(void)setSuperView:(UIView*)view
{
    [superView release];superView = nil;
    superView = [view retain];
    
    bInitPain = YES;
    
    [self createPaintBottomView:superView];
    [self createView:superView];
    
    paintColor.hidden = YES;
    [self performSelector:@selector(showPaintBottomView) withObject:nil afterDelay:0.1];
}

- (void)showPaintBottomView
{
    [UIView animateWithDuration:0.4 delay:0
                        options:UIViewAnimationOptionTransitionNone
                     animations:^{
                         [paintBottomView setFrame:CGRectMake(paintBottomView.frame.origin.x, phoneHeight -paintBottomView.frame.size.height, self.frame.size.width, paintBottomView.frame.size.height)];
                     } completion:^(BOOL finished) {
                         if (bInitPain) {
                             [self switchMainView:[paintBottomView viewWithTag:100]];
                             bInitPain = NO;
                         }
                     }];
    
}

- (void)hidePaintBottomView
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    [paintBottomView setFrame:CGRectMake(paintBottomView.frame.origin.x, phoneHeight+paintBottomView.frame.size.height, self.frame.size.width, paintBottomView.frame.size.height)];
    paintDialog.hidden = YES;
    paintGraphic.hidden = YES;
    [UIView commitAnimations];
}

- (void)show:(UIView*)view
{
    [superView bringSubviewToFront:view];
    [superView bringSubviewToFront:paintBottomView];
    view.hidden = NO;
    [UIView animateWithDuration:0.2
                     animations:^{
                         [view setFrame:CGRectMake(view.frame.origin.x, bottomY-view.frame.size.height, self.frame.size.width, view.frame.size.height)];
                     } completion:^(BOOL finished) {
                         
                     }];
    
}

- (void)hide:(UIView*)view
{
    [UIView animateWithDuration:0.2
                     animations:^{
                         [view setFrame:CGRectMake(view.frame.origin.x, phoneHeight+view.frame.size.height, self.frame.size.width, view.frame.size.height)];
                     } completion:^(BOOL finished) {
                         view.hidden = YES;
                     }];
}

- (void)showOrHide:(UIView*)view
{
    if (view.frame.origin.y==phoneHeight+view.frame.size.height) {
        [self show:view];
    }
    else {
        [self hide:view];
    }
}

- (void)showPaintDialog:(UIView*)view
{
    [UIView beginAnimations:nil context:nil];
    [view setFrame:CGRectMake(view.frame.origin.x, phoneHeight-view.frame.size.height, view.frame.size.width, view.frame.size.height)];
    [UIView commitAnimations];
    [superView bringSubviewToFront:view];
}

- (void)hidePaintDialog:(UIView*)view
{
    [UIView beginAnimations:nil context:nil];
    [view setFrame:CGRectMake(view.frame.origin.x, phoneHeight+view.frame.size.height, view.frame.size.width, view.frame.size.height)];
    [UIView commitAnimations];
}

// 主底部栏切换
-(void)switchMainView:(id)sender
{
    
    for (int i=0; i<5; i++) {
        UIButton* btn=(UIButton*)[paintBottomView viewWithTag:100+i];
        btn.selected = NO;
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    
    UIButton* btn=(UIButton*)sender;
    NSInteger flag=btn.tag-100;
    switch (flag) {
        case 0:
        {
            //涂鸦层
            if (drawingView == nil) {
                drawingView = [[ACEDrawingView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                drawingView.delegate = self;
                [self insertSubview:drawingView atIndex:ZdrawTouchPointView];
                drawingView.lineColor = [UIColor blackColor];
                drawingView.lineWidth = 2.0;
            }
            [self exchangeSubview:drawingView];
            
            btn.selected = YES;
            
            [self hide:paintDChoice];
            [self hide:paintGraphic];
            if (!paintColor.hidden) {
               [self hide:paintColor];
            }else{
                [self show:paintColor];
            }
            
            
            break;
        }
        case 1:
        {
            //图标拖动层(基本图标)
            if (dragView==nil) {
                dragView=[[DragPhotoView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                dragView.delegate=self;
                [self insertSubview:dragView atIndex:ZdragPhotoView];
            }
            [self exchangeSubview:dragView];
            
            btn.selected = YES;
            
            [self hide:paintDChoice];
            [self hide:paintColor];
            if (!paintGraphic.hidden) {
                [self hide:paintGraphic];
            }else{
                [self show:paintGraphic];
            }
            
            break;
        }
        case 2:
        {
            //图标拖动层(可写文字图标)
            if (dragView==nil) {
                dragView=[[DragPhotoView alloc]initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                dragView.delegate=self;
                [self insertSubview:dragView atIndex:ZdragPhotoView];
            }
            [self exchangeSubview:dragView];
            
            btn.selected = YES;
            
            [self hide:paintGraphic];
            [self hide:paintColor];
            if (!paintDChoice.hidden) {
                [self hide:paintDChoice];
            }else{
                [self show:paintDChoice];
            }
            break;
        }
        case 3:
        {
            [self hide:paintDChoice];
            [self hide:paintGraphic];
            [self hide:paintColor];
            if ([[historyPaintArray lastObject] isKindOfClass:[UIView class]]) {
                [[historyPaintArray lastObject] removeFromSuperview];
            }else{
                [drawingView undoLatestStep];
            }
            [historyPaintArray removeLastObject];
            break;
        }
        case 4:
        {
            [self hide:paintDChoice];
            [self hide:paintGraphic];
            [self hide:paintColor];
            
            [dragView removeFromSuperview];
            [dragView release];
            dragView=nil;
            
            [drawingView removeFromSuperview];
            [drawingView release];
            drawingView = nil;
            
            for (int i=0; i<7; i++) {
                UIButton* btn=(UIButton*)[paintColor viewWithTag:100+i];
                [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
            }
            [(UIButton*)[paintColor viewWithTag:100] setImage:[UIImage imageNamed:@"color_selected"] forState:UIControlStateNormal];
            
            break;
        }
        default:
            break;
    }
    
    paintBottomTag = btn.tag;
}

- (void)cleanPaint
{
    [dragView removeFromSuperview];
    [dragView release];
    dragView=nil;
    
    [drawingView removeFromSuperview];
    [drawingView release];
    drawingView = nil;
}

// 图标选择
-(void)graphicButtonPressed:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    
    NSArray* array=[NSArray arrayWithObjects:
                    [UIImage imageNamed:@"line.png"],
                    [UIImage imageNamed:@"point.png"],
                    [UIImage imageNamed:@"twowaypoint.png"],
                    [UIImage imageNamed:@"round.png"],
                    [UIImage imageNamed:@"warning.png"],
                    nil];
    
    UIImageView* imageview=[[[UIImageView alloc]initWithImage:[UIImage imageWithCGImage:[[array objectAtIndex:btn.tag-100] CGImage] scale: 0.8 orientation: UIImageOrientationUp]]autorelease];
    imageview.contentMode = UIViewContentModeCenter;
    imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageview.frame.size.width + 30, imageview.frame.size.height + 30);
    [historyPaintArray addObject:imageview];
    [dragView setDragUIImageView:imageview];
    [self exchangeSubview:dragView];
}

// 可写对话框选择
-(void)graphicDialogPressed:(id)sender
{
    UIButton* btn=(UIButton*)sender;
    
    NSArray* array=[NSArray arrayWithObjects:@"say_dialog1_b.png",@"say_dialog2_b.png",@"say_dialog3_b.png",@"say_dialog4_b.png",@"say_dialog5_b.png",nil];
    
    ChatEditPopView* imageview=[[ChatEditPopView alloc]initWithBgImageName:[array objectAtIndex:btn.tag-100]];
    [historyPaintArray addObject:imageview];
    [imageview setTag:++dragObjTag];
    imageview.delegate=self;
    imageview.frame = CGRectMake(imageview.frame.origin.x, imageview.frame.origin.y, imageview.frame.size.width + 30, imageview.frame.size.height + 30);
    [dragView setDragUIView:imageview];
    [self exchangeSubview:dragView];
}


// Change the brush color
- (void)changeBrushColor:(id)sender
{
    
    for (int i=0; i<7; i++) {
        UIButton* btn=(UIButton*)[paintColor viewWithTag:100+i];
        [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    UIButton* btn=(UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"color_selected"] forState:UIControlStateNormal];
    switch (btn.tag-100) {
        case 0:
        {
            [drawingView setLineColor:[UIColor blackColor]];
            break;
        }
        case 1:
        {
            [drawingView setLineColor:RGBA(255.0, 255.0, 0, 1.0)];
            break;
        }
        case 2:
        {
            [drawingView setLineColor:RGBA(243.0, 152.0, 0, 1.0)];
            break;
        }
        case 3:
        {
            [drawingView setLineColor:RGBA(232.0, 121.0, 171.0, 1.0)];
            break;
        }
        case 4:
        {
            [drawingView setLineColor:RGBA(143.0, 195.0, 31.0, 1.0)];
            break;
        }
        case 5:
        {
            [drawingView setLineColor:RGBA(89.0, 189.0, 228.0, 1.0)];
            break;
        }
        case 6:
        {
            [drawingView setLineColor:RGBA(137.0, 87.0, 161.0, 1.0)];
            break;
        }
    }
    [self exchangeSubview:drawingView];
}

- (void)changeTextColor:(id)sender
{
    for (int i=0; i<7; i++) {
        UIButton* btn=(UIButton*)[paintTextColor viewWithTag:100+i];
        [btn setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    }
    
    UIButton* btn=(UIButton*)sender;
    [btn setImage:[UIImage imageNamed:@"color_selected"] forState:UIControlStateNormal];
    
    if ([[dragView viewWithTag:dragSubTag] isKindOfClass:[ChatEditPopView class]]) {
        ChatEditPopView* popview=(ChatEditPopView*)[dragView viewWithTag:dragSubTag];
        switch (btn.tag-100) {
            case 0:
            {
                popview.contentLabel.textColor = [UIColor blackColor];
                break;
            }
            case 1:
            {
                popview.contentLabel.textColor = RGBA(255.0, 255.0, 0, 1.0);
                break;
            }
            case 2:
            {
                popview.contentLabel.textColor = RGBA(243.0, 152.0, 0, 1.0);
                break;
            }
            case 3:
            {
                popview.contentLabel.textColor = RGBA(232.0, 121.0, 171.0, 1.0);
                break;
            }
            case 4:
            {
                popview.contentLabel.textColor = RGBA(143.0, 195.0, 31.0, 1.0);
                break;
            }
            case 5:
            {
                popview.contentLabel.textColor = RGBA(89.0, 189.0, 228.0, 1.0);
                break;
            }
            case 6:
            {
                popview.contentLabel.textColor = RGBA(137.0, 87.0, 161.0, 1.0);
                break;
            }
        }
        
    }
    [self exchangeSubview:dragView];
}

-(void)dChoiceButtonPressed:(id)sender
{
    for (int i=0; i<2; i++) {
        UIButton* btn=(UIButton*)[paintDChoice viewWithTag:100+i];
        [btn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    [self hidePaintDialog:paintBottomView];
    UIButton* btn=(UIButton*)sender;
    [btn setTitleColor:RGBA(89.0, 189.0, 228.0, 1.0) forState:UIControlStateNormal];
    switch (btn.tag-100) {
        case 0:
        {
            [self hidePaintDialog:paintTextColor];
            [self showPaintDialog:paintDialog];
            break;
        }
        case 1:
        {
            [self hidePaintDialog:paintDialog];
            [self showPaintDialog:paintTextColor];
            break;
        }
    }
    
}

#pragma mark - uitl
-(void)dragViewBackgroundTouched
{
    [self hidePaintDialog:paintDialog];
    [self hidePaintDialog:paintColor];
    [self showPaintDialog:paintBottomView];
}

- (void)exchangeSubview:(UIView*)view
{
    [self bringSubviewToFront:view];
}

#pragma mark - editableController
- (void)dragViewSubTouched:(int)tag
{
    dragSubTag = tag;
}

- (void)backgroundDoubleClick:(int)tag
{
    dragSubTag = tag;
    if (editableController==nil) {
        editableController=[[EditableController alloc]init];
        editableController.delegate=self;
    }
    if ([[dragView viewWithTag:dragSubTag] isKindOfClass:[ChatEditPopView class]]) {
        ChatEditPopView* popview=(ChatEditPopView*)[dragView viewWithTag:dragSubTag];
        editableController.growingTextView.text=popview.contentLabel.text;
    }
//    [((UIViewController*)superView.nextResponder) presentModalViewController:editableController animated:YES];
    [((UIViewController*)superView.nextResponder) presentViewController:editableController animated:YES completion:nil];
}
- (void)editableControllerSetText:(NSString*)text
{
    if ([[dragView viewWithTag:dragSubTag] isKindOfClass:[ChatEditPopView class]]) {
        ChatEditPopView* popview=(ChatEditPopView*)[dragView viewWithTag:dragSubTag];
        [popview setText:editableController.growingTextView.text];
    }
}



#pragma mark - ACEDrawingViewDelegate
- (void)drawingView:(ACEDrawingView *)view willBeginDrawUsingTool:(id<ACEDrawingTool>)tool
{
    /* 记录所画的笔画 */
    [historyPaintArray addObject:tool];
}

@end
