//
//  CocoaTentRepostFetcher.m
//  TentClient
//
//  Created by Dustin Rue on 10/5/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentRepostFetcher.h"
#import "CocoaTent.h"
#import "CocoaTentCommunication.h"
#import "CocoaTentEntity.h"
#import "CocoaTentCoreProfile.h"
#import "AFJSONRequestOperation.h"

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
 fetchRepostDataFor:withID:forPost: is going to create a new CocoaTent object
 and perform a discover on it.  Once CocoaTent reports it is ready it will
 ask CocoaTent to get the post with post_id, if it can it'll update the content 
 property of the post passed in.  It can then be killed.
 */

@implementation CocoaTentRepostFetcher

- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forSender:(id) sender context:(id)context
{
    self.context = context;
    self.sender  = sender;
    self.post_id = post_id;
    
    
    CocoaTentCoreProfile *coreProfile = [[CocoaTentCoreProfile alloc] init];
    
    coreProfile.entity = entity;
    
    self.tentEntity = [[CocoaTentEntity alloc] init];
    
    self.tentEntity.core = coreProfile;

    self.cocoaTent = [[CocoaTent alloc] initWithEntity:self.tentEntity];
    
    [self.cocoaTent setDelegate:self];
    
    [self.cocoaTent discover];
}

- (void) cocoaTentIsReady
{
    // we're now "attached" to the entities server, so we do
    // an unauthorized request to get a specific post id
    [self.cocoaTent getPostWithId:self.post_id];
}

- (void) didReceiveRepostData:(NSDictionary *) userInfo
{

}

- (void) communicationError:(NSError *)error
{

    [self.sender communicationError:error];

}

// implemented just to keep the compiler happy
- (void) didUpdateProfile:(id)sender
{
    
}

- (void) didReceiveNewPost:(id)postData
{
    
    NSMutableDictionary *userInfo = [self.context mutableCopy];
    
    [userInfo setValue:postData forKey:@"postData"];
    
    self.context = userInfo;

    [self.sender didReceiveRepostData:self.context];

}

- (void) didSubmitNewPost
{
    
}

- (void) didReceiveBasicInfo
{

}
@end
