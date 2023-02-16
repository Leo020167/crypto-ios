//
//  TJRPaintView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 13-3-1.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ACEDrawingView;
@class DragPhotoView;
@class EditableController;

@interface TJRPaintView : UIView
{
    ACEDrawingView *drawingView;
    DragPhotoView* dragView;
    EditableController* editableController;
	CFTimeInterval		lastTime;
    
    UIImageView* imageView;
    CGRect m_CGRect;
    
    NSMutableArray* historyPaintArray;//用于撤销
    

    UIView* paintColor;
    UIView* paintDialog;
    UIView* paintGraphic;
    UIView* paintDChoice;
    UIView* paintTextColor;
    UIView* paintBottomView;
    
    NSTimer* timer;
    NSInteger timeCount;
    
    NSInteger dragSubTag;
    
    CGRect phoneRectScreen;
    float bottomY;
    
    BOOL bReqFinished;

    UIView* superView;
    
    BOOL bInitPain;
}
@property (retain, nonatomic) UIView* paintBottomView;
@property (retain, nonatomic) UIImageView* imageView;
-(void)setImage:(UIImage*)img;
-(void)setSuperView:(UIView*)view;

-(UIImage*)getPaintViewImage;
- (void)showPaintBottomView;
- (void)hidePaintBottomView;
- (void)cleanPaint;
@end
