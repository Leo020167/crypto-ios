//
//  CircleChatFaceView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 11/13/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "CircleChatFaceView.h"



#define FaceWidth					36
#define FaceHeight					34

#define BackspaceIconName           @"7299"
#define BackspaceTag                7299

//读取本地图片
#define TJRLOADIMAGE(file,ext) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle]pathForResource:file ofType:ext]]

//定义UIImage对象
#define TJRIMAGE(A) [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:A ofType:nil]]

#define IMAGE(A) {NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"TJRFace_%@", faceName] ofType:nil];\
UIImage *image = [UIImage imageWithContentsOfFile:path];}

@interface CircleChatFaceView (){
    
}

@end

@implementation CircleChatFaceView

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
    [[NSBundle mainBundle] loadNibNamed:@"CircleChatFaceView" owner:self options:nil];
    CGRect frame = self.allView.frame;
    frame.size = self.frame.size;
    self.allView.frame = frame;
    [self addSubview:self.allView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"TJRNewFace" ofType:@"plist"];
    _faceDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    HorizontalSpacing = 12;
    [self interfaceChange];
}

- (void)interfaceChange {
    if (phoneWidth == 0) phoneWidth = UIScreen.mainScreen.bounds.size.width;
    if (phoneHeight == 0) phoneHeight = UIScreen.mainScreen.bounds.size.height;
    MaxRow = 4;
    VerticalSpacing = 21;
    
    CGRect frame = self.frame;
    frame.size.width = phoneWidth;
    self.frame = frame;
    [self creactFaceView];
    
}

#pragma mark - 生成整个表情View
- (void)creactFaceView {
    @synchronized(self) {
        [self maxPageNum];	// 计算总页面数
        NSArray *allFaces = [self allFaceArray];
        int index = 0;
        int maxNum = MaxRank * MaxRow;
        if (maxNum == 0) return;
        for (NSString *faceName in allFaces) {
            UIButton *btnFace = (UIButton *)[_svFace viewWithTag:[faceName integerValue]];
            
            if (btnFace) [btnFace removeFromSuperview];
            
            if ((index +1) % maxNum == 0) {
                [self addFaceToScrollView:index faceName:BackspaceIconName];
                index++;
            }
            [self addFaceToScrollView:index faceName:faceName];
            index++;
        }
        int page = [self addFaceToScrollView:index faceName:BackspaceIconName] + 1;
        _pageControl.numberOfPages = page;
        _svFace.contentSize = CGSizeMake(self.frame.size.width * page, _svFace.frame.size.height);/* 定义UIScrollView scrollview的滚动范围 */
    }
}

#pragma mark - 生成表情方块并添加到九宫格里
- (int)addFaceToScrollView:(int)index faceName:(NSString *)faceName {
    int currentPage = index / (MaxRank * MaxRow);/* 表情所属页面 */
    UIButton *btnFace = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    btnFace.frame = [self getFrameWithPerRowItemCount:MaxRank perColumItemCount:MaxRow itemWidth:FaceWidth itemHeight:FaceHeight paddingX:HorizontalSpacing paddingY:VerticalSpacing atIndex:index onPage:currentPage];
    NSString *imageName = [NSString stringWithFormat:@"TJRFace_%@@2x.png", faceName];
    [btnFace setBackgroundImage:TJRIMAGE(imageName) forState:UIControlStateNormal];
    [btnFace addTarget:self action:@selector(faceButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    btnFace.tag = [faceName integerValue];
    [_svFace addSubview:btnFace];
    RELEASE(btnFace);
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

#pragma mark - 表情单击事件
- (void)faceButtonOnClick:(UIButton *)btnFace {
    if (btnFace.tag == BackspaceTag) {
        if (_delegate && [_delegate respondsToSelector:@selector(faceOnClickBackspace)]) {
            [_delegate faceOnClickBackspace];
        }
    } else {
        NSString *faceName = [NSString stringWithFormat:@"%ld", (long)btnFace.tag];
        NSArray *keyArray = [_faceDictionary allKeysForObject:faceName];
        
        if (keyArray && (keyArray.count == 1)) {
            NSString *detail = [keyArray objectAtIndex:0];
            if (_delegate && [_delegate respondsToSelector:@selector(faceOnClickWithName:)]) {
                [_delegate faceOnClickWithName:detail];
            }
        }
    }
}

#pragma mark - 将表情图片名排序
- (NSArray *)allFaceArray {
    NSComparator cmptr =^(id obj1, id obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedDescending;
        }
        
        if ([obj1 integerValue] < [obj2 integerValue]) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    };
    
    return [_faceDictionary.allValues sortedArrayUsingComparator:cmptr];
}

#pragma mark - 计算最大页面数
- (void)maxPageNum {
    MaxRank = (int)((float)(self.frame.size.width - HorizontalSpacing) / (float)(FaceWidth + HorizontalSpacing));
    
    HorizontalSpacing = (float)(self.frame.size.width - (MaxRank * FaceWidth)) / (MaxRank + 1);
    VerticalSpacing = (float)(_svFace.frame.size.height - (MaxRow * FaceHeight)) / MaxRow;
}

#pragma mark - UIScrolView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    int page = scrollView.contentOffset.x / self.svFace.frame.size.width;	// 通过滚动的偏移量来判断目前页面所对应的小白点
    
    _pageControl.currentPage = page;										// pagecontroll响应值的变化
}

- (void)setfaceSendBtnEnable:(BOOL)enable{
    if (enable) {
        [_btnSend setBackgroundImage:[UIImage imageNamed:@"circleChat_face_send_btn_b"] forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [_btnSend setBackgroundImage:[UIImage imageNamed:@"circleChat_face_send_btn"] forState:UIControlStateNormal];
        [_btnSend setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }
}

- (IBAction)pageControlValueChanged:(id)sender {
    [_svFace setContentOffset:CGPointMake(self.frame.size.width * _pageControl.currentPage, 0) animated:YES];
}
- (IBAction)face1ButtonClicked:(id)sender {
}
- (IBAction)face2ButtonClicked:(id)sender {
}
- (IBAction)sendButtonClicked:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(faceOnClickSend)]) {
        [_delegate faceOnClickSend];
    }
}

- (void)dealloc {
    self.delegate = nil;
    RELEASE(_faceDictionary);
    [_svFace release];
    [_pageControl release];
    [_allFaceBackgroundImageView release];
    [_allView release];
    [_btnFace1 release];
    [_btnFace2 release];
    [_btnSend release];
    [super dealloc];
}
@end
