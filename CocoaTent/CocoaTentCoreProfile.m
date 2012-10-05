//
//  CocoaTentCoreProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentCoreProfile.h"

@implementation CocoaTentCoreProfile

+ (NSString *) profileType
{
    return @"https://tent.io/types/info/core/v0.1.0";
}

- (NSString *) profileType
{
    return @"https://tent.io/types/info/core/v0.1.0";
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
    if (self.entity)
        [dictionaryOfPropertyValues setValue:self.entity forKey:@"entity"];
    
    if (self.licenses)
        [dictionaryOfPropertyValues setValue:self.licenses forKey:@"licenses"];
    
    if (self.servers)
        [dictionaryOfPropertyValues setValue:self.servers forKey:@"servers"];
    
    return dictionaryOfPropertyValues;
}

@end
