//
//  OTCover.m
//  OTMediumCover
//
//  Created by yechunxiao on 14-9-21.
//  Copyright (c) 2014年 yechunxiao. All rights reserved.
//

#import "OTCover.h"
#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@interface OTCover()

@property (nonatomic, strong) NSMutableArray *blurImages;
@property (nonatomic, assign) CGFloat OTCoverHeight;
@property (nonatomic, strong) UIView* scrollHeaderView;

@end

@implementation OTCover

@synthesize delegate,headerImageView,tableView;

+ (OTCover*)initWithTableViewWithHeaderImageUrl:(NSString *)headerImageUrl withOTCoverHeight:(CGFloat)height
{
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    OTCover *otCover = [[[OTCover alloc] initWithFrame:bounds] autorelease];
    otCover.backgroundColor = [UIColor clearColor];
    otCover.headerImageView = [[[TJRImageAndDownFile alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height)] autorelease];
    otCover.headerImageView.isContentMode = YES;
    otCover.headerImageView.clipsToBounds = YES;
    otCover.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    [otCover.headerImageView showImageViewWithURL:headerImageUrl canTouch:NO];
    otCover.headerImageView.hidden = YES;
    
    [otCover addSubview:otCover.headerImageView];
    
    otCover.OTCoverHeight = height;
    
    otCover.tableView = [[[UITableView alloc] initWithFrame:otCover.frame] autorelease];
    otCover.tableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    otCover.tableView.tableHeaderView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, height - 25)] autorelease];
    otCover.tableView.backgroundColor = [UIColor clearColor];
    [otCover addSubview:otCover.tableView];
    
    [otCover.tableView addObserver:otCover forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
    
    otCover.blurImages = [[[NSMutableArray alloc] init] autorelease];
    [otCover prepareForBlurImages];
    
    return otCover;
}

- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    [headerImageView release];
    [tableView release];
    [super dealloc];
}

- (void)setHeaderImageUrl:(NSString *)headerImageUrl{
    self.headerImageView.hidden = NO;
    [self.headerImageView showImageViewWithURL:headerImageUrl canTouch:NO];
    [self.blurImages removeAllObjects];
    [self prepareForBlurImages];
}

- (void)prepareForBlurImages
{
    CGFloat factor = 0.1;
    [self.blurImages addObject:self.headerImageView.image];
    for (NSUInteger i = 0; i < self.OTCoverHeight/10; i++) {
        [self.blurImages addObject:[self.headerImageView.image boxblurImageWithBlur:factor]];
        factor+=0.04;
    }
}

- (void)animationForTableView{
    CGFloat offset = self.tableView.contentOffset.y;
    
    if([delegate respondsToSelector:@selector(otCoverDidScrollingContentOffset:tableViewOffSet:)]){
        [delegate otCoverDidScrollingContentOffset:self tableViewOffSet:self.tableView.contentOffset];
    }
    
    if (self.tableView.contentOffset.y > 0) {
        
        NSInteger index = offset / 10;
        if (index < 0) {
            index = 0;
        }
        else if(index >= self.blurImages.count) {
            index = self.blurImages.count - 1;
        }
        UIImage *image = self.blurImages[index];
        if (self.headerImageView.image != image) {
            [self.headerImageView setImage:image];
            
        }
        self.tableView.backgroundColor = [UIColor clearColor];
        
    }
    else {
        self.headerImageView.frame = CGRectMake(offset,0, self.frame.size.width+ (-offset) * 2, self.OTCoverHeight + (-offset));
    }
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self animationForTableView];
}




@end

//from https://github.com/cyndibaby905/TwitterCover

@implementation UIImage (Blur)

-(UIImage *)boxblurImageWithBlur:(CGFloat)blur {
    
    NSData *imageData = UIImageJPEGRepresentation(self, 1); // convert to jpeg
    UIImage* destImage = [UIImage imageWithData:imageData];
    
    
    if (blur < 0.f || blur > 1.f) {
        blur = 0.5f;
    }
    int boxSize = (int)(blur * 40);
    boxSize = boxSize - (boxSize % 2) + 1;
    
    CGImageRef img = destImage.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    
    vImage_Error error;
    
    void *pixelBuffer;
    
    
    //create vImage_Buffer with data from CGImageRef
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //create vImage_Buffer for output
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    if(pixelBuffer == NULL)
        NSLog(@"No pixelbuffer");
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    // Create a third buffer for intermediate processing
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //perform convolution
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             (CGBitmapInfo)kCGImageAlphaNoneSkipLast);
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
    
    CGImageRelease(imageRef);
    
    return returnImage;
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
