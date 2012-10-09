//
//  CocoaTentCoreProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentCoreProfile.h"
#import "CocoaTentEntityPermission.h"

@implementation CocoaTentCoreProfile

- (id) initWithDictionary:(NSDictionary *) dictionary
{
    self = [super init];
    
    if (!self)
        return self;
    
    NSArray *allKeys = [dictionary allKeys];
    
    for (NSString *key in allKeys)
    {
        // permissions property is an array of Cocoa Tent Permissions
        if ([key isEqualToString:@"permissions"])
        {
            NSMutableArray *permArray = [NSMutableArray arrayWithCapacity:0];
            for (NSString *permKey in [dictionary valueForKey:key])
                [permArray addObject:[[CocoaTentEntityPermission alloc] initWithDictionary:[dictionary valueForKey:key]]];
            
            [self setValue:permArray forKey:key];
        }
        else
            [self setValue:[dictionary valueForKey:key] forKey:key];
    }
    
    return self;
}

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
    
    if (self.permissions)
    {
        NSMutableArray *perms = [NSMutableArray arrayWithCapacity:0];
        for (CocoaTentEntityPermission *perm in self.permissions)
        {
            [perms addObject:[perm dictionary]];
        }
        
        [dictionaryOfPropertyValues setValue:perms forKey:@"permissions"];
    }
    
    return dictionaryOfPropertyValues;
}

@end
