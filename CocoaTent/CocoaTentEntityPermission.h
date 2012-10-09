//
//  CocoaTentEntityPermission.h
//  TentClient
//
//  Created by Dustin Rue on 10/7/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaTentEntityPermission : NSObject

@property (strong) NSDictionary *entities;
@property (strong) NSArray      *groups;
@property (assign) NSString     *public;

- (id) initWithDictionary:(NSDictionary *) dictionary;
- (NSDictionary *) dictionary;

@end
