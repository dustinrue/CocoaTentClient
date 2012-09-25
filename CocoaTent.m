//
//  CocoaTent.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
// References:
//   HTTP Mac
//   http://tools.ietf.org/html/draft-ietf-oauth-v2-http-mac-01#section-3.1

#import "CocoaTent.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFNetworking/AFHTTPClient.h"
#import "JSONKit.h"
#import "HMAC256.h"
#import "NSString+ParseQueryString.h"

@implementation CocoaTent

- (id) init {
    self = [super init];
    
    if (!self)
        return self;
    
    self.tentVersion  = @"0.1.0";
    self.tentServer   = @"http://localhost:3001";
    self.tentMimeType = @"application/vnd.tent.v0+json";
    
    self.appInfo = [[NSMutableDictionary alloc] init];
    [self.appInfo setValue:@"Cocoa Tent Client" forKey:@"name"];
    [self.appInfo setValue:@"Does amazing foos with your data" forKey:@"description"];
    [self.appInfo setValue:@"http://example.com" forKey:@"url"];
    [self.appInfo setValue:@"http://example.com/icon.png" forKey:@"icon"];
    [self.appInfo setValue:[NSArray arrayWithObject:@"cocoatentclient://oauth"] forKey:@"redirect_uris"];
    [self.appInfo setValue:[NSDictionary dictionaryWithObjectsAndKeys:@"Uses an app profile section to describe foos", @"write_profile", @"Calculates foos based on your followings", @"read_followings", nil] forKey:@"scopes"];
    
    return self;
}

- (void) getUserProfile {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.tentServer, @"profile"]];
    NSLog(@"connecting to %@", url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveProfileData" object:nil userInfo:JSON];
        ;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil]; 
        NSLog(@"failure, %@", error);
    }];
    
    [operation start];
}

- (void) discover {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];

    NSURLRequest *request = [client requestWithMethod:@"HEAD" path:@"/" parameters:nil];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got %@", [[response allHeaderFields] valueForKey:@"Link"]);
        [self doRegister];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@", error);
    }];
    
    [operation start];
}

- (void) doRegister {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/apps" parameters:nil];
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[self.appInfo JSONData]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self parseOAuthData:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

- (void) parseOAuthData:(NSDictionary *) data {
    [self.appInfo setValue:[data valueForKey:@"mac_algorithm"] forKey:@"mac_algorithm"];
    [self.appInfo setValue:[data valueForKey:@"mac_key"] forKey:@"mac_key"];
    [self.appInfo setValue:[data valueForKey:@"mac_key_id"] forKey:@"mac_key_id"];
    [self.appInfo setValue:[data valueForKey:@"id"] forKey:@"id"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"appInfoDidChange" object:nil userInfo:self.appInfo];
    
    NSString *params = [NSString stringWithFormat:@"client_id=%@&redirect_uri=cocoatentclient://oauth&scope=read_posts,read_profile&state=87351cc2f6737bfc8ba&tent_profile_info_types=https://tent.io/types/info/music/v0.1.0&tent_post_types=https://tent.io/types/posts/status/v0.1.0,https://tent.io/types/posts/photo/v0.1.0", [self.appInfo valueForKey:@"id"]];
    
    NSString *fullParams = [NSString stringWithFormat:@"%@/%@?%@", self.tentServer, @"oauth/authorize", params];
    NSLog(@"fullParms %@", fullParams);
    NSURL *url = [NSURL URLWithString:fullParams];
    NSLog(@"opening %@", url);
	[[NSWorkspace sharedWorkspace] openURL:url];
}

- (void) OAuthCallbackData:(NSURL *) callBackData
{
    NSDictionary *data = [[callBackData query] explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
    
    self.code = [data valueForKey:@"code"];
    self.state = [data valueForKey:@"state"];
    [self getAccessToken];
}

/**
 * Builds the URL/request to exchange a code for an access token
 */
- (void) getAccessToken
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *ts = [[NSNumber numberWithDouble: timestamp] stringValue];
    
    NSString *nonce = @"random";
    
    NSString *app_id = [self.appInfo valueForKey:@"id"];
    
    NSString *mac = [HMAC256 HMAC256:[self.appInfo valueForKey:@"mac_key"] withKey:[self.appInfo valueForKey:@"mac_key_id"]];

    
    NSString *authorizationHeader = [NSString stringWithFormat:@"MAC id=\"%@\", ts=\"%ld\", nonce=\"%@\", mac=\"%@\"", app_id, [ts integerValue], nonce, mac];
    
    NSLog(@"will be sending %@", authorizationHeader);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:[NSString stringWithFormat:@"apps/%@/authorizations", [self.appInfo valueForKey:@"id"]] parameters:nil];
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    
    NSDictionary *httpBody = [NSDictionary dictionaryWithObjectsAndKeys:[self code], @"code", @"mac", @"token_type", nil];
    [request setHTTPBody:[httpBody JSONData]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"authorization response %@", JSON);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}
@end
