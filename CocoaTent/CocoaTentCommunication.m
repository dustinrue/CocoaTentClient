//
//  CocoaTentCommunication.m
//  TentClient
//
//  Created by Dustin Rue on 9/28/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentCommunication.h"
#import "AFJSONRequestOperation.h"
#import "NSString+Base64.h"
#import "NSString+hmac_sha_256.h"
#import "NSString+ParseQueryString.h"
#import "NSString+Random.h"
#import "NSData+hmac_sha_256.h"
#import "JSONKit.h"
#import "CocoaTentApp.h"

@implementation CocoaTentCommunication

+ (CocoaTentCommunication *) sharedInstanceWithBaseURL:(NSURL *)baseURL;
{
    static CocoaTentCommunication *sharedInstance;
    
    @synchronized(self)
    {
        if (!sharedInstance)
        {
            sharedInstance = [[CocoaTentCommunication alloc] initWithBaseURL:baseURL];
        }
    }
    
    return sharedInstance;
}

- (id) initWithBaseURL:(NSURL *)url {
    NSLog(@"starting with %@", url);
    self = [super initWithBaseURL:url];
    
    if (!self)
        return self;
    
    
    self.tentHost         = [url host];
    self.tentHostPort     = [[url port] stringValue];
    self.tentHostProtocol = [url scheme];
    self.tentVersion      = @"0.1.0";
    self.tentMimeType     = @"application/vnd.tent.v0+json";
    self.urlScheme        = @"cocoatentclient";
    
    
    return self;
}

#pragma mark -
#pragma mark communications
- (AFJSONRequestOperation *) newJSONRequestOperationWithMethod:(NSString *) method
                                          pathWithLeadingSlash:(NSString *) path
                                                      HTTPBody:(NSDictionary *) httpBody
                                                          sign:(BOOL) isSigned
                                                       success:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, id JSON))success
                                                       failure:(void (^)(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON))failure
{
    
    NSMutableURLRequest *request = [self requestWithMethod:method path:path parameters:nil];
    
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
        
        
        // the double newline is not a mistake
        NSString *normalizedRequestString = [NSString stringWithFormat:@"%ld\n%@\n%@\n%@\n%@\n%@\n\n",
                                             [ts integerValue],
                                             nonce,
                                             method,
                                             path,
                                             self.tentHost,
                                             self.tentHostPort];
        
        NSLog(@"signing %@", normalizedRequestString);
        // can't sign anything if we don't have a key
        if (!self.mac_key)
        {
            // TODO: properly bail out of here
            NSLog(@"no key, need to register app first");
            return nil;
        }
        
        
        NSString *mac = [normalizedRequestString hmac_sha_256:self.mac_key];
        
        // if access_token is set then set id to that, if not, then use the mac_key_id
        NSString *authorizationHeader = nil;
        if (self.access_token)
        {
            authorizationHeader = [NSString stringWithFormat:@"MAC id=\"%@\", ts=\"%ld\", nonce=\"%@\", mac=\"%@\"", self.access_token, [ts integerValue], nonce, mac];
        }
        else if (self.mac_key_id)
        {
            authorizationHeader = [NSString stringWithFormat:@"MAC id=\"%@\", ts=\"%ld\", nonce=\"%@\", mac=\"%@\"", self.mac_key_id, [ts integerValue], nonce, mac];
        }
        else
        {
            // neither is set, but we're being asked to sign, not possible
            // TODO: properly bail out of here
            NSLog(@"no key id, register first");
            return nil;
        }
        
        
        //NSLog(@"will be sending %@", authorizationHeader);
        [request setValue:authorizationHeader forHTTPHeaderField:@"Authorization"];
    }
    
    if (httpBody)
    {
        [request setHTTPBody:[httpBody JSONData]];
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

@end
