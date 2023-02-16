//
//  NewbieHelpView.m
//  TJRtaojinroad
//
//  Created by Jeans on 10/18/12.
//  Copyright (c) 2018 Taojinroad. All rights reserved.
//

#import "NewbieHelpView.h"
#import "TJRDatabase.h"

static const CGFloat kAnimationDuration = 0.3f;
static const CGFloat kCutoutRadius = 2.0f;
static const NSInteger SelfViewTag = 7890;

#define PhoneScreenRect  [UIScreen mainScreen].bounds

@interface NewbieHelpView()<CAAnimationDelegate>
{
    CAShapeLayer *mask;
    NSUInteger markIndex;
}

@property (nonatomic, retain) NSArray *coachMarks;      //同个页面多个指导存储数组，存储字典类型
@property (nonatomic, retain) UILabel *lblCaption;
@property (nonatomic, retain) UIImageView *guideImageView;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) CGFloat cutoutRadius;


@end

@implementation NewbieHelpView
@synthesize currentType;
@synthesize nhDelegate;
@synthesize coachMarks,lblCaption,guideImageView;

/**
	查询页面是否是第一次运行
	@param type
	@returns YES为第一次运行,反之不是
 */
+ (BOOL)checkIsNewbieWithNHType:(NHType)type
{
    __block int totalCount = 0;
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        
        NSString *selectCountStr = [NSString stringWithFormat:@"select count(*) from NewbieGuide where NHType='%d'", type];
        TJRFMResultSet *rs = [db executeQuery:selectCountStr];
        
        if ([rs next]) {
            totalCount = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    
    return totalCount == 0;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Setup
        [self setup];
    }
    return self;
}

- (void)dealloc
{
    [coachMarks release];
    [lblCaption release];
    [guideImageView release];
    [super dealloc];
}

/**
    初始化基本设置
 */
- (void)setup
{
    // Default
    self.tag = SelfViewTag;
    self.animationDuration = kAnimationDuration;
    self.cutoutRadius = kCutoutRadius;
    
    
    // Shape layer mask
    mask = [CAShapeLayer layer];
    [mask setFillRule:kCAFillRuleEvenOdd];
    [mask setFillColor:[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.0 alpha:0.7].CGColor];
    [self.layer addSublayer:mask];
    
    // Capture touches
//    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidTap:)];
//    [self addGestureRecognizer:tapGestureRecognizer];
//    [tapGestureRecognizer release];
    
    // Captions
    self.lblCaption = [[UILabel alloc] initWithFrame:(CGRect){{0.0f, 0.0f}, {0.0, 0.0f}}];
    [lblCaption release];
    self.lblCaption.backgroundColor = [UIColor clearColor];
    self.lblCaption.textColor = [UIColor colorWithRed:0.0 green:189.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    self.lblCaption.font = [UIFont systemFontOfSize:20.0f];
    self.lblCaption.lineBreakMode = NSLineBreakByWordWrapping;
    self.lblCaption.numberOfLines = 0;
    self.lblCaption.textAlignment = NSTextAlignmentCenter;
    self.lblCaption.alpha = 1.0f;
    [self addSubview:self.lblCaption];
    
    // guide image
    guideImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, 0.0)];
    [self addSubview:self.guideImageView];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self userDidTap:nil];
}


#pragma mark - 显示新手指南
- (void)ShowNewbieHelpByNHType:(NHType)type andSuperView:(UIView *)view
{

    currentType = type;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(CURRENT_DEVICE_VERSION < 7.0){
        rect.size.height -= 20;
    }
    
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.frame = rect;
    [self setNewbieHelpComponent];// 设置相对应的新手帮助元素
    //如果存在了本指导页面则不再添加(在竖屏切换横屏时这种特殊情况会出现重新加载)
    if([view viewWithTag:SelfViewTag] == nil){
        [view addSubview:self];	// 显示帮助页面
        [view bringSubviewToFront:self];
    }else{
        NewbieHelpView *oldView = (NewbieHelpView *)[view viewWithTag:SelfViewTag]; //获取基类的这个页面
        [oldView removeFromSuperview]; //将之前存在的删除后再重新添加
        [view addSubview:self];	// 显示帮助页面
        [view bringSubviewToFront:self];
    }

}

#pragma mark - 显示新手指南(主要作用在于某些行情或者其他逻辑较为复杂时,用[[UIScreen mainScreen] bounds]都没办法正常识别时，加入这个变量会更方便)
/**
 @params isPortrait 是否竖屏模式
 */
- (void)ShowNewbieHelpByNHType:(NHType)type andSuperView:(UIView *)view andIsPortrait:(BOOL)isPortrait
{
    
    currentType = type;
    CGRect rect = [[UIScreen mainScreen] bounds];
    if(isPortrait){     //如果是竖屏
        if(rect.size.width > rect.size.height){
            CGFloat temp = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width  = temp;
        }
    }else{      //如果是横屏
        if(rect.size.width < rect.size.height){
            CGFloat temp = rect.size.height;
            rect.size.height = rect.size.width;
            rect.size.width  = temp;
        }
    }
    if(CURRENT_DEVICE_VERSION < 7.0){
        rect.size.height -= 20;
    }
    
    rect.origin.x = 0;
    rect.origin.y = 0;
    self.frame = rect;
    self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
    [self setNewbieHelpComponent];// 设置相对应的新手帮助元素
    //如果存在了本指导页面则不再添加(在竖屏切换横屏时这种特殊情况会出现重新加载)
    if([view viewWithTag:SelfViewTag] == nil){
        [view addSubview:self];	// 显示帮助页面
        [view bringSubviewToFront:self];
    }else{
        NewbieHelpView *oldView = (NewbieHelpView *)[view viewWithTag:SelfViewTag]; //获取基类的这个页面
        [oldView removeFromSuperview]; //将之前存在的删除后再重新添加
        [view addSubview:self];	// 显示帮助页面
        [view bringSubviewToFront:self];
    }


}

#pragma mark - 触摸背景
- (void)userDidTap:(UITapGestureRecognizer *)recognizer
{
    if(coachMarks.count > 0 && [self goToCoachMarkIndexed:markIndex+1]){
        return;
    }
    
    
    // 插入数据库
    [[TJRDatabase shareFMDatabaseQueue] inDatabase:^(TJRFMDatabase *db) {
        NSString *insertStr = [NSString stringWithFormat:@"insert into NewbieGuide(NHType) values('%d')", currentType];
        [db executeUpdate:insertStr];
    }];

    if([nhDelegate respondsToSelector:@selector(newBieHelpViewWillDisappear:)]){
        [nhDelegate newBieHelpViewWillDisappear:self];
    }
    //消失
    [self dismissNewbieHelp];
}

#pragma mark - 消除页面
- (void)dismissNewbieHelp
{
    [UIView animateWithDuration:0.5 animations:^(void){
        self.alpha = 0.0;
    }completion:^(BOOL finished){
        [self removeFromSuperview];
        //[mask removeAllAnimations];
    }];
}

#pragma mark - Cutout modify
//圆角矩形
- (void)setCutoutToRoundedRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToRoundedRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:self.cutoutRadius];
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}

//矩形内切圆
- (void)setCutoutToOvalInRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [maskPath appendPath:cutoutPath];
    
    // Set the new path
    mask.path = maskPath.CGPath;
}

- (void)animateCutoutToOvalInRect:(CGRect)rect
{
    // Define shape
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.bounds];
    UIBezierPath *cutoutPath = [UIBezierPath bezierPathWithOvalInRect:rect];
    [maskPath appendPath:cutoutPath];
    
    // Animate it
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"path"];
    anim.delegate = self;
    anim.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    anim.duration = self.animationDuration;
    anim.fromValue = (__bridge id)(mask.path);
    anim.toValue = (__bridge id)(maskPath.CGPath);
    [mask addAnimation:anim forKey:@"path"];
    mask.path = maskPath.CGPath;
}


#pragma mark - 设置指导图片
- (void)setGuideImage:(UIImage *)guideImage position:(CGPoint)position
{
    guideImageView.image = guideImage;
    [guideImageView setFrame:CGRectMake(position.x, position.y, guideImage.size.width, guideImage.size.height)];
}

#pragma mark - 设置指导文字
- (void)setCaptionText:(NSString *)captionText textFrame:(CGRect)textFrame
{
    [self.lblCaption setText:captionText];
    [self.lblCaption setFrame:textFrame];
}

#pragma mark - 跳转下一个新手指导
- (BOOL)goToCoachMarkIndexed:(NSUInteger)index
{
    // Out of bounds
    if (index >= self.coachMarks.count) {
        [self cleanup];
        return NO;
    }
    
    // Current index
    markIndex = index;
    
    // Coach mark definition
    CoachMarksArrayItem *markDef = [self.coachMarks objectAtIndex:index];
    UIImage *guideImage = markDef.guideImage;
    CGPoint guideImagePos = markDef.guideImagePos;
    CGRect cutoutFrame = markDef.cutoutFrame;
    NSString *captionText = markDef.captionText;
    CGRect captionTextFrame = markDef.captionTextFrame;
    NHCutoutShape cutoutShape = markDef.cutoutShape;

    self.lblCaption.alpha = 0.0f;
    self.lblCaption.frame = captionTextFrame;
    self.lblCaption.text = captionText;
    
    [UIView animateWithDuration:0.3f animations:^{
        self.lblCaption.alpha = 1.0f;
    }];
    
    
    // Animate the cutout
    [self setGuideImage:guideImage position:guideImagePos];
    switch (cutoutShape) {
        case NHCutoutShape_RoundedRect:
            //[self setCutoutToRoundedRect:cutoutFrame];
            [self animateCutoutToRoundedRect:cutoutFrame];
            break;
        case NHCutoutShape_OvalInRect:
            //[self setCutoutToOvalInRect:cutoutFrame];
            [self animateCutoutToOvalInRect:cutoutFrame];
            break;
        default:
            //[self setCutoutToRoundedRect:cutoutFrame];
            [self animateCutoutToRoundedRect:cutoutFrame];
            break;
    }
    
    
    return YES;
}

#pragma mark - Cleanup

- (void)cleanup
{
    self.coachMarks = nil;
}


#pragma mark - 设置对应图片和图片坐标
/**
 *普通的添加新手引导只需要在这里操作
 */
- (void)setNewbieHelpComponent
{
    UIImage *guideImage = nil;      //指引的图片
	switch (currentType) {
        case NH_HomeViewController:         //首页
        {
            CoachMarksArrayItem *item1 = [CoachMarksArrayItem coachMarksArrayItem];
            item1.guideImage = [UIImage imageNamed:@"NH_Gesture_Guide_Down"];
            item1.guideImagePos = CGPointMake(PhoneScreenRect.size.width/2 - 30, PhoneScreenRect.size.height - 135);
            item1.cutoutShape = NHCutoutShape_RoundedRect;
            item1.cutoutFrame = CGRectMake((PhoneScreenRect.size.width - 48)/2, PhoneScreenRect.size.height - 48, 48, 48);
            item1.captionText = @"交易功能，\n随时随地随心交易";
            item1.captionTextFrame = CGRectMake(PhoneScreenRect.size.width/2 - 80, PhoneScreenRect.size.height - 220, 160, 80);
            self.coachMarks = @[item1];
            
            [self goToCoachMarkIndexed:0];
        }
            break;
        case NH_IndexViewController_HotPage:        //热点
            guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];   //指引图片
            [self setCutoutToRoundedRect:CGRectMake(PhoneScreenRect.size.width - 60, [self checkPositionWithDeviceVersion:20], 60, 44)];    //设置高亮坐标与大小
            [self setGuideImage:guideImage position:CGPointMake(PhoneScreenRect.size.width - 45, [self checkPositionWithDeviceVersion:42])];  //设置指引图片位置
            [self setCaptionText:@"更多不同排名" textFrame:CGRectMake(PhoneScreenRect.size.width - 150, [self checkPositionWithDeviceVersion:118], 150, 35)]; //设置标题文字,坐标

            break;
        case NH_IndexViewController_TimePage:   //分时
            guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];   //指引图片
            [self setCutoutToRoundedRect:CGRectMake((PhoneScreenRect.size.width - 220)/2, [self checkPositionWithDeviceVersion:20], 220, 44)];    //设置高亮坐标与大小
            [self setGuideImage:guideImage position:CGPointMake(PhoneScreenRect.size.width - 120, [self checkPositionWithDeviceVersion:42])];  //设置指引图片位置
            [self setCaptionText:@"点击箭头\n切换下一个指数" textFrame:CGRectMake(PhoneScreenRect.size.width - 192, [self checkPositionWithDeviceVersion:130], 160, 90)]; //设置标题文字,坐标
            
            break;
        case NH_StockKeyboard:      //键盘
            guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];   //指引图片
            [self setCutoutToRoundedRect:CGRectMake(80, self.frame.size.height - 210, 160, 160)];    //设置高亮坐标与大小
            [self setGuideImage:guideImage position:CGPointMake(110, PhoneScreenRect.size.height - 130)];  //设置指引图片位置
            [self setCaptionText:@"支持传统股票快捷代码:\n例如: 03 上证指数\n      06 自选股\n             60 泸深涨幅榜\n                 80 五分钟涨速榜\n          88 板块排名" textFrame:CGRectMake(0, self.frame.size.height - 410, 320, 200)]; //设置标题文字,坐标
            
            break;
        case NH_MyHomeViewController:           //我的资料
            guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];   //指引图片
            [self setCutoutToRoundedRect:CGRectMake(PhoneScreenRect.size.width - 60, [self checkPositionWithDeviceVersion:22], 60, 40)];    //设置高亮坐标与大小
            [self setGuideImage:guideImage position:CGPointMake(PhoneScreenRect.size.width - 40, [self checkPositionWithDeviceVersion:40])];  //设置指引图片位置
            [self setCaptionText:@"填写修改完记得保存哦" textFrame:CGRectMake(PhoneScreenRect.size.width - 110, [self checkPositionWithDeviceVersion:50], 100, 200)]; //设置标题文字,坐标
            
            break;
        case NH_SetUpViewController:        //自选股管理
            guideImage = [UIImage imageNamed:@"NH_Gesture_UpOrDown"];   //指引图片
            [self setCutoutToRoundedRect:CGRectMake(0, [self checkPositionWithDeviceVersion:64], PhoneScreenRect.size.width, 50)];    //设置高亮坐标与大小
            [self setGuideImage:guideImage position:CGPointMake(PhoneScreenRect.size.width - 40, [self checkPositionWithDeviceVersion:20])];  //设置指引图片位置
            [self setCaptionText:@"按住拖动\n调整股票排序" textFrame:CGRectMake(PhoneScreenRect.size.width - 220, [self checkPositionWithDeviceVersion:100], 120, 100)]; //设置标题文字,坐标
            
            break;

        case NH_StockViewController_KLinePage:          //K线
        {
            //新手指导内容组
            CoachMarksArrayItem *item1 = [CoachMarksArrayItem coachMarksArrayItem];
            item1.guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];
            item1.guideImagePos = CGPointMake(160, self.frame.size.height - 100);
            item1.cutoutShape = NHCutoutShape_OvalInRect;
            item1.cutoutFrame = CGRectMake(105, self.frame.size.height - 120, 120, 70);
            item1.captionText = @"点击这里\n切换技术指标";
            item1.captionTextFrame = CGRectMake(0, self.frame.size.height - 220, self.frame.size.width, 100);
            
            CoachMarksArrayItem *item2 = [CoachMarksArrayItem coachMarksArrayItem];
            item2.guideImage = [UIImage imageNamed:@"NH_Phone_Rotation"];
            item2.guideImagePos = CGPointMake((self.frame.size.width - item2.guideImage.size.width)/2, [self checkPositionWithDeviceVersion:165]);
            item2.cutoutShape = NHCutoutShape_OvalInRect;
            item2.cutoutFrame = CGRectMake(165, self.frame.size.height - 95, 0, 0); //本来高亮部分不再需要显示时一般设置为CGRectZero的，但由于配合前面指南的过渡性，因此x,y坐标上设定了某些位置，只要设置了w h为0即可消失高亮
            item2.captionText = @"横屏可以查看详细K线哦";
            item2.captionTextFrame = CGRectMake(0, [self checkPositionWithDeviceVersion:330], self.frame.size.width, 20);
            
            self.coachMarks = @[item1,item2];
            [self goToCoachMarkIndexed:0];
        }
            
            break;
        case NH_StockViewController_ShareTime:      //个股竖屏分时
        {
            
            CoachMarksArrayItem *item1 = [CoachMarksArrayItem coachMarksArrayItem];
            item1.guideImage = [UIImage imageNamed:@"NH_Gesture_Shake"];
            item1.guideImagePos = CGPointMake(PhoneScreenRect.size.width/2 - 70, [self checkPositionWithDeviceVersion:PhoneScreenRect.size.height/2 - 200]);  //设置指引图片位置
            item1.cutoutShape = NHCutoutShape_RoundedRect;
            item1.cutoutFrame = CGRectMake(PhoneScreenRect.size.width - 100, 85, 0, 0);
            item1.captionText = @"摇一摇，查看全网投顾诊断该个股";
            item1.captionTextFrame = CGRectMake(PhoneScreenRect.size.width/2 - 110, PhoneScreenRect.size.height/2 - 40, 220, 100);
            
            CoachMarksArrayItem *item2 = [CoachMarksArrayItem coachMarksArrayItem];
            item2.guideImage = [UIImage imageNamed:@"NH_Gesture_Left"];
            item2.guideImagePos = CGPointMake(125, [self checkPositionWithDeviceVersion:220]);
            item2.captionText = @"滑屏切换K线,资料等";
            item2.captionTextFrame = CGRectMake(0, [self checkPositionWithDeviceVersion:315], self.frame.size.width, 30);
            
            CoachMarksArrayItem *item3 = [CoachMarksArrayItem coachMarksArrayItem];
            item3.guideImage = [UIImage imageNamed:@"NH_Phone_Rotation"];
            item3.guideImagePos = CGPointMake((PhoneScreenRect.size.width - item3.guideImage.size.width)/2, [self checkPositionWithDeviceVersion:165]);
            item3.cutoutFrame = CGRectMake(PhoneScreenRect.size.width/2,140 , 0, 0); //本来高亮部分不再需要显示时一般设置为CGRectZero的，但由于配合前面指南的过渡性，因此x,y坐标上设定了某些位置，只要设置了w h为0即可消失高亮
            item3.captionText = @"横屏有更多个股信息";
            item3.captionTextFrame = CGRectMake(0, [self checkPositionWithDeviceVersion:330], PhoneScreenRect.size.width, 20);
            
            CoachMarksArrayItem *item4 = [CoachMarksArrayItem coachMarksArrayItem];
            item4.guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];
            item4.guideImagePos = CGPointMake((PhoneScreenRect.size.width - item4.guideImage.size.width)/2, 140);
            item4.cutoutFrame = CGRectMake(0.0, 104, PhoneScreenRect.size.width, 80);
            item4.captionText = @"点击查看交易明细";
            item4.captionTextFrame = CGRectMake((PhoneScreenRect.size.width - 190)/2, 220, 190, 30);
            
            //新手指导内容组
            self.coachMarks = @[item1,item2,item3,item4];
            [self goToCoachMarkIndexed:0];
        }
            
            break;
        case NH_KLineLandScape:
        {
            /*由于K线横屏的特殊性，因此要检查宽高,如果是宽度少于高度,则调换宽度，而且对于ios7以下还要加上之前高度删去的20(因为之前减的20是现在的宽度)
            相应的，之前没减的宽度要减少20，因为现在已是高度。*/
            if(self.frame.size.width < self.frame.size.height){
                if(CURRENT_DEVICE_VERSION < 7.0){
                    self.frame = CGRectMake(0, 0, self.frame.size.height + 20, self.frame.size.width);
                }else{
                    self.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.width);
                }
            }

            CoachMarksArrayItem *item1 = [CoachMarksArrayItem coachMarksArrayItem];
            item1.guideImage = [UIImage imageNamed:@"NH_Gesture_Tap"];
            item1.guideImagePos = CGPointMake(self.frame.size.width/2 + 50, [self checkPositionWithDeviceVersion:120]);
            item1.cutoutFrame = CGRectMake(0, 75, self.frame.size.width, 150);
            item1.captionText = @"长按可查看某K线详情";
            item1.captionTextFrame = CGRectMake(self.frame.size.width/2 - 30, [self checkPositionWithDeviceVersion:230], 250, 30);

            CoachMarksArrayItem *item2 = [CoachMarksArrayItem coachMarksArrayItem];
            item2.guideImage = [UIImage imageNamed:@"NH_Gesture_LeftOrRight"];
            item2.guideImagePos = CGPointMake(self.frame.size.width/2 + 25, [self checkPositionWithDeviceVersion:120]);
            item2.cutoutFrame = CGRectMake(0, 75, self.frame.size.width, 150);
            item2.captionText = @"用两根手指缩放K线";
            item2.captionTextFrame = CGRectMake(self.frame.size.width/2 - 30, [self checkPositionWithDeviceVersion:230], 200, 30);
            
            CoachMarksArrayItem *item3 = [CoachMarksArrayItem coachMarksArrayItem];
            item3.guideImage = [UIImage imageNamed:@"NH_Gesture_Right"];
            item3.guideImagePos = CGPointMake(self.frame.size.width/2 + 25, [self checkPositionWithDeviceVersion:120]);
            item3.cutoutFrame = CGRectMake(0, 75, self.frame.size.width, 150);
            item3.captionText = @"拖动K线";
            item3.captionTextFrame = CGRectMake(self.frame.size.width/2 - 30, [self checkPositionWithDeviceVersion:230], 200, 30);
            
            self.coachMarks = @[item1,item2,item3];
            [self goToCoachMarkIndexed:0];
        }
            
            break;
        case NH_CircleMainViewController:         //我的圈子
        {
            //新手指导内容组
            CoachMarksArrayItem *item1 = [CoachMarksArrayItem coachMarksArrayItem];
            item1.cutoutShape = NHCutoutShape_OvalInRect;
            item1.cutoutFrame = CGRectMake((CGRectGetWidth(PhoneScreenRect) - 90)/2, 10, 90, 70);
            item1.captionText = @"Redz“圈子”，您要的答案都在这里";
            item1.captionTextFrame = CGRectMake((CGRectGetWidth(PhoneScreenRect) - 280)/2, 80, 280,80);
            
            
            self.coachMarks = @[item1];
            [self goToCoachMarkIndexed:0];
        }
            break;
    }
}


#pragma mark - 填入ios7的某个标准坐标y(必须)判断自动返回ios6或者ios7坐标
- (CGFloat )checkPositionWithDeviceVersion:(float)y
{
    CGFloat convertY = y;
    if(CURRENT_DEVICE_VERSION >= 7.0){
        return convertY;
    }
    return convertY - 20;
}

@end

