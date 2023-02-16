//
//  MyHomeSelfDescribtionViewController.m
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-11.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "MyHomeSelfDescribtionViewController.h"

@interface MyHomeSelfDescribtionViewController ()

@end

@implementation MyHomeSelfDescribtionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    user = [self getValueFromModelDictionary:MyHomeDict forKey:@"User"];
    _textView.text = user.selfDescription;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [self setIvBgTextField:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [_textView release];
    [_ivBgTextField release];
    [super dealloc];
}
- (IBAction)backgroundClicked:(id)sender {
    [_textView resignFirstResponder];
}

- (IBAction)gobackPressed:(id)sender
{
    [self goBack];
}

- (IBAction)completePressed:(id)sender
{
    if (_textView.text.length == 0) {
        [self showToastCenter:NSLocalizedStringForKey(@"请输入文字!") inView:self.view];
    }else if (_textView.text.length > 140){
        [self showToastCenter:NSLocalizedStringForKey(@"输入太多文字啦!") inView:self.view];
    }else {
        [self putValueToParamDictionary:MyHomeDict value:@"1" forKey:@"isRefresh"];
        user.selfDescription = _textView.text;
        [self goBack];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]){ //判断输入的字是否是回车，即按下return
        //在这里做你响应return键的代码
        if (textView.text.length == 0) {
            
            [self showToastCenter:NSLocalizedStringForKey(@"请输入文字!") inView:self.view];
        }else if (textView.text.length > 140){
            [self showToastCenter:NSLocalizedStringForKey(@"输入太多文字啦!") inView:self.view];
        }else {
            [self putValueToParamDictionary:MyHomeDict value:@"1" forKey:@"isRefresh"];
            user.selfDescription = textView.text;
            [self goBack];
        }
        return NO; //这里返回NO，就代表return键值失效，即页面上按下return，不会出现换行，如果为yes，则输入页面会换行
    }
    
    return YES;
}
@end
