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

/*
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CocoaTent.h"
#import "CocoaTentApp.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "JSONKit.h"
#import "NSData+hmac_sha_256.h"
#import "NSString+hmac_sha_256.h"
#import "NSString+ParseQueryString.h"
#import "NSString+Random.h"

@implementation CocoaTent

- (id) initWithApp:(CocoaTentApp *) cocoaTentApp {
    self = [super init];
    
    if (!self)
        return self;
    
    self.tentVersion  = @"0.1.0";
    self.tentServer   = @"http://localhost:3001";
    self.tentMimeType = @"application/vnd.tent.v0+json";
    
    self.cocoaTentApp = cocoaTentApp;
    
    [self.cocoaTentApp addObserver:self forKeyPath:@"name"          options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"description"   options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"url"           options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"icon"          options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"redirect_uris" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"scopes"        options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"app_id"        options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_agorithm"  options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key"       options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key_id"    options:NSKeyValueObservingOptionNew context:nil];
    
    [self registerForURLScheme];
    
    return self;
}

- (void)registerForURLScheme
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]]; // Now you can parse the URL and perform whatever action is needed
    
    [self OAuthCallbackData:url];
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


/*
 * STEP 1: Tell tentd that we exist and it'll respond with:
 *   an id for our app (id)
 *   the id for our key (mac_key_id)
 *   the shared key (mac_key)
 *   the algorithm used (mac_algorithm)
 */
- (void) doRegister {
    
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/apps" parameters:nil];
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[[self.cocoaTentApp dictionary] JSONData]];

    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self parseOAuthData:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

/*
 * Take the data from doRegister and store it then perform auth request (STEP 2)
 */
- (void) parseOAuthData:(NSDictionary *) data {
    [self.cocoaTentApp setMac_algorithm:[data valueForKey:@"mac_algorithm"]];
    [self.cocoaTentApp setMac_key:[data valueForKey:@"mac_key"]];
    [self.cocoaTentApp setMac_key_id:[data valueForKey:@"mac_key_id"]];
    [self.cocoaTentApp setApp_id:[data valueForKey:@"id"]];
    
    
    NSString *params = [NSString stringWithFormat:@"client_id=%@&redirect_uri=cocoatentclient://oauth&scope=read_posts,read_profile&state=87351cc2f6737bfc8ba&tent_profile_info_types=https://tent.io/types/info/music/v0.1.0&tent_post_types=https://tent.io/types/posts/status/v0.1.0,https://tent.io/types/posts/photo/v0.1.0", [self.cocoaTentApp app_id]];
    
    NSString *fullParams = [NSString stringWithFormat:@"%@/%@?%@", self.tentServer, @"oauth/authorize", params];
    
    NSURL *url = [NSURL URLWithString:fullParams];
    
	[[NSWorkspace sharedWorkspace] openURL:url];
}

/*
 * Store the code and state (we're supposed to set the state value and verify it here..but we don't yet)
 */
- (void) OAuthCallbackData:(NSURL *) callBackData
{
    NSDictionary *data = [[callBackData query] explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
    
    self.code = [data valueForKey:@"code"];
    self.state = [data valueForKey:@"state"];
    [self getAccessToken];
}

/**
 * STEP 3: get our permanent access token using the code we just got
 * Builds the URL/request to exchange a code for an access token
 */
- (void) getAccessToken
{
    
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *ts = [[NSNumber numberWithDouble: timestamp] stringValue];
    
    NSString *nonce = [NSString randomizedString];
    
    NSDictionary *httpBody = [NSDictionary dictionaryWithObjectsAndKeys:[self code], @"code", @"mac", @"token_type", nil];
    
    NSString *mac = [[httpBody JSONData] hmac_sha_256:[self.cocoaTentApp mac_key]];

    
    NSString *authorizationHeader = [NSString stringWithFormat:@"MAC id=\"%@\", ts=\"%ld\", nonce=\"%@\", mac=\"%@\"", [self.cocoaTentApp mac_key_id], [ts integerValue], nonce, mac];
    
    NSLog(@"will be sending %@", authorizationHeader);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:[NSString stringWithFormat:@"apps/%@/authorizations", [self.cocoaTentApp app_id]] parameters:nil];
    
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    
    
    [request setHTTPBody:[httpBody JSONData]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self parseAccessToken:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

- (void) parseAccessToken:(id) JSON
{
    [self.cocoaTentApp setAccess_token:[JSON valueForKey:@"access_token"]];
}

- (void) getFollowings
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSString *ts = [[NSNumber numberWithDouble: timestamp] stringValue];
    
    NSString *nonce = [NSString randomizedString];
    
    NSDictionary *httpBody = [NSDictionary dictionaryWithObjectsAndKeys:[self code], @"code", @"mac", @"token_type", nil];
    
    NSString *mac = [[httpBody JSONData] hmac_sha_256:[self.cocoaTentApp mac_key]];
    
    
    NSString *authorizationHeader = [NSString stringWithFormat:@"MAC id=\"%@\", ts=\"%ld\", nonce=\"%@\", mac=\"%@\"", [self.cocoaTentApp mac_key_id], [ts integerValue], nonce, mac];
    
    NSLog(@"will be sending %@", authorizationHeader);
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@", self.tentServer]];
    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:[NSString stringWithFormat:@"followings"] parameters:nil];
    
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    
    [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    
    
    [request setHTTPBody:[httpBody JSONData]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got followings %@", JSON);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"got updated data for %@, key: %@; value: %@", [object class], keyPath, change);
}
@end
