//
//  PanelIntroFooter3.h
//  TJRtaojinroad
//
//  Created by taojinroad on 9/25/15.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MYIntroductionPanel.h"

@protocol PanelIntroDelegate <NSObject>

@optional
- (void)panelIntroLogin;
@end

@interface PanelIntroFooter4 : MYIntroductionPanel {
}

@property (retain, nonatomic) IBOutlet UIButton *inButton;

@property (assign, nonatomic) id<PanelIntroDelegate> delegate;
@end
