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

// used during the OAuth2 exchange
@property (strong) NSString *code;
@property (strong) NSString *state;

// this should really be class
@property (strong) NSMutableDictionary *appInfo;

- (void) getUserProfile;
- (void) discover;
- (void) doRegister;
- (void) parseOAuthData:(id) data;
- (void) OAuthCallbackData:(NSURL *) callBackData;
- (void) getAccessToken;

@end
