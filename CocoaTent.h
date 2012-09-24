//
//  CocoaTent.h
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaTent : NSObject

@property (strong) NSString *tentVersion;
@property (strong) NSString *tentServer;
@property (strong) NSString *tentMimeType;

// this should really be class
@property (strong) NSMutableDictionary *appInfo;

- (void) getUserProfile;
- (void) discover;
- (void) doRegister;
- (void) parseOAuthData:(id) data;
- (void) authenticate;

@end
