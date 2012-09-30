//
//  CocoaTentApp.h
//  TentClient
//
//  Created by Dustin Rue on 9/25/12.
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
#import "CocoaTentCommunication.h"

@interface CocoaTentApp : NSObject

@property (strong) NSString *name;
@property (strong) NSString *description;
@property (strong) NSString *url;
@property (strong) NSString *icon;
@property (strong) NSString *app_id;
@property (strong) NSArray  *redirect_uris;
@property (strong) NSDictionary *scopes;
@property (strong) NSDictionary *tent_post_types;
@property (strong) NSDictionary *tent_profile_info_types;

@property (strong) NSString *tentHostURL;

@property (strong) NSString *mac_key_id;
@property (strong) NSString *mac_key;
@property (strong) NSString *access_token;

- (NSDictionary *)dictionary;

@end
