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

@required
// would be used when streaming to notify the delegate that new data
// has been received

// TODO: provide the sender
- (void) didReceiveNewPost:(id)postType withPostData:(id)postData;
- (void) didSubmitNewPost;
- (void) didUpdateProfile:(id) sender;

// this lets you know that the communication layer is ready to start
// doing work
- (void) cocoaTentIsReady;

// would be used to tell the delegate that communication layer
// error has occurred
- (void) communicationError:(NSError *)error;


// these are optional, you should either implement these
// OR observe the values
@optional
- (void) didReceiveAppId:(NSString *)app_id;
- (void) didReceiveAccessToken:(NSString *)access_token;
- (void) didReceiveBasicInfo;
- (void) didReceiveCoreInfo;
- (void) didReceiveRepostData:(NSDictionary *) repostData;

@end

@interface CocoaTent : NSObject

@property (strong) CocoaTentApp *cocoaTentApp;
@property (strong) CocoaTentCommunication *cocoaTentCommunication;

// together, the following two properties define the last, unique
// post on a tent system
@property (strong) NSString *lastPostId;
@property (strong) NSString *lastEntityId;

// other properties used to define the last post
@property (strong) NSNumber *lastPostTimeStamp;


@property (strong) id <CocoaTentDelegate> delegate;

// You should create and set the properties of a CocoaTentApp object
// and pass it in as you create a CocoaTent object.  
- (id) initWithApp:(CocoaTentApp *) cocoaTentApp;


/*
 *
 */
- (void) registerWithTentServer;



- (void) discover;
- (void) getFollowings;
- (void) followEntity:(NSString *)newEntity;

#pragma mark -
#pragma mark Mention Finder
- (NSArray *) findMentionsInPostContent:(NSString *)content;

#pragma mark -
#pragma mark User Profile
- (void) getUserProfile;
- (void) pushProfileInfo:(id) profile;

#pragma mark -
#pragma mark Posts
- (void) getPosts;
- (void) getPostWithId:(NSString *)post_id;
- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forPost:(id)post;

// gets the most recent posts since the last time
// or gets all posts if there isn't a "since_id" value
- (void) getRecentPosts;

// manually get posts since a post_id
- (void) getPostsSince:(NSString *)post_id;

- (void) newPost:(id)post;

@end
