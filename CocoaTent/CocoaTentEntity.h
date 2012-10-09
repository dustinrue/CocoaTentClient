//
//  CocoaTentEntity.h
//  TentClient
//
//  Created by Dustin Rue on 10/7/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CocoaTentBasicProfile;
@class CocoaTentCoreProfile;

@interface CocoaTentEntity : NSObject


@property (nonatomic, strong) CocoaTentBasicProfile *basic;
@property (nonatomic, strong) CocoaTentCoreProfile *core;

- (NSMutableDictionary *) dictionary;

@end
