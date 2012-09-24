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
@property (strong) NSString *mac_algorithm;
@property (strong) NSString *mac_key;
@property (strong) NSString *mac_key_id;
@property (strong) NSString *app_id;

- (void) getUserProfile;
- (void) discover;
- (void) doRegister;

@end
