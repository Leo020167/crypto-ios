//
//  TTGlobalCore.h
//  BProject
//
//  Created by taojinroad on 14-6-16.
//  Copyright (c) 2014年 UnWood. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Creates a mutable array which does not retain references to the objects it contains.
 *
 * Typically used with arrays of delegates.
 */
NSMutableArray* TTCreateNonRetainingArray(void);

/**
 * Creates a mutable dictionary which does not retain references to the values it contains.
 *
 * Typically used with dictionaries of delegates.
 */
NSMutableDictionary* TTCreateNonRetainingDictionary(void);

/**
 * Tests if an object is an array which is not empty.
 */
BOOL TTIsArrayWithItems(id object);

/**
 * Tests if an object is a set which is not empty.
 */
BOOL TTIsSetWithItems(id object);

/**
 * Tests if an object is a string which is not empty.
 */
BOOL TTIsStringWithAnyText(id object);

/**
 * Swap the two method implementations on the given class.
 * Uses method_exchangeImplementations to accomplish this.
 */
void TTSwapMethods(Class cls, SEL originalSel, SEL newSel);

