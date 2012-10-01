//
//  CocoaTentCommunication.h
//  TentClient
//
//  Created by Dustin Rue on 9/28/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AFHTTPClient.h"

@class AFJSONRequestOperation;

@interface CocoaTentCommunication : AFHTTPClient

@property (strong) NSString *tentVersion;
@property (strong) NSString *tentHostProtocol;
@property (strong) NSString *tentHost;
@property (strong) NSString *tentHostPort;
@property (strong) NSString *tentMimeType;
@property (strong) NSString *urlScheme;
@property (strong) NSString *mac_key_id;
@property (strong) NSString *mac_key;
@property (strong) NSString *mac_algorithm;
@property (strong) NSString *access_token;

// used during the OAuth2 exchange
@property (strong) NSString *code;
@property (strong) NSString *state;

+ (CocoaTentCommunication *) sharedInstanceWithBaseURL:(NSURL *)baseURL;

- (AFJSONRequestOperation *) newJSONRequestOperationWithMethod:(NSString *)method
                                          pathWithLeadingSlash:(NSString *) path
                                                      HTTPBody:(NSDictionary *) httpBody
                                                          sign:(BOOL) isSigned
                                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure;

@end
