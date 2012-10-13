//
//  CocoaTentPost.h
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

#import <Foundation/Foundation.h>

@class CocoaTentPermission;

@interface CocoaTentPost : NSObject

/*
 id             Optional	String	The unique identifier of the post.
 entity         Required	String	The entity that published the post.
 published_at	Required	Integer	The date/time when the post was published in Unix time.
 received_at	Optional	Integer	The date/time when the post was received from the publishing server in Unix time.
 mentions       Optional	Array	The entities and posts that this post mentions.
 licenses       Required	Array	The licenses that the post is released under.
 type           Required	String	The post type URL.
 content        Required	Object	The post content.
 attachments    Optional	Array	Attachments to the post.
 app            Optional	Object	The application that published the post.
 views          Optional	Object	The available views of the post.
 permissions	Optional	Object	The permissions that apply to the instance.
 */

// required attributes

// entity uri
@property (strong) NSString *entity;

// timestamp
@property (strong) NSNumber *published_at;

// array of string values detailing the license to be applied to the post
@property (strong) NSArray *licenses;

// what post type
@property (strong) NSString *type;


// optional
@property (strong) NSString *post_id;
@property (strong) NSNumber *received_at;
@property (strong) NSArray *mentions;
@property (strong) NSArray *attachments;

// it is not necessary for a client to set this, the server will override it anyway
@property (strong) NSDictionary *app;
@property (strong) NSString *views;
@property (strong) CocoaTentPermission *permissions;

- (NSMutableDictionary *)dictionary;

@end
