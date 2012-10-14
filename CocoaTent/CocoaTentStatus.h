//
//  CocoaTentStatus.h
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

#define kCocoaTentStatusType @"https://tent.io/types/post/status/v0.1.0"

@class CocoaTentEntity;

@interface CocoaTentStatus : CocoaTentPost

@property (strong) NSString *text;

// NSArray with lat/lon?
@property (strong) NSArray *location;

- (id) init;
- (id) initWithReplyTo:(NSDictionary *) post withEntity:(CocoaTentEntity *) entity;
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *)dictionary;


// builds the proper mention stanza for when reposting a post.  You can
// simply assign the value returned to the "mentions" property of your
// repost object.
- (NSDictionary *) buildMentionListForRepostOf:(id) post;

@end
