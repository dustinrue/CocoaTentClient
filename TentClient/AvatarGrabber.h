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

- (void) getAvatarForEntity:(NSString *) entity forTimelineObject:(TimelineData *) timelineObject;

@end
