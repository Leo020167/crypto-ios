/*
Copyright (C) 2011 Apple Inc. All Rights Reserved.

 */

#import <QuartzCore/QuartzCore.h>
#import "DragPhotoView.h"

@implementation DragPhotoView

@synthesize pieceView;
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		[self setupBackgroundTouchedTaps];
	}
	return self;
}

-(void)setupBackgroundTouchedTaps
{
    UISwipeGestureRecognizer *swipeUpGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self addGestureRecognizer:swipeUpGestureRecognizer];
    [swipeUpGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeDownGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    [self addGestureRecognizer:swipeDownGestureRecognizer];
    [swipeDownGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    swipeLeftGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    [swipeLeftGestureRecognizer release];
    
    UISwipeGestureRecognizer *swipeRightGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    swipeRightGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:swipeRightGestureRecognizer];
    [swipeRightGestureRecognizer release];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTouched:)];
    [self addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
    
}

-(void)backgroundTouched:(UIGestureRecognizer *)gestureRecognizer {
    if([delegate respondsToSelector:@selector(dragViewBackgroundTouched)])
        [delegate dragViewBackgroundTouched];
}

#pragma mark -
#pragma mark === Setting up and tearing down ===
#pragma mark

// adds a set of gesture recognizers to one of our piece subviews
- (void)addGestureRecognizersToPiece:(UIView *)piece
{
    UIRotationGestureRecognizer *rotationGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotatePiece:)];
    [piece addGestureRecognizer:rotationGesture];
    [rotationGesture release];
    
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePiece:)];
    [pinchGesture setDelegate:self];
    [piece addGestureRecognizer:pinchGesture];
    [pinchGesture release];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panPiece:)];
    [panGesture setMaximumNumberOfTouches:2];
    [panGesture setDelegate:self];
    [piece addGestureRecognizer:panGesture];
    [panGesture release];
    
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showResetMenu:)];
    [piece addGestureRecognizer:longPressGesture];
    [longPressGesture release];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPiece:)];
    [piece addGestureRecognizer:tapGestureRecognizer];
    [tapGestureRecognizer release];
}

- (void)setDragUIImageView:(UIImageView*)imageview
{
     
    self.pieceView=imageview;
    pieceView.multipleTouchEnabled = YES;
    pieceView.userInteractionEnabled = YES;

    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    [pieceView setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [self addGestureRecognizersToPiece:pieceView];

    [self addSubview:pieceView];
        
}

- (void)setDragUIView:(UIView*)view
{

    view.multipleTouchEnabled = YES;
    view.userInteractionEnabled = YES;
    
    self.multipleTouchEnabled = YES;
    self.userInteractionEnabled = YES;
    [view setCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2)];
    [self addGestureRecognizersToPiece:view];
    
    [self addSubview:view];
    
}

-(void)dealloc
{
	[pieceView release];
	[super dealloc];	
}

#pragma mark -
#pragma mark === Utility methods  ===
#pragma mark

// scale and rotation transforms are applied relative to the layer's anchor point
// this method moves a gesture recognizer's view's anchor point between the user's fingers
- (void)adjustAnchorPointForGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        UIView *piece = gestureRecognizer.view;
        CGPoint locationInView = [gestureRecognizer locationInView:piece];
        CGPoint locationInSuperview = [gestureRecognizer locationInView:piece.superview];
        
        piece.layer.anchorPoint = CGPointMake(locationInView.x / piece.bounds.size.width, locationInView.y / piece.bounds.size.height);
        piece.center = locationInSuperview;
    }
}

// display a menu with a single item to allow the piece's transform to be reset
- (void)showResetMenu:(UILongPressGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        UIMenuItem *resetMenuItem = [[UIMenuItem alloc] initWithTitle:@"重置" action:@selector(resetPiece:)];
        CGPoint location = [gestureRecognizer locationInView:[gestureRecognizer view]];
        
        [self becomeFirstResponder];
        [menuController setMenuItems:[NSArray arrayWithObject:resetMenuItem]];
        [menuController setTargetRect:CGRectMake(location.x, location.y, 0, 0) inView:[gestureRecognizer view]];
        [menuController setMenuVisible:YES animated:YES];
        
        pieceForReset = [gestureRecognizer view];
        
        [resetMenuItem release];
    }
}

// animate back to the default anchor point and transform
- (void)resetPiece:(UIMenuController *)controller
{
    CGPoint locationInSuperview = [pieceForReset convertPoint:CGPointMake(CGRectGetMidX(pieceForReset.bounds), CGRectGetMidY(pieceForReset.bounds)) toView:[pieceForReset superview]];
    
    [[pieceForReset layer] setAnchorPoint:CGPointMake(0.5, 0.5)];
    [pieceForReset setCenter:locationInSuperview];
    
    [UIView beginAnimations:nil context:nil];
    [pieceForReset setTransform:CGAffineTransformIdentity];
    [UIView commitAnimations];
}

// UIMenuController requires that we can become first responder or it won't display
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark -
#pragma mark === Touch handling  ===
#pragma mark

- (void)panPiece:(UIPanGestureRecognizer *)gestureRecognizer
{
    UIView *piece = [gestureRecognizer view];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [self setBorder:piece display:YES];
        if ([delegate respondsToSelector:@selector(dragViewSubTouched:)]) {
            [delegate dragViewSubTouched:piece.tag];
        }
    }
    
    CGPoint translation = [gestureRecognizer translationInView:self];
    gestureRecognizer.view.center = CGPointMake(gestureRecognizer.view.center.x + translation.x, 
                                         gestureRecognizer.view.center.y + translation.y);
    [gestureRecognizer setTranslation:CGPointMake(0, 0) inView:self];

    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        
        CGPoint velocity = [gestureRecognizer velocityInView:self];
        CGFloat magnitude = sqrtf((velocity.x * velocity.x) + (velocity.y * velocity.y));
        CGFloat slideMult = magnitude / 200;

        float slideFactor = 0.1 * slideMult; // Increase for more of a slide
        CGPoint finalPoint = CGPointMake(gestureRecognizer.view.center.x + (velocity.x * slideFactor), 
                                         gestureRecognizer.view.center.y + (velocity.y * slideFactor));
        finalPoint.x = MIN(MAX(finalPoint.x, 0), self.bounds.size.width);
        finalPoint.y = MIN(MAX(finalPoint.y, 0), self.bounds.size.height);
        
        [UIView animateWithDuration:slideFactor*2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            piece.center = finalPoint;
            [self setBorder:piece display:NO];
        } completion:nil];
        
    }
}

- (void)rotatePiece:(UIRotationGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [gestureRecognizer view].transform = CGAffineTransformRotate([[gestureRecognizer view] transform], [gestureRecognizer rotation]);
        [gestureRecognizer setRotation:0];
        [self setBorder:[gestureRecognizer view] display:YES];
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setBorder:[gestureRecognizer view] display:NO];
    }
}


- (void)scalePiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    [self adjustAnchorPointForGestureRecognizer:gestureRecognizer];
    
    if([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        lastScale = [gestureRecognizer scale];
        [self setBorder:[gestureRecognizer view] display:YES];
    }
    
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || 
        [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[[gestureRecognizer view].layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = 2.0;
        const CGFloat kMinScale = 0.8;
        
        CGFloat newScale = 1 -  (lastScale - [gestureRecognizer scale]); 
        newScale = MIN(newScale, kMaxScale / currentScale);   
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([[gestureRecognizer view] transform], newScale, newScale);
        [gestureRecognizer view].transform = transform;
        
        lastScale = [gestureRecognizer scale];  // Store the previous scale factor for the next pinch gesture call 
    }
    
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setBorder:[gestureRecognizer view] display:NO];
    }

}

- (void)tapPiece:(UIPinchGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan || [gestureRecognizer state] == UIGestureRecognizerStateChanged) {
        [self setBorder:[gestureRecognizer view] display:YES];
        if ([delegate respondsToSelector:@selector(dragViewBackgroundTouched)]) {
            [delegate dragViewBackgroundTouched];
        }
    }
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self setBorder:[gestureRecognizer view] display:NO];
    }
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (void)setBorder:(UIView*)view display:(BOOL)display
{
    if (display) {
        view.layer.borderWidth=2;
        view.layer.borderColor=[[UIColor greenColor]CGColor];
    }
    else {
        view.layer.borderWidth=0;
        view.layer.borderColor=[[UIColor clearColor]CGColor];
    }
    
}

@end
