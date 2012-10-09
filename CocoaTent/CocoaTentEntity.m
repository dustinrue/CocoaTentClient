//
//  CocoaTentEntity.m
//  TentClient
//
//  Created by Dustin Rue on 10/7/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

/*
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
