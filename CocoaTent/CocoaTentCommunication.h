//
//  CocoaTentCommunication.h
//  TentClient
//
//  Created by Dustin Rue on 9/28/12.
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

#import "AFHTTPClient.h"

@class AFJSONRequestOperation;

@interface CocoaTentCommunication : AFHTTPClient

@property (strong) NSString *tentVersion;
@property (strong) NSString *tentHostProtocol;
@property (strong) NSString *tentHost;
@property (strong) NSString *tentHostPort;
@property (strong) NSString *tentMimeType;
@property (strong) NSURL *tentHostURL;
@property (strong) NSString *urlScheme;
@property (strong) NSString *mac_key_id;
@property (strong) NSString *mac_key;
@property (strong) NSString *mac_algorithm;
@property (strong) NSString *access_token;

// used during the OAuth2 exchange
@property (strong) NSString *code;
@property (strong) NSString *state;

+ (CocoaTentCommunication *) sharedInstanceWithBaseURL:(NSURL *)baseURL;

- (AFJSONRequestOperation *) newJSONRequestOperationWithMethod:(NSString *)method
                                          pathWithoutLeadingSlash:(NSString *) path
                                                      HTTPBody:(NSDictionary *) httpBody
                                                          sign:(BOOL) isSigned
                                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
