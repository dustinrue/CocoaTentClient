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


@interface CocoaTent (Private)

- (void) saveResponseDataAndRedirectToAuthorizationURL:(id) data;
- (void) saveAuthorizationCodeFromAuthorizationURL:(NSURL *) callBackData;
- (void) getPermanentAccessToken;
- (void) savePermanentAccessToken:(id) JSON;

@end


@implementation CocoaTent

- (id) initWithApp:(CocoaTentApp *) cocoaTentApp {
    self = [super init];
    
    if (!self)
        return self;
    
    self.tentVersion  = @"0.1.0";
    self.tentHost     = @"http://localhost";
    self.tentHostPort = @"3000";
    self.tentMimeType = @"application/vnd.tent.v0+json";
    self.urlScheme    = @"cocoatentclient";
    
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
    [self.cocoaTentApp addObserver:self forKeyPath:@"access_token"  options:NSKeyValueObservingOptionNew context:nil];
    
    [self registerForURLScheme];
    
    return self;
}

- (void)registerForURLScheme
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]]; // Now you can parse the URL and perform whatever action is needed
    
    [self saveAuthorizationCodeFromAuthorizationURL:url];
}


#pragma mark -
#pragma mark communications
- (AFJSONRequestOperation *) newJSONRequestOperationWithMethod:(NSString *)method
                                          pathWithLeadingSlash:(NSString *) path
                                                      HTTPBody:(NSDictionary *) httpBody
                                                          sign:(BOOL) isSigned
                                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@:%@", self.tentHost, self.tentHostPort]];

    
    AFHTTPClient *client = [AFHTTPClient clientWithBaseURL:url];
    
    NSMutableURLRequest *request = [client requestWithMethod:method path:path parameters:nil];
    
    NSSet *acceptableContentType = [NSSet setWithObject:self.tentMimeType];
    [AFJSONRequestOperation addAcceptableContentTypes:acceptableContentType];
    
    if (isSigned)
    {
        /*
         *
         * must create a normalized request string
         *
         *   The string is constructed by concatenating together, in order, the
         *   following HTTP request elements, each followed by a new line
         *   character (%x0A):
         *
         *   1.  The timestamp value calculated for the request.
         *   2.  The nonce value generated for the request.
         *   3.  The HTTP request method in upper case.  For example: "HEAD",
         *       "GET", "POST", etc.
         *   4.  The HTTP request-URI as defined by [RFC2616] section 5.1.2.
         *   5.  The hostname included in the HTTP request using the "Host"
         *       request header field in lower case.
         *   6.  The port as included in the HTTP request using the "Host" request
         *       header field.  If the header field does not include a port, the
         *       default value for the scheme MUST be used (e.g. 80 for HTTP and
         *       443 for HTTPS).
         *   7.  The value of the "ext" "Authorization" request header field
         *       attribute if one was included in the request, otherwise, an empty
         *       string.
         *
         */
        
        NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
        NSString *ts = [[NSNumber numberWithDouble: timestamp] stringValue];
        
        NSString *nonce = [NSString randomizedString];
        
        
        
        NSString *normalizedRequestString = [NSString stringWithFormat:@"%ld\n%@\n%@\n%@\n%@\n%@",
                                             [ts integerValue],
                                             nonce,
                                             method,
                                             path,
                                             self.tentHost,
                                             self.tentHostPort];
        
        // NSLog(@"signing %@", normalizedRequestString);
        
        
        NSString *mac = [normalizedRequestString hmac_sha_256:[self.cocoaTentApp mac_key]];
        
        // if access_token is set then set id to that, if not, then use the mac_key_id
        NSString *authorizationHeader = nil;
        if ([self.cocoaTentApp access_token])
        {
            authorizationHeader = [NSString stringWithFormat:@"MAC id='%@', ts='%ld', nonce='%@', mac='%@'", [self.cocoaTentApp access_token], [ts integerValue], nonce, mac];
        }
        else if ([self.cocoaTentApp mac_key_id])
        {
            authorizationHeader = [NSString stringWithFormat:@"MAC id='%@', ts='%ld', nonce='%@', mac='%@'", [self.cocoaTentApp mac_key_id], [ts integerValue], nonce, mac];
        }
        else
        {
            // neither is set, but we're being asked to sign, not possible
            return nil;
        }
        
        
        //NSLog(@"will be sending %@", authorizationHeader);
        [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    }
    
    if (httpBody)
    {
        [request setHTTPBody:[httpBody JSONData]];
    }
    
    if ([method isEqualToString:@"POST"])
    {
        [request setValue:self.tentMimeType forHTTPHeaderField:@"content-type"];
    }
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        success(request, response, JSON);
        ;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failure(request, response, error, JSON);
    }];
    
    return operation;
}




#pragma mark -
#pragma mark OAuth2 registration steps
/*
 * STEP 1: Tell tentd that we exist and it'll respond with:
 *   an id for our app (id)
 *   the id for our key (mac_key_id)
 *   the shared key (mac_key)
 *   the algorithm used (mac_algorithm)
 */
- (void) registerWithTentServer {
    
    AFJSONRequestOperation *operation = [self newJSONRequestOperationWithMethod:@"POST" pathWithLeadingSlash:@"/apps" HTTPBody:[self.cocoaTentApp dictionary] sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self saveResponseDataAndRedirectToAuthorizationURL:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

/*
 * STEP 2
 * Take the data from doRegister and store it then perform auth request
 */
- (void) saveResponseDataAndRedirectToAuthorizationURL:(NSDictionary *) data {
    [self.cocoaTentApp setMac_algorithm:[data valueForKey:@"mac_algorithm"]];
    [self.cocoaTentApp setMac_key:[data valueForKey:@"mac_key"]];
    [self.cocoaTentApp setMac_key_id:[data valueForKey:@"mac_key_id"]];
    [self.cocoaTentApp setApp_id:[data valueForKey:@"id"]];
    
    
    NSString *params = [NSString stringWithFormat:@"client_id=%@&redirect_uri=cocoatentclient://oauth&scope=read_posts,read_profile&state=87351cc2f6737bfc8ba&tent_profile_info_types=https://tent.io/types/info/music/v0.1.0&tent_post_types=https://tent.io/types/posts/status/v0.1.0,https://tent.io/types/posts/photo/v0.1.0", [self.cocoaTentApp app_id]];
    
    NSString *fullParams = [NSString stringWithFormat:@"%@:%@/%@?%@", self.tentHost, self.tentHostPort, @"oauth/authorize", params];
    
    NSURL *url = [NSURL URLWithString:fullParams];
    
	[[NSWorkspace sharedWorkspace] openURL:url];
}

/*
 * Store the code and state (we're supposed to set the state value and verify it here..but we don't yet)
 */
- (void) saveAuthorizationCodeFromAuthorizationURL:(NSURL *) callBackData
{
    NSDictionary *data = [[callBackData query] explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
    
    self.code = [data valueForKey:@"code"];
    self.state = [data valueForKey:@"state"];
    [self getPermanentAccessToken];
}

/**
 * STEP 3: get our permanent access token using the code we just got
 * Builds the URL/request to exchange a code for an access token
 */
- (void) getPermanentAccessToken
{
    
    NSDictionary *httpBody = [NSDictionary dictionaryWithObjectsAndKeys:[self code], @"code", @"mac", @"token_type", nil];
    
    AFJSONRequestOperation *operation = [self newJSONRequestOperationWithMethod:@"POST" pathWithLeadingSlash:[NSString stringWithFormat:@"/apps/%@/authorizations", [self.cocoaTentApp app_id]] HTTPBody:httpBody sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self savePermanentAccessToken:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}

- (void) savePermanentAccessToken:(id) JSON
{
    [self.cocoaTentApp setAccess_token:[JSON valueForKey:@"access_token"]];
}

#pragma mark -
#pragma mark other things
- (void) getUserProfile {
    AFJSONRequestOperation *operation = [self newJSONRequestOperationWithMethod:@"GET" pathWithLeadingSlash:@"/profile" HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveProfileData" object:nil userInfo:JSON];
        ;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@", error);
    }];
    
    [operation start];
}

- (void) discover {
    
    AFJSONRequestOperation *operation = [self newJSONRequestOperationWithMethod:@"HEAD" pathWithLeadingSlash:@"/" HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got %@", [[response allHeaderFields] valueForKey:@"Link"]);
        [self registerWithTentServer];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@", error);
    }];
    
    [operation start];
}


- (void) getFollowings
{
    
    AFJSONRequestOperation *operation = [self newJSONRequestOperationWithMethod:@"GET" pathWithLeadingSlash:@"/followings" HTTPBody:nil sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
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
