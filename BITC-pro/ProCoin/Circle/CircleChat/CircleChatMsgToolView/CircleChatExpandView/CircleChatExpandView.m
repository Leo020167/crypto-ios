//
//  CircleChatExpandView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatExpandView.h"
#import "UIImage+Size.h"
#import "TZImagePickerController.h"

#define kAmountInEachPage	8	// 每页数量
#define btnWidth			60
#define totalHeight			80

@interface CircleChatExpandView ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,TZImagePickerControllerDelegate>{

    float VerticalSpacing;
    float HorizontalSpacing;
    int MaxRank;/* 最大列数 */
    int MaxRow;	/* 最大行数 */
    float phoneHeight;
    float phoneWidth;
    
    UIImagePickerController *cameraPicker;

}
@property (retain, nonatomic) IBOutlet UIPageControl *pageControl;
@property (retain, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CircleChatExpandView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializationFaceView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializationFaceView];
    }
    return self;
}

- (void)initializationFaceView {
    [[NSBundle mainBundle] loadNibNamed:@"CircleChatExpandView" owner:self options:nil];
    CGRect frame = self.allView.frame;
    frame.size = self.frame.size;
    self.allView.frame = frame;
    [self addSubview:self.allView];

    frame = self.frame;
    frame.size.width = UIScreen.mainScreen.bounds.size.width;
    self.frame = frame;

    MaxRow = 2;
    VerticalSpacing = 10;
    HorizontalSpacing = 20;
    
    [self creactView];
}

- (void)setBAdmin:(BOOL)bAdmin{
    _bAdmin = bAdmin;
    
    NSArray *views = [self.scrollView subviews];
    for(int i = 0 ; i < [views count] ; i++)
        [[views objectAtIndex:i] removeFromSuperview];
    
    [self creactView];
}

- (void)setBPrivate:(BOOL)bPrivate{
    _bPrivate = bPrivate;
    
    NSArray *views = [self.scrollView subviews];
    for(int i = 0 ; i < [views count] ; i++)
        [[views objectAtIndex:i] removeFromSuperview];
    
    [self creactView];
}


#pragma mark - 生成整个View
- (void)creactView {
    @synchronized(self) {
        [self maxPageNum];	// 计算总页面数
        
        NSArray *btnImageNameArray;
        NSArray *btnTitleArray;
        NSArray *btnTagArray;
        
        if (_bPrivate) {
            btnImageNameArray = [NSArray arrayWithObjects:@"circleChat_extend_btn_image", @"circleChat_extend_btn_camera", nil];
            btnTitleArray = [NSArray arrayWithObjects: @"图片", NSLocalizedStringForKey(@"拍照"), nil];
            btnTagArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:CETpicture], [NSNumber numberWithInt:CETcamera], nil];
            
        }else {
            if (_bAdmin) {
                btnImageNameArray = [NSArray arrayWithObjects:@"circleChat_extend_btn_image", @"circleChat_extend_btn_camera", nil];
                btnTitleArray = [NSArray arrayWithObjects: @"图片", NSLocalizedStringForKey(@"拍照"), nil];
                btnTagArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:CETpicture], [NSNumber numberWithInt:CETcamera], nil];
                
            }else{
                btnImageNameArray = [NSArray arrayWithObjects:@"circleChat_extend_btn_image", @"circleChat_extend_btn_camera", nil];
                btnTitleArray = [NSArray arrayWithObjects: @"图片", NSLocalizedStringForKey(@"拍照"), nil];
                btnTagArray = [NSArray arrayWithObjects: [NSNumber numberWithInt:CETpicture], [NSNumber numberWithInt:CETcamera], nil];
            }
        }
        
        NSAssert(btnImageNameArray.count == btnTitleArray.count, @"名字与图片数目必须相等");
        
        int index = 0;
        int maxNum = MaxRank * MaxRow;
        if (maxNum == 0) return;
        
        for (int i=0; i<btnImageNameArray.count; i++) {
            
            [self addFaceToScrollView:index name:[btnTitleArray objectAtIndex:i] imageName:[btnImageNameArray objectAtIndex:i] tag:[btnTagArray objectAtIndex:i]];
            index++;
        }

        int page;
        
        if (index % (MaxRank * MaxRow)==0) {
            page = index/(MaxRank * MaxRow);
            
        }else {
            page = index/(MaxRank * MaxRow)+1;
        }
        
        _pageControl.numberOfPages = page;
        _scrollView.contentSize = CGSizeMake(self.frame.size.width * page + 1, _scrollView.frame.size.height);/* 定义UIScrollView scrollview的滚动范围 */
    }
}

#pragma mark - 生成表情方块并添加到九宫格里
- (int)addFaceToScrollView:(int)index name:(NSString *)name imageName:(NSString *)imageName tag:(NSNumber*)tag{
    
    int currentPage = index / (MaxRank * MaxRow);/* 表情所属页面 */
    
    UIButton *btn = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    CGRect frame = [self getFrameWithPerRowItemCount:MaxRank perColumItemCount:MaxRow itemWidth:btnWidth itemHeight:totalHeight paddingX:HorizontalSpacing paddingY:VerticalSpacing atIndex:index onPage:currentPage];
    btn.frame = CGRectMake(frame.origin.x, frame.origin.y, btnWidth, totalHeight - 20);
    
    [btn setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.tag = [tag integerValue];
    [_scrollView addSubview:btn];

    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(btn.frame.origin.x, btn.frame.origin.y+btn.frame.size.height, btn.frame.size.width, 20)];
    label.text = name;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:13];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = RGBA(191, 191, 191, 1);
    [_scrollView addSubview:label];
    
    [label release];
    [btn release];
    
    return currentPage;
}

/**
 *  通过目标的参数，获取一个grid布局
 *
 *  @param perRowItemCount   每行有多少列
 *  @param perColumItemCount 每列有多少行
 *  @param itemWidth         gridItem的宽度
 *  @param itemHeight        gridItem的高度
 *  @param paddingX          gridItem之间的X轴间隔
 *  @param paddingY          gridItem之间的Y轴间隔
 *  @param index             某个gridItem所在的index序号
 *  @param page              某个gridItem所在的页码
 *
 *  @return 返回一个已经处理好的gridItem frame
 */
- (CGRect)getFrameWithPerRowItemCount:(NSInteger)perRowItemCount
                    perColumItemCount:(NSInteger)perColumItemCount
                            itemWidth:(CGFloat)itemWidth
                           itemHeight:(NSInteger)itemHeight
                             paddingX:(CGFloat)paddingX
                             paddingY:(CGFloat)paddingY
                              atIndex:(NSInteger)index
                               onPage:(NSInteger)page {
    CGRect itemFrame = CGRectMake((index % perRowItemCount) * (itemWidth + paddingX) + paddingX + (page * CGRectGetWidth(self.bounds)), ((index / perRowItemCount) - perColumItemCount * page) * (itemHeight + paddingY) + paddingY, itemWidth, itemHeight);
    return itemFrame;
}

#pragma mark - 计算最大页面数
- (void)maxPageNum {
    
    MaxRank = (int)((float)(self.frame.size.width - HorizontalSpacing) / (float)(btnWidth + HorizontalSpacing));
    HorizontalSpacing = (float)(self.frame.size.width - (MaxRank * btnWidth)) / (MaxRank + 1);
    VerticalSpacing = (float)(_scrollView.frame.size.height - (MaxRow * totalHeight)) / MaxRow;
}

#pragma mark - UIScrolView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / _scrollView.frame.size.width;	// 通过滚动的偏移量来判断目前页面所对应的小白点
    
    _pageControl.currentPage = page;										// pagecontroll响应值的变化
}

- (IBAction)pageControlValueChanged:(id)sender {
    [_scrollView setContentOffset:CGPointMake(self.frame.size.width * _pageControl.currentPage, 0) animated:YES];
}

- (void)buttonOnClick:(id)sender{
    UIButton* btn = (UIButton*)sender;
    switch (btn.tag) {
        case CETpicture:
        {
            [self getInAlbum];
            break;
        }
        case CETcamera:
        {
            [self getInCamera];
            break;
        }
        case CETpaper:
        {
            [self paper];
            break;
        }
        default:
            break;
    }
}

#pragma mark - 从相册获取照片
- (void)getInAlbum {

    TZImagePickerController* photoPicker = [[[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:self]autorelease];
    photoPicker.allowPickingVideo = NO;
    photoPicker.allowPickingOriginalPhoto = NO;
    photoPicker.allowTakePicture = NO;
    [photoPicker setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets,BOOL isSelectOriginalPhoto) {
        
    }];
    [ROOTCONTROLLER.navigationController.topViewController presentViewController:photoPicker animated:YES completion:nil];
}

#pragma mark - 从相机获取照片
- (void)getInCamera {
    if (!cameraPicker) {
        cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.delegate = self;
        cameraPicker.allowsEditing = YES;
    }
    cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [ROOTCONTROLLER.navigationController.topViewController presentViewController:cameraPicker animated:YES completion:nil];

}

#pragma mark - UIImagePickerControllerDelegate Methods
- (void) imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{
    [picker dismissViewControllerAnimated:YES completion:nil];

    if ([_delegate respondsToSelector:@selector(expandView:image:)]) {
        [_delegate expandView:self image:image];
    }

}

#pragma mark TZImagePickerControllerDelegate
/// User finish picking photo，if assets are not empty, user picking original photo.
/// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray<UIImage *> *)photos sourceAssets:(NSArray *)assets isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto
{
    if ([_delegate respondsToSelector:@selector(expandView:image:)]) {
        UIImage* image = [photos lastObject];
        if (image) {
            [_delegate expandView:self image:image];
        }
    }

}


/// User finish picking video,
/// 用户选择好了视频
- (void)stockKeyboard{
    
}



- (void)paper{
    if ([_delegate respondsToSelector:@selector(expandViewOnPaper:)]) {
        [_delegate expandViewOnPaper:self];
    }
}

- (void)dealloc {
    [cameraPicker release];
    [_pageControl release];
    [_scrollView release];
    [super dealloc];
}


@end
