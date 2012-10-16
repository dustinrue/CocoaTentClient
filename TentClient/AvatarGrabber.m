//
//  AvatarGrabber.m
//  TentClient
//
//  Created by Dustin Rue on 10/9/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AvatarGrabber.h"
#import "CocoaTent.h"
#import "CocoaTentCoreProfile.h"
#import "CocoaTentEntity.h"
#import "CocoaTentBasicProfile.h"
#import "TimelineData.h"
#import "AFImageRequestOperation.h"

@implementation AvatarGrabber

- (void) getAvatarInBackground:(id) info
{
    NSString *entity = [info valueForKey:@"entity"];
    TimelineData * timelineObject = [info valueForKey:@"timelineObject"];
    [self getAvatarForEntity:entity forTimelineObject:timelineObject];
}

- (void) getAvatarForEntity:(NSString *) entity forTimelineObject:(TimelineData *) timelineObject
{
    
    CocoaTentCoreProfile *coreProfile = [[CocoaTentCoreProfile alloc] init];
    
    coreProfile.entity = entity;
    
    CocoaTentEntity *entityObject = [[CocoaTentEntity alloc] init];
    
    entityObject.core = coreProfile;
    
    
    CocoaTent *ct = [[CocoaTent alloc] initWithEntity:entityObject];
    
    ct.delegate = self;
    
    self.timelineObject = timelineObject;
    
    [ct discover];
}

- (void) cocoaTentIsReady:(id) sender
{
    // we don't care about that cocoa tent is ready because the discover will grab the profile information
    // which is what we're interested in here
}

- (void) didReceiveBasicInfo:(CocoaTentBasicProfile *)cocoaTentBasicProfile
{
    NSMutableURLRequest *avatarRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:cocoaTentBasicProfile.avatar_url]];
    
    AFImageRequestOperation *operation = [AFImageRequestOperation imageRequestOperationWithRequest:avatarRequest imageProcessingBlock:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSImage *image) {
        [self.timelineObject setAvatar:image];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        NSLog(@"failed to get avatar image");
    }];
    // this will cause the whole client to hang if the server doesn't response very quickly

    [operation start];
    
}

- (void) communicationError:(NSError *)error
{
    //[self.post setContent:[NSString stringWithFormat:@"Failed to fetch repost data"]];
}

// implemented just to keep the compiler happy
- (void) didUpdateProfile:(id)sender
{
    
}

- (void) didReceiveNewPost:(id)postData
{
    
}

- (void) didReceiveRepostData:(NSDictionary *)userInfo
{
    
}

- (void) didSubmitNewPost
{
    
}

- (void) didReceiveBasicInfo
{
    
}

@end
