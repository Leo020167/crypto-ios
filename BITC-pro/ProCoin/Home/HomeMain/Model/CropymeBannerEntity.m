//
//  CropymeBannerEntity.m
//  Cropyme
//
//  Created by Hay on 2019/5/29.
//  Copyright © 2019 淘金路. All rights reserved.
//

#import "CropymeBannerEntity.h"

//@property (copy, nonatomic) NSString *bannerId;
//@property (copy, nonatomic) NSString *imageUrl;
//@property (copy, nonatomic) NSString *params;
//@property (copy, nonatomic) NSString *pview;
//@property (assign, nonatomic) NSInteger type;
//@property (copy, nonatomic) NSString *videoUrl;

@implementation CropymeBannerEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.bannerId = [self stringParser:@"bannerId" json:json];
        self.imageUrl = [self stringParser:@"imageUrl" json:json];
        self.params = [self stringParser:@"params" json:json];
        self.pview = [self stringParser:@"pview" json:json];
        self.type = [self integerParser:@"type" json:json];
        self.videoUrl = [self stringParser:@"videoUrl" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_bannerId release];
    [_imageUrl release];
    [_params release];
    [_pview release];
    [_videoUrl release];
    [super dealloc];
}
@end
