//
//  CocoaTentAlbum.m
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentAlbum.h"

@implementation CocoaTentAlbum

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = @"https://tent.io/types/post/album/v0.1.0";
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionary];
    
    if (self.title)
        [content setValue:self.title forKey:@"title"];
    
    if (self.description)
        [content setValue:self.description forKey:@"description"];
    
    if (self.photos)
        [content setValue:self.photos forKey:@"photos"];
    
    if (self.cover)
        [content setValue:self.cover forKey:@"cover"];
    
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
