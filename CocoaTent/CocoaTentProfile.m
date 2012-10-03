//
//  CocoaTentProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentProfile.h"

@implementation CocoaTentProfile

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = @"https://tent.io/types/post/profile/v0.1.0";
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionary];
    
    if (self.type)
        [content setValue:self.type forKey:@"types"];
    
    if (self.action)
        [content setValue:self.action forKey:@"action"];
    
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
