//
//  CocoaTentStatus.m
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
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

#import "CocoaTentStatus.h"

@implementation CocoaTentStatus

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = kCocoaTentStatusType;
    
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (!self)
        return self;
    
    /*
     @property (strong) NSString *text;
     
     // NSArray with lat/lon?
     @property (strong) NSArray *location;
     */
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"text"])
        self.text = [dictionary valueForKeyPath:@"content.text"];
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"location"])
        self.location = [dictionary valueForKeyPath:@"content.location"];
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.text, @"text",
                             self.location, @"location", nil];
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
