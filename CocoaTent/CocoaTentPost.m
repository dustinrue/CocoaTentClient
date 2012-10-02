//
//  CocoaTentPost.m
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@implementation CocoaTentPost

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
  
    if (self.post_id)
        [dictionaryOfPropertyValues setValue:self.post_id forKey:@"id"];
    
    if (self.entity)
        [dictionaryOfPropertyValues setValue:self.entity forKey:@"entity"];
    
    if (self.published_at)
        [dictionaryOfPropertyValues setValue:self.published_at forKey:@"published_at"];
    else
        [dictionaryOfPropertyValues setValue:[NSNumber numberWithDouble:[[NSDate date] timeIntervalSince1970]] forKey:@"published_at"];
    
    if (self.received_at)
        [dictionaryOfPropertyValues setValue:self.received_at forKey:@"received_at"];
    
    if (self.mentions)
        [dictionaryOfPropertyValues setValue:self.mentions forKey:@"mentions"];
    
    if (self.licenses)
        [dictionaryOfPropertyValues setValue:self.licenses forKey:@"licenses"];
    
    if (self.views)
        [dictionaryOfPropertyValues setValue:self.views forKey:@"views"];
    
    if (self.app)
        [dictionaryOfPropertyValues setValue:self.app forKey:@"app"];
    
    if (self.permissions)
        [dictionaryOfPropertyValues setValue:self.permissions forKey:@"permissions"];
    
    if (self.type)
        [dictionaryOfPropertyValues setValue:self.type forKey:@"type"];
    
    return dictionaryOfPropertyValues;
}

@end
