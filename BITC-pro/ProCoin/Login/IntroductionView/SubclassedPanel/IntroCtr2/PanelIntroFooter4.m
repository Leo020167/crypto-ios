//
//  PanelIntroFooter4.m
//  TJRtaojinroad
//
//  Created by taojinroad on 9/25/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "PanelIntroFooter4.h"
#import "TJRBaseViewController.h"

@interface PanelIntroFooter4 ()

@end

@implementation PanelIntroFooter4


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}


#pragma mark - Interaction Methods
//Override them if you want them!

-(void)panelDidAppear{

}

-(void)panelDidDisappear{
    
}

- (IBAction)buttonClicked:(id)sender {
    
    if (_delegate && [_delegate respondsToSelector:@selector(panelIntroLogin)]) {
        [_delegate panelIntroLogin];
    }

}
- (void)dealloc {

    [_inButton release];
    [super dealloc];
}
@end
