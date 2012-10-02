//
//  CocoaTentStatus.m
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentStatus.h"

@implementation CocoaTentStatus


- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.text, @"text",
                             self.location, @"location", nil];
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
