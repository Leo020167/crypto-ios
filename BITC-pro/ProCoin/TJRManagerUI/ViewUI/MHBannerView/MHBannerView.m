//
//  MHBannerView.m
//  Cropyme
//
//  Created by Hay on 2019/7/9.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "MHBannerView.h"
#import "RZWebImageView.h"

@interface MHBannerView()<UIScrollViewDelegate>
{
    UIPageControl *pageControll;
    NSTimer *scrollTimer;
}

@property (retain, nonatomic) UIScrollView *coreScrollView;

@end

@implementation MHBannerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self){
        [self initialBannerView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self){
        [self initialBannerView];
    }
    return self;
}

- (void)dealloc
{
    [_dataArray release];
    [pageControll release];
    [_coreScrollView release];
    [super dealloc];
}

/** 初始化*/
- (void)initialBannerView
{
    pageControll = [[UIPageControl alloc] initWithFrame:CGRectMake(0.0, self.frame.size.height - 42, self.frame.size.width, 37)];
    pageControll.numberOfPages = 10;
    self.userInteractionEnabled = YES;
    self.coreScrollView = [[[UIScrollView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)] autorelease];
    UITapGestureRecognizer *gesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDidTap:)] autorelease];
    [self.coreScrollView addGestureRecognizer:gesture];
    _coreScrollView.delegate = self;
    _coreScrollView.pagingEnabled = YES;
    _coreScrollView.bounces = YES;
    if (@available(iOS 11.0, *)) {
        self.coreScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
//    _coreScrollView.contentInset = UIEdgeInsetsZero;

    [self addSubview:_coreScrollView];
    [self addSubview:pageControll];
    
    
}

#pragma mark - 赋值数据源
- (void)setDataArray:(NSArray<NSString *> *)dataArray
{
    if(_dataArray != nil){
        [_dataArray release];
        _dataArray = nil;
    }
    _dataArray = [dataArray copy];
    
    [_coreScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    if([dataArray count] == 0){
        return;
    }

    pageControll.numberOfPages = [dataArray count];
    pageControll.currentPage = 0;
    if([dataArray count] == 1){
        NSString *urlString = [dataArray lastObject];
        RZWebImageView *imageView = [[[RZWebImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _coreScrollView.frame.size.width, self.frame.size.height)] autorelease];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView showImageWithUrl:urlString placeholderImage:RZWebImageViewDefaultRectanglePlaceHolderImage];
        [_coreScrollView addSubview:imageView];
    }else{
        /** 保证整个banner能重复连播，在第一个添加最后一张图片，在最后一个添加第一张图片*/
        NSString *lastStringUrl = [dataArray lastObject];
        RZWebImageView *firstImageView = [[[RZWebImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, _coreScrollView.frame.size.width, self.frame.size.height)] autorelease];
        firstImageView.contentMode = UIViewContentModeScaleAspectFill;
        firstImageView.clipsToBounds = YES;
        [_coreScrollView addSubview:firstImageView];
        [firstImageView showImageWithUrl:lastStringUrl placeholderImage:RZWebImageViewDefaultRectanglePlaceHolderImage];

        for(int i = 0; i < [dataArray count]; i++){
            NSString *urlString = [dataArray objectAtIndex:i];
            RZWebImageView *imageView = [[[RZWebImageView alloc] initWithFrame:CGRectMake(_coreScrollView.frame.size.width * (i + 1), 0.0, _coreScrollView.frame.size.width, self.frame.size.height)] autorelease];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            imageView.clipsToBounds = YES;
            [_coreScrollView addSubview:imageView];
            [imageView showImageWithUrl:urlString placeholderImage:RZWebImageViewDefaultRectanglePlaceHolderImage];
        }

        NSString *firstStringUrl = [dataArray firstObject];
        RZWebImageView *lastImageView = [[[RZWebImageView alloc] initWithFrame:CGRectMake(_coreScrollView.frame.size.width * ([dataArray count] + 1), 0.0, _coreScrollView.frame.size.width, self.frame.size.height)] autorelease];
        lastImageView.contentMode = UIViewContentModeScaleAspectFill;
        [lastImageView showImageWithUrl:firstStringUrl placeholderImage:RZWebImageViewDefaultRectanglePlaceHolderImage];
        lastImageView.clipsToBounds = YES;
        [_coreScrollView addSubview:lastImageView];

        [_coreScrollView setContentSize:CGSizeMake(([dataArray count] + 2) * _coreScrollView.frame.size.width, self.frame.size.height)];
        [_coreScrollView setContentOffset:CGPointMake(_coreScrollView.frame.size.width, 0.0)];


    }
}

#pragma mark - 设置是否自动滚动
- (void)setAutoScroll:(BOOL)autoScroll
{
    if(autoScroll){
        [self startScrollTimer];
    }else{
        [self closeScrollTimer];
    }
}


#pragma mark - 开启关闭定时器
- (void)startScrollTimer
{
    [self closeScrollTimer];
    scrollTimer = [NSTimer timerWithTimeInterval:3.0 target:self selector:@selector(autoScrollBannerImage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:scrollTimer forMode:NSRunLoopCommonModes];
}

- (void)closeScrollTimer
{
    if(scrollTimer != nil && scrollTimer.isValid){
        [scrollTimer invalidate];
        scrollTimer = nil;
    }
}

#pragma mark - 滚动banner
- (void)autoScrollBannerImage
{
    if([_dataArray count] <= 0){
        return;
    }
    if([_dataArray count] == 1)
        return;
    CGPoint point = _coreScrollView.contentOffset;
    [_coreScrollView setContentOffset:CGPointMake(point.x + self.frame.size.width, 0.0) animated:YES];
    
}

#pragma mark - scroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint point = scrollView.contentOffset;
    if(point.x  >= _coreScrollView.contentSize.width - self.frame.size.width){
        [scrollView setContentOffset:CGPointMake(self.frame.size.width, 0.0) animated:NO];
        pageControll.currentPage = 0;
    }else if(point.x == 0){
        [scrollView setContentOffset:CGPointMake(_coreScrollView.contentSize.width - self.frame.size.width - self.frame.size.width, 0.0) animated:NO];
        pageControll.currentPage = [_dataArray count] -1;
    }else{
        NSInteger currentPage = (NSInteger)(point.x) / (NSInteger)(_coreScrollView.frame.size.width) - 1;
        pageControll.currentPage = currentPage;//将上述的滚动视图页数重新赋给当前视图页数,进行分页
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self closeScrollTimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self startScrollTimer];
}

#pragma mark - tap gesture
- (void)scrollViewDidTap:(UIGestureRecognizer *)rec
{
    if([_delegate respondsToSelector:@selector(bannerViewDidTapImage:)]){
        //由于前后各额外增加了1个图片，所以需要逻辑处理下保证点的索引为正确索引
        if([_dataArray count] > 1){
            NSInteger index = _coreScrollView.contentOffset.x / _coreScrollView.frame.size.width - 1;
            if(index < 0 || index >= [_dataArray count]){
                return;
            }
            [_delegate bannerViewDidTapImage:index];
        }else{      //只有1个数据时
            if([_dataArray count] == 0)
                return;
            NSInteger index = 0;
            [_delegate bannerViewDidTapImage:index];
        }
        
    }
}
@end
