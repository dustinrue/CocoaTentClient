//
//  CocoaTentEssay.m
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentEssay.h"

@implementation CocoaTentEssay

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = @"https://tent.io/types/post/essay/v0.1.0";
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionary];
    
    if (self.title)
        [content setValue:self.title forKey:@"title"];
    
    if (self.excerpt)
        [content setValue:self.excerpt forKey:@"excert"];
    
    if (self.body)
        [content setValue:self.body forKey:@"body"];
    
    if (self.tags)
        [content setValue:self.tags forKey:@"tags"];
                             
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
