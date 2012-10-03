//
//  CocoaTentPost.m
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

#import "CocoaTentPost.h"

@implementation CocoaTentPost

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
  
    if (self.post_id)
        [dictionaryOfPropertyValues setValue:self.post_id forKey:@"id"];
    
    if (self.entity)
        [dictionaryOfPropertyValues setValue:self.entity forKey:@"entity"];
    
    if (self.published_at)
        [dictionaryOfPropertyValues setValue:self.published_at forKey:@"published_at"];
    else
        [dictionaryOfPropertyValues setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"published_at"];
    
    if (self.received_at)
        [dictionaryOfPropertyValues setValue:self.received_at forKey:@"received_at"];
    
    if (self.mentions)
        [dictionaryOfPropertyValues setValue:self.mentions forKey:@"mentions"];
    
    if (self.licenses)
        [dictionaryOfPropertyValues setValue:self.licenses forKey:@"licenses"];
    
    if (self.views)
        [dictionaryOfPropertyValues setValue:self.views forKey:@"views"];
    
    if (self.app)
        [dictionaryOfPropertyValues setValue:self.app forKey:@"app"];
    
    if (self.permissions)
        [dictionaryOfPropertyValues setValue:self.permissions forKey:@"permissions"];
    
    if (self.type)
        [dictionaryOfPropertyValues setValue:self.type forKey:@"type"];
    
    return dictionaryOfPropertyValues;
}

@end