//
//  NSScrollViewScrollKiller.m
//  TentClient
//
//  Created by Dustin Rue on 10/6/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "NSScrollViewScrollKiller.h"

@implementation NSScrollViewScrollKiller

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}



- (void)scrollWheel:(NSEvent *)theEvent {
    void (*responderScroll)(id, SEL, id);
    
    responderScroll = (void (*)(id, SEL, id))([NSResponder
                                               instanceMethodForSelector:@selector(scrollWheel:)]);
    
    responderScroll(self, @selector(scrollWheel:), theEvent);
}


@end
