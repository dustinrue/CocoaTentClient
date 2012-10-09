//
//  CocoaTentCoreProfile.h
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kCocoaTentCoreProfile @"https://tent.io/types/info/core/v0.1.0"

@interface CocoaTentCoreProfile : NSObject

@property (strong) NSString *entity;
@property (strong) NSArray  *licenses;
@property (strong) NSArray  *servers;
@property (strong) NSArray  *permissions;

- (id) initWithDictionary:(NSDictionary *) dictionary;
+ (NSString *) profileType;
- (NSString *) profileType;
- (NSMutableDictionary *) dictionary;

@end
