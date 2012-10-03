//
//  CocoaTentPhoto.m
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPhoto.h"

@implementation CocoaTentPhoto

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = @"https://tent.io/types/post/photo/v0.1.0";
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionary];
    
    if (self.caption)
        [content setValue:self.caption forKey:@"caption"];
    
    if (self.albums)
        [content setValue:self.albums forKey:@"albums"];
    
    if (self.tags)
        [content setValue:self.tags forKey:@"tags"];
    
    if (self.exif)
        [content setValue:self.exif forKey:@"exif"];
    
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
