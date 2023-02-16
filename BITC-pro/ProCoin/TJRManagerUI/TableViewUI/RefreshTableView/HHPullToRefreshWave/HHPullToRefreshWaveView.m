//
//  HHPullToRefrshWaveView.m
//  HHPullToRefreshWaveView
//
//  Created by Herui on 15/12/24.
//  Copyright © 2015年 harry. All rights reserved.
//

#import "HHPullToRefreshWaveView.h"

static CGFloat HHMaxVariable = 3.0;
static CGFloat HHMinVariable = 1.0;
static CGFloat HHMinStepLength = 0;
static CGFloat HHMaxStepLength = 0;

static NSString *HHKeyPathsContentOffset = @"contentOffset";
static NSString *HHKeyPathsContentInset = @"ContentInset";
static NSString *HHKeyPathsFrame = @"frame";
static NSString *HHKeyPathsPanGestureRecognizerState = @"panGestureRecognizer.state";

typedef NS_ENUM(NSUInteger, HHPullToRefreshWaveViewState) {
    HHPullToRefreshWaveViewStopped,
    HHPullToRefreshWaveViewAnimating,
    HHPullToRefreshWaveViewAnimatingToStopped,
};


@interface HHPullToRefreshWaveView ()
{
    CGFloat _amplitude;
    CGFloat _cycle;
    CGFloat _offsetX;
    CGFloat _offsetY;
    CGFloat _variable;
    CGFloat _height;
    BOOL _increase;
    
    CGFloat originalContentInsetTop;
}


@property (nonatomic, strong) CADisplayLink *displaylink;
@property (nonatomic, strong) CAShapeLayer  *secondWaveLayer;
@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic) HHPullToRefreshWaveViewState state;
@property (nonatomic) NSUInteger times;

@end

@implementation HHPullToRefreshWaveView

#pragma mark - Init
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    [self setup];
    return self;
}

- (void)setup {
    _displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTric:)];
    _displaylink.frameInterval = 2;
    [_displaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    _displaylink.paused = YES;
    
    
    _secondWaveLayer = [CAShapeLayer layer];
    _secondWaveLayer.fillColor = [UIColor whiteColor].CGColor;
    
    _topWaveColor = [UIColor lightGrayColor];
    _bottomWaveColor = [UIColor whiteColor];
    
    [self setupProperty];
   
}

#pragma mark - Setter && Getter
- (void)setScrollView:(UIScrollView *)scrollView {
    _scrollView = scrollView;
    _cycle = 2 * M_PI / scrollView.frame.size.width;
  
}

- (void)setBottomWaveColor:(UIColor *)bottomWaveColor {
    _bottomWaveColor = bottomWaveColor;
    _secondWaveLayer.fillColor = bottomWaveColor.CGColor;
}

- (void)setupProperty
{
    _times = 1;
    _amplitude = HHMaxVariable;
    _variable = HHMaxVariable;
    _increase = NO;
    
}

- (CGFloat)currentHeight {
    if (!self.scrollView) {
        return 0.0;
    }
    return MAX(-originalContentInsetTop + 4* _height, 0);
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    
    if (!self.scrollView) {
        return;
    }
    
    if ([keyPath isEqualToString:HHKeyPathsContentOffset]) {
            [self scrollViewDidChangeContentOffset];
        
    } else if ([keyPath isEqualToString:HHKeyPathsFrame]) {

    } else if ([keyPath isEqualToString:HHKeyPathsContentInset]) {
        originalContentInsetTop = [change[NSKeyValueChangeNewKey] UIEdgeInsetsValue].top;
    } else if ([keyPath isEqualToString:HHKeyPathsPanGestureRecognizerState]) {

    }
}

#pragma mark - Event

- (void)scrollViewDidChangeContentOffset {
    
    CGFloat offset = (-self.scrollView.contentOffset.y-self.scrollView.contentInset.top);
    if (offset < 0.00) {
        _times = 0;
    }
    
    _times = offset/10 + 1;

    if (offset == 0.00 && self.scrollView.isDecelerating) {
         [self animatingStopWave];
    }
    if (offset >= 0.00 && !self.scrollView.isDecelerating && self.state != HHPullToRefreshWaveViewAnimating && self.scrollView.isTracking) {
         [self startWave];
    }
}

- (void)displayLinkTric:(CADisplayLink *)displayLink {
    
    [self configWaveAmplitude];
    [self configWaveOffset];
    
    [self configViewFrame];
    [self configSecondWaveLayerPath];
    
}
- (void)configWaveAmplitude {
    
    if (_increase) {
        _variable += HHMinStepLength;
    } else {
        CGFloat minus = self.state == HHPullToRefreshWaveViewAnimatingToStopped ? HHMaxStepLength : HHMinStepLength;
        _variable -= minus;
        if (_variable <= 0.00) {
            [self stopWave];
        }
    }
    
    if (_variable <= HHMinVariable) {
        _increase = self.state == HHPullToRefreshWaveViewAnimatingToStopped ? NO : YES;
    }
    
    if (_variable >= HHMaxVariable) {
        _increase = NO;
    }
    
    _amplitude = _variable*_times/2;
    _height = HHMaxVariable*_times;

}

- (void)configWaveOffset {

    _offsetY =  [self currentHeight] - _amplitude;
}


- (void)configSecondWaveLayerPath {
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGFloat y = _offsetY;
    CGPathMoveToPoint(path, nil, 0, y);

    CGFloat waveWidth = self.scrollView.frame.size.width;
    for (float x = 0.0f; x <=  waveWidth ; x++) {
        y = _amplitude * cos(_cycle*x) + _offsetY;
        CGPathAddLineToPoint(path, nil, x, y);
    }
    
    CGPathAddLineToPoint(path, nil, waveWidth, self.frame.size.height);
    CGPathAddLineToPoint(path, nil, 0, self.frame.size.height);
    CGPathCloseSubpath(path);
    
    _secondWaveLayer.path = path;
    CGPathRelease(path);
}


- (void)configViewFrame {
    CGFloat width = self.scrollView.bounds.size.width;
    CGFloat height = [self currentHeight];
    self.frame = CGRectMake(0, -height, width, height);
}

#pragma mark - Public Fuc
- (void)startWave {
   
    if (self.displaylink.paused == NO) {
        self.secondWaveLayer.path = nil;
        [self.secondWaveLayer removeFromSuperlayer];
    }
    
    [self setupProperty];
    
    self.state = HHPullToRefreshWaveViewAnimating;
    [self.layer addSublayer:self.secondWaveLayer];
    self.displaylink.paused = NO;
}

- (void)stopWave {
   
    self.state = HHPullToRefreshWaveViewStopped;
    self.displaylink.paused = YES;
    self.secondWaveLayer.path = nil;
    [self.secondWaveLayer removeFromSuperlayer];
}

- (void)animatingStopWave {
    self.state = HHPullToRefreshWaveViewAnimatingToStopped;
    if (self.actionHandler) {
        self.actionHandler();
    }
}

- (void)observeScrollView:(UIScrollView *)scrollView {
    self.scrollView = scrollView;
    [self.scrollView addObserver:self forKeyPath:HHKeyPathsContentOffset options:NSKeyValueObservingOptionNew context:nil];
    [self.scrollView addObserver:self forKeyPath:HHKeyPathsPanGestureRecognizerState options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserverScrollView:(UIScrollView *)scrollView {
    [scrollView removeObserver:self forKeyPath:HHKeyPathsContentOffset];
    [scrollView removeObserver:self forKeyPath:HHKeyPathsPanGestureRecognizerState];
    
}

- (void)invalidateWave {
    [self.displaylink invalidate];
    
}



@end
