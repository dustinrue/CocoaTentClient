//
//  AvatarGrabber.h
//  TentClient
//
//  Created by Dustin Rue on 10/9/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaTent.h"

@class TimelineData;

@interface AvatarGrabber : NSObject <CocoaTentDelegate>

@property (strong) CocoaTent *cocoaTent;
@property (strong) CocoaTentEntity *tentEntity;
@property (strong) id timelineObject;

- (void) getAvatarInBackground:(id) info;
- (void) getAvatarForEntity:(NSString *) entity forTimelineObject:(TimelineData *) timelineObject;
- (void) getAvatarAtURL:(NSString *) avatarURL forTimelineObject:(TimelineData *) timelineObject;

@end
