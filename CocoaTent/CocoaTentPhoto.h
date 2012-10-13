//
//  CocoaTentPhoto.h
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

#define kCocoaTentPhotoType @"https://tent.io/types/post/photo/v0.1.0"

/*
 *   Photo is the post type for sharing pictures. The file itself is attached to the post. Applications can add EXIF data, tags, and a caption to describe the issue, plus a list of albums that include the photo.
 */
@interface CocoaTentPhoto : CocoaTentPost

/*
 caption	Optional	String	A caption that describes the photo.
 albums     Optional	Array	A list of the Post IDs of albums that this photo belongs to.
 tags       Optional	Array	A list of tags that describe this photo.
 exif       Optional	Object	The EXIF data that describes the photo.
 */

@property (strong) NSString *caption;
@property (strong) NSArray  *albums;
@property (strong) NSArray  *tags;
@property (strong) NSDictionary *exif;

- (id) init;
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *) dictionary;

@end
