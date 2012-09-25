//
//  HMAC256.h
//  TentClient
//
//  Created by Dustin Rue on 9/24/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HMAC256 : NSObject

+ (NSString *)HMAC256:(NSString *)key withKey:(NSString *)data;

@end
