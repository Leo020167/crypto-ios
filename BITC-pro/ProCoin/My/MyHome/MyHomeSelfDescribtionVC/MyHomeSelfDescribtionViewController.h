//
//  MyHomeSelfDescribtionViewController.h
//  TJRtaojinroad
//
//  Created by Jeans Huang on 12-9-11.
//  Copyright (c) 2018年 Taojinroad. All rights reserved.
//

#import "TJRBaseViewController.h"

@interface MyHomeSelfDescribtionViewController : TJRBaseViewController{
    TJRUser *user;
}
@property (retain, nonatomic) IBOutlet UITextView *textView;
@property (retain, nonatomic) IBOutlet UIImageView *ivBgTextField;

@end
