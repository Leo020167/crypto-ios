//
//  EditableController.m
//  TJRtaojinroad
//
//  Created by road taojin on 12-9-24.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "EditableController.h"
#import "iToast.h"

@interface EditableController ()

@end

@implementation EditableController
@synthesize countHintLbl;
@synthesize growingTextView;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    growingTextView.placeHolder = @"输入内容...";
    growingTextView.textCountLabel = countHintLbl;
    growingTextView.maxTextLimitCount=60;

}

-(void)viewWillDisappear:(BOOL)animated
{
    [growingTextView resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setGrowingTextView:nil];
    [self setCountHintLbl:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (IBAction)leftButtonClicked:(id)sender
{
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rightButtonClicked:(id)sender
{
    if (growingTextView.text==nil||growingTextView.text.length==0||[growingTextView.placeHolder isEqualToString:growingTextView.text]) {
        [[[[iToast makeText:@"请输入内容"] setGravity:iToastGravityCenter] setDuration:1500] show:self.view];
        return;
    }
    if ([growingTextView count]>60||[growingTextView.placeHolder isEqualToString:growingTextView.text]) {
        [[[[iToast makeText:@"输入内容超出60个字符数"] setGravity:iToastGravityCenter] setDuration:1500] show:self.view];
        return;
    }
    if ([delegate respondsToSelector:@selector(editableControllerSetText:)]) {
        [delegate editableControllerSetText:growingTextView.text];
    }
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dealloc {
    [growingTextView release];
    [countHintLbl release];
    [super dealloc];
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView
{
    [self rightButtonClicked:nil];
}
@end
