//
//  VerticalLabel.h
//  TJRtaojinroad
//
//  Created by taojinroad on 2016/12/21.
//  Copyright © 2018年 Taojinroad. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM (NSInteger ,VerticalAlignment){
    
    VerticalAlignmentTop = 0,//上居中
    
    VerticalAlignmentMiddle, //中居中
    
    VerticalAlignmentBottom //低居中
    
};

@interface VerticalLabel : UILabel {
@private
    
    VerticalAlignment _verticalAlignment;
}
@property (nonatomic,assign)VerticalAlignment verticalAlignment;
@end
