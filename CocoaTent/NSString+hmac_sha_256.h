//
//  NSString+hmac_sha_256.h
//  TentClient
//
//  Created by Dustin Rue on 9/25/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (hmac_sha_256)

- (NSString *) hmac_sha_256:(NSString *) key;

@end
