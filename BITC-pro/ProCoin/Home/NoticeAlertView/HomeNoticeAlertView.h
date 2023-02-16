//
//  HomeNoticeAlertView.h
//  TJRtaojinroad
//
//  Created by taojinroad on 8/3/16.
//  Copyright © 2016 Taojinroad. All rights reserved.
//

#import "TJRBaseView.h"

@interface HomeNoticeAlertView : TJRBaseView{
    
}

- (void)show:(UIView*)superView title:(NSString*)title content:(NSString*)content updateTime:(NSString*)updateTime;
@end
