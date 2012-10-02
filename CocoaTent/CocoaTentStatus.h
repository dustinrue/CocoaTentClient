//
//  CocoaTentStatus.h
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@interface CocoaTentStatus : CocoaTentPost

@property (strong) NSString *text;

// NSArray with lat/lon?
@property (strong) NSArray *location;

- (NSMutableDictionary *)dictionary;

@end
