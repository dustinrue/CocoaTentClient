//
//  CocoaTentBasicProfile.h
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCocoaTentBasicProfile @"https://tent.io/types/info/basic/v0.1.0"

@interface CocoaTentBasicProfile : NSObject

@property (strong) NSString *name;
@property (strong) NSString *avatar_url;
@property (strong) NSString *birthdate;
@property (strong) NSString *location;
@property (strong) NSString *gender;
@property (strong) NSString *bio;
@property (strong) NSArray  *permissions;

- (id) initWithDictionary:(NSDictionary *) dictionary;
+ (NSString *) profileType;
- (NSString *) profileType;
- (NSMutableDictionary *) dictionary;

@end
