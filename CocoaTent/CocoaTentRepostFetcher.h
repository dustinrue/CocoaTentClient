//
//  CocoaTentRepostFetcher.h
//  TentClient
//
//  Created by Dustin Rue on 10/5/12.
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

/**
 Retrieves the content of a "repost" post by doing a discover
 on the entity URL and getting the post from their server.  It then
 directly updates the content property of the passed in post
 */

#import <Foundation/Foundation.h>
#import "CocoaTent.h"
#import "CocoaTentPostTypes.h"
@class CocoaTentCommunication;


@interface CocoaTentRepostFetcher : NSObject <CocoaTentDelegate>

@property (strong) CocoaTent *cocoaTent;
@property (strong) CocoaTentApp *cocoaTentApp;
@property (strong) CocoaTentCommunication *cocoaTentCommunication;

@property (strong) NSString *post_id;
@property (strong) id post;

- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forPost:(id)post;

@end
