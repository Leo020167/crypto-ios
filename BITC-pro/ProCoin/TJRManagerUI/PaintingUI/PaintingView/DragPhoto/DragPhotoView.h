/*

Copyright (C) 2011 Apple Inc. All Rights Reserved.

*/

#import <UIKit/UIKit.h>

@protocol DragPhotoViewDelegate <NSObject>
@optional
- (void)dragViewBackgroundTouched;
- (void)dragViewSubTouched:(NSInteger)tag;
@end

@interface DragPhotoView : UIView <UIGestureRecognizerDelegate>
{
	// Views the user can move
	UIImageView *pieceView;
	
	BOOL piecesOnTop;  // Keeps track of whether or not two or more pieces are on top of each other
	int touchCount;
    
    UIView *pieceForReset;
    
	CGPoint startTouchPosition; 
    
    CGFloat lastScale;
    
    id <DragPhotoViewDelegate>delegate;
}

@property (nonatomic, retain) UIImageView *pieceView;
@property (nonatomic, assign)id delegate;
- (void)setDragUIImageView:(UIImageView*)imageview;
- (void)setDragUIView:(UIView*)view;
@end

