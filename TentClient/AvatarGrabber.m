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
    // update the already in place view with the repost data
    //NSLog(@"avatar url is %@", cocoaTentBasicProfile.avatar_url);
    [self.timelineObject setAvatar:[[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:cocoaTentBasicProfile.avatar_url]]];
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
