//
//  TimelineItem.m
//  TentClient
//
//  Created by Dustin Rue on 10/6/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "TimelineItem.h"

@interface TimelineItem ()

@end

@implementation TimelineItem

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void) scrollWheel:(NSEvent *)theEvent
{
    NSLog(@"hi");
    [super scrollWheel:theEvent];
}

@end
