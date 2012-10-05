//
//  CocoaTentBasicProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentBasicProfile.h"

@implementation CocoaTentBasicProfile

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
    
    return dictionaryOfPropertyValues;
}

@end
