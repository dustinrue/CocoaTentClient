//
//  CocoaTentEntity.m
//  TentClient
//
//  Created by Dustin Rue on 10/7/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentEntity.h"
#import "CocoaTentBasicProfile.h"
#import "CocoaTentCoreProfile.h"

@implementation CocoaTentEntity

- (NSMutableDictionary *) dictionary
{

    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
    // Basic
    @try {
        [dictionaryOfPropertyValues setValue:[self.basic dictionary] forKey:kCocoaTentBasicProfile];
    }
    @catch (NSException *exception) {
        // most likely thrown because if the JSON returned contains a property we don't
        // define which would violate the current version of the spec (0.1.0)
        @throw exception;
    }
    
    // Core
    @try {
        [dictionaryOfPropertyValues setValue:[self.core dictionary] forKey:kCocoaTentCoreProfile];
    }
    @catch (NSException *exception) {
        // most likely thrown because if the JSON returned contains a property we don't
        // define which would violate the current version of the spec (0.1.0)
        @throw exception;
    }

    return dictionaryOfPropertyValues;
}

@end
