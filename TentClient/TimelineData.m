//
//  TimelineData.m
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "TimelineData.h"

@implementation TimelineData

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.avatar = [[NSImage alloc] init];
    
    return self;
}
@end
