//
//  CocoaTentRepost.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
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

#define kCocoaTentRepostType @"https://tent.io/types/post/repost/v0.1.0"

@class CocoaTentEntity;

@interface CocoaTentRepost : CocoaTentPost
/*
   https://tent.io/types/post/repost/v0.1.0
 
   A repost is a post that points to a post created by another entity.
 
 entity     Required	String	The entity that is being reposted.
 id         Required	String	The post identifier that is being reposted.
 */

@property (strong) NSString *repostedEntity;
@property (strong) NSString *repostedPostId;

- (id) init;
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (id) initWithRepost:(NSDictionary *)post withEntity:(CocoaTentEntity *) entity;
- (NSMutableDictionary *) dictionary;

@end
