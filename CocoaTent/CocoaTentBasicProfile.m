//
//  CocoaTentBasicProfile.m
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

/*
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

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
