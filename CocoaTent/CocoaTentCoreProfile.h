//
//  CocoaTentCoreProfile.h
//  TentClient
//
//  Created by Dustin Rue on 10/4/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaTentCoreProfile : NSObject

@property (strong) NSString *entity;
@property (strong) NSArray  *licenses;
@property (strong) NSArray  *servers;

+ (NSString *) profileType;
- (NSString *) profileType;
- (NSMutableDictionary *) dictionary;

@end
