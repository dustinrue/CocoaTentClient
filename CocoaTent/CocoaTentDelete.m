//
//  CocoaTentDelete.m
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentDelete.h"

@implementation CocoaTentDelete

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = @"https://tent.io/types/post/delete/v0.1.0";
    
    return self;
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
    if (self.entity)
        [dictionaryOfPropertyValues setValue:self.entity forKey:@"entity"];

    
    return dictionaryOfPropertyValues;
}

@end
