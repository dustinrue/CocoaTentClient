//
//  CocoaTentBasicProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentBasicProfile.h"
#import "CocoaTentEntityPermission.h"

@implementation CocoaTentBasicProfile

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
    return @"https://tent.io/types/info/basic/v0.1.0";
}

- (NSString *) profileType
{
    return [CocoaTentBasicProfile profileType];
}

- (NSMutableDictionary *) dictionary
{
    NSMutableDictionary *dictionaryOfPropertyValues = [NSMutableDictionary dictionary];

    
    if (self.name)
        [dictionaryOfPropertyValues setValue:self.name forKey:@"name"];
    
    if (self.avatar_url)
        [dictionaryOfPropertyValues setValue:self.avatar_url forKey:@"avatar_url"];
    
    if (self.birthdate)
        [dictionaryOfPropertyValues setValue:self.birthdate forKey:@"birthdate"];
    
    if (self.location)
        [dictionaryOfPropertyValues setValue:self.location forKey:@"location"];
    
    if (self.gender)
        [dictionaryOfPropertyValues setValue:self.gender forKey:@"gender"];
    
    if (self.bio)
        [dictionaryOfPropertyValues setValue:self.bio forKey:@"bio"];
    
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
