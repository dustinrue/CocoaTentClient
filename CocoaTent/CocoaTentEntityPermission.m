//
//  CocoaTentEntityPermission.m
//  TentClient
//
//  Created by Dustin Rue on 10/7/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentEntityPermission.h"

@implementation CocoaTentEntityPermission

- (id) initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    
    if (!self)
        return self;
    
    for (NSString *key in [dictionary allKeys])
    {
        [self setValue:[dictionary valueForKey:key] forKey:key];
    }
    return self;
}

- (NSDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];
    
    if (self.entities)
        [dictionaryOfPropertyValues setValue:self.entities forKey:@"entities"];
    
    if (self.groups)
        [dictionaryOfPropertyValues setValue:self.groups forKey:@"groups"];
    
    if (self.public)
        [dictionaryOfPropertyValues setValue:self.public forKey:@"public"];

    return dictionaryOfPropertyValues;
}
@end
