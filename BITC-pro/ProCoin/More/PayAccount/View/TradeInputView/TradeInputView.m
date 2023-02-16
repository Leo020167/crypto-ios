//
//  TradeInputView.m
//  TJRtaojinroad
//
//  Created by taojinroad on 1/25/16.
//  Copyright © 2016 淘金路. All rights reserved.
//

#define TradeInputViewNumCount 6

#import "TradeInputView.h"

@interface TradeInputView ()<UITextFieldDelegate>
/** 数字数组 */
@property (nonatomic, retain) NSMutableArray *nums;

/** 返回密码 */
@property (nonatomic, copy) NSString *passWord;

@property (nonatomic, copy) NSString *tempStr;

@end

@implementation TradeInputView


#pragma mark - LazyLoad

- (NSMutableArray *)nums
{
    if (_nums == nil) {
        _nums = [[NSMutableArray alloc]init];
    }
    return _nums;
}

#pragma mark - LifeCircle

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.backgroundColor = [UIColor clearColor];

    }
    return self;
}

/** 注册keyboard通知 */
- (void)setupKeyboardNote
{
    // 删除通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delete) name:TradeKeyboardDeleteButtonClick object:nil];
    
    // 数字通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(number:) name:TradeKeyboardNumberButtonClick object:nil];
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark - Private

// 删除
- (void)delete
{
    [self.nums removeLastObject];

    [self setNeedsDisplay];
}

// 数字
- (void)number:(NSNotification *)note
{
    NSDictionary *userInfo = note.userInfo;
    NSString *numObj = userInfo[TradeKeyboardNumberKey];
    if (self.nums.count > TradeInputViewNumCount) return;
    [self.nums addObject:numObj];

    [self setNeedsDisplay];
    
}

- (void)clean{
    self.tempStr = nil;
    self.passWord = nil;
    [self.nums removeAllObjects];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    // 画图
    UIImage *field = [UIImage imageNamed:@"pay_accout_password_in"];
    
    
    CGFloat x = (self.frame.size.width - field.size.width)/2;
    CGFloat y = (self.frame.size.height - field.size.height)/2;
    CGFloat w = field.size.width;
    CGFloat h = field.size.height;
    [field drawInRect:CGRectMake(x, y, w, h)];
    
    // 画点
    UIImage *pointImage = [UIImage imageNamed:@"pay_accout_password_point"];
    CGFloat pointW = pointImage.size.width;
    CGFloat pointH = pointW;
    CGFloat pointY = 10;
    CGFloat pointX;
    CGFloat margin = (field.size.height - pointH)/2 + y;
    CGFloat padding = (field.size.width/TradeInputViewNumCount - pointW)/2;
    for (int i = 0; i < self.nums.count; i++) {
        pointX = x + padding + i * (pointW + 2 * padding);
        pointY = margin;
        [pointImage drawInRect:CGRectMake(pointX, pointY, pointW, pointH)];
    }
    
    // 按钮状态
    BOOL statue = NO;
    if (self.nums.count == TradeInputViewNumCount) {
        statue = YES;
    } else {
        statue = NO;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(tradeInputView:statue:)]) {
        [_delegate tradeInputView:self statue:statue];
    }
}

/** 响应者 */
- (void)setupResponsder
{
    UITextField *responsder = [[[UITextField alloc] init]autorelease];
    responsder.delegate = self;
    responsder.keyboardType = UIKeyboardTypeNumberPad;
    
    [self addSubview:responsder];
    self.responsder = responsder;
}

/**
 *  处理字符串 和 删除键
 */
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (!_tempStr) {
        self.tempStr = string;
    }else{
        self.tempStr = [NSString stringWithFormat:@"%@%@",_tempStr,string];
    }
    
    if (self.tempStr.length > TradeInputViewNumCount) {
        NSMutableString *str = [[[NSMutableString alloc]init]autorelease];
        [str appendString:self.tempStr];
        [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
        self.tempStr = str;
        return YES;
    }
    
    if ([string isEqualToString:@""]) {
        
        [self delete];
        
        if (_tempStr.length > 0) {   //  删除最后一个字符串
            NSString *cccc = [_tempStr substringToIndex:[_tempStr length] - 1];
            self.tempStr = cccc;
        }

    }else{
        
        if (_tempStr.length == TradeInputViewNumCount) {
           
            
            // 通知代理\传递密码
            if (_delegate && [_delegate respondsToSelector:@selector(tradeInputView:finish:)]) {
                [_delegate tradeInputView:self finish:_tempStr];
            }
            
            // 回调block\传递密码
            if (self.finish) {
                self.finish(_tempStr);
            }
        }
        
        NSMutableDictionary *userInfoDict = [NSMutableDictionary dictionary];
        userInfoDict[TradeKeyboardNumberKey] = string;
        [[NSNotificationCenter defaultCenter] postNotificationName:TradeKeyboardNumberButtonClick object:self userInfo:userInfoDict];
    }
    return YES;
}

- (BOOL)becomeFirstResponder{
    
    [self setupResponsder];
    [self setupKeyboardNote];
    return [self.responsder becomeFirstResponder];
}

- (BOOL)resignFirstResponder{
    
    BOOL r =  [self.responsder resignFirstResponder];
    self.responsder = nil;
    self.tempStr = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return r;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_nums release];
    self.tempStr = nil;
    [super dealloc];
}
@end
