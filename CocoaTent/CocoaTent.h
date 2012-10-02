//
//  CocoaTent.h
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
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

@class CocoaTent;


@class CocoaTentApp;
@class CocoaTentCommunication;
@class CocoaTentPost;

// use a delegate system to alert the app of changes, would it be
// better to use blocks here?
@protocol CocoaTentDelegate <NSObject>

- (void) didReceiveAppId:(NSString *)app_id;
- (void) didReceiveAccessToken:(NSString *)access_token;

// would be used when streaming to notify the delegate that new data
// has been received
- (void) didReceiveNewPost:(id)postType withPostData:(id)postData;

// would be used to tell the delegate that communication layer
// error has occurred
- (void) communicationError:(NSError *)error;

@end

@interface CocoaTent : NSObject

@property (strong) CocoaTentApp *cocoaTentApp;
@property (strong) CocoaTentCommunication *cocoaTentCommunication;
@property (strong) id <CocoaTentDelegate> delegate;

// You should create and set the properties of a CocoaTentApp object
// and pass it in as you create a CocoaTent object.  
- (id) initWithApp:(CocoaTentApp *) cocoaTentApp;


/*
 *
 */
- (void) registerWithTentServer;


- (void) getUserProfile;
- (void) discover;
- (void) getFollowings;
- (void) followEntity:(NSString *)newEntity;
- (void) pushProfileInfo;

- (void) getPosts;
- (void) newPost:(id)post;

@end
