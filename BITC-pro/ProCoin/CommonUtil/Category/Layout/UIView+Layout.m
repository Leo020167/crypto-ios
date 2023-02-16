//
//  UIView+Layout.m
//  TJRtaojinroad
//
//  Created by taojinroad on 22/02/2017.
//  Copyright © 2018 Taojinroad. All rights reserved.
//

#import "UIView+Layout.h"

@implementation UIView (Layout)

-(NSLayoutConstraint *)constraintForIdentifier:(NSString *)identifier {
    
    for (NSLayoutConstraint *constraint in self.constraints) {
        if ([constraint.identifier isEqualToString:identifier]) {
            return constraint;
        }
    }
    return nil;
}

@end
