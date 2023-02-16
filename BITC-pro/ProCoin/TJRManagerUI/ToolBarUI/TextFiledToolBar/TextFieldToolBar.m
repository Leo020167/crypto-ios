//
//  TextFieldToolBar.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-8.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TextFieldToolBar.h"

@implementation TextFieldToolBar
@synthesize tfDelegate;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)dealloc{
    [super dealloc];
}

/**
	专门针对textField 的 toolbar
	@param delegate 委托对象
	@param num textField数量
	@returns 实例
 */
- (id)initWithDelegate:(id)delegate numOfTextField:(NSUInteger)num
{
    if (num == 1) {
        self = [super initWithDelegate:self
                            TitleArray:[NSArray arrayWithObjects:NSLocalizedStringForKey(@"完成"), nil]
                         selectorArray:@selector(doneField:),nil];
    }else{
        self = [super initWithDelegate:self
                            TitleArray:[NSArray arrayWithObjects:NSLocalizedStringForKey(@"上一步"),NSLocalizedStringForKey(@"下一步"),NSLocalizedStringForKey(@"完成"), nil]
                         selectorArray:@selector(previousField:),@selector(nextField:),@selector(doneField:),nil];
    }
    
    if (self) {
        tfDelegate = delegate;
        fieldCount = num;
        
    }
    return self;
}


- (void)previousField:(id)sender{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [(UITextField *)firstResponder tag];
        NSUInteger previousTag = tag == 1 ? 1 : tag - 1;
        [self checkBarButton:previousTag];
        
        if ([tfDelegate respondsToSelector:@selector(TFAnimateView:)])
            [tfDelegate TFAnimateView:previousTag];
        
        UIViewController *viewControl = (UIViewController*)tfDelegate;
        
        UITextField *previousField = (UITextField *)[viewControl.view viewWithTag:previousTag];
        [previousField becomeFirstResponder];
    }
}

- (void)nextField:(id)sender{
    id firstResponder = [self getFirstResponder];
    if ([firstResponder isKindOfClass:[UITextField class]]) {
        NSUInteger tag = [(UITextField *)firstResponder tag];
        NSUInteger nextTag = tag == fieldCount ? fieldCount : tag + 1;
        [self checkBarButton:nextTag];
        
        if ([tfDelegate respondsToSelector:@selector(TFAnimateView:)])
            [tfDelegate TFAnimateView:nextTag];
        
        UIViewController *viewControl = (UIViewController*)tfDelegate;
        
        UITextField *nextField = (UITextField *)[viewControl.view viewWithTag:nextTag];
        if (nextField) [nextField becomeFirstResponder];
    }
}

- (void)doneField:(id)sender{
    if ([tfDelegate respondsToSelector:@selector(TFDonePressed)])
        [tfDelegate TFDonePressed];
}

- (void)checkBarButton:(NSUInteger)tag
{
    
    UIBarButtonItem *previousBarItem = [[self items] objectAtIndex:0];
    UIBarButtonItem *nextBarItem = [[self items] objectAtIndex:1];
    
    [previousBarItem setEnabled:tag == 1 ? NO : YES];
    [nextBarItem setEnabled:tag == fieldCount ? NO : YES];
}

- (id)getFirstResponder
{
    NSUInteger index = 1;
    while (index <= fieldCount) {
        UIViewController *viewControl = (UIViewController*)tfDelegate;
        UITextField *textField = (UITextField *)[viewControl.view viewWithTag:index];
        if ([textField isFirstResponder]) {
            return textField;
        }
        index++;
    }
    return nil;
}


@end
