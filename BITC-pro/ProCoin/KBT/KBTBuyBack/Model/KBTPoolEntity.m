//
//  KBTPoolEntity.m
//  Cropyme
//
//  Created by Hay on 2019/8/15.
//  Copyright © 2019 Toka. All rights reserved.
//

#import "KBTPoolEntity.h"

@implementation KBTPoolEntity

- (id)initWithJson:(NSDictionary *)json
{
    self = [super initWithJson:json];
    if(self){
        self.destroyAmount = [self stringParser:@"destroyAmount" json:json];
        self.produceAmount = [self stringParser:@"produceAmount" json:json];
        self.repoPrice = [self stringParser:@"repoPrice" json:json];
        self.repoPriceCny = [self stringParser:@"repoPriceCny" json:json];
    }
    return self;
}

- (void)dealloc
{
    [_destroyAmount release];
    [_produceAmount release];
    [_repoPrice release];
    [_repoPriceCny release];
    [super dealloc];
}
@end
