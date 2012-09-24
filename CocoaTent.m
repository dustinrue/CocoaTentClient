//
//  CocoaTent.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTent.h"
#import "AFNetworking/AFJSONRequestOperation.h"
#import "AFNetworking/AFHTTPClient.h"
#import "JSONKit.h"

@implementation CocoaTent

- (id) init {
    self = [super init];
    
    if (!self)
        return self;
    
    self.tentVersion  = @"0.1.0";
    self.tentServer   = @"http://localhost:3000";
    self.tentMimeType = @"application/vnd.tent.v0+json";
    
    return self;
}

- (void) getUserProfile {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", self.tentServer, @"profile"]];
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

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"Cocoa Tent Client" forKey:@"name"];
    [parameters setValue:@"Does amazing foos with your data" forKey:@"description"];
    [parameters setValue:@"http://example.com" forKey:@"url"];
    [parameters setValue:@"http://example.com/icon.png" forKey:@"icon"];
    [parameters setValue:[NSArray arrayWithObject:@"https://app.example.com/tent/callback"] forKey:@"redirect_uris"];
    [parameters setValue:[NSDictionary dictionaryWithObjectsAndKeys:@"Uses an app profile section to describe foos", @"write_profile", @"Calculates foos based on your followings", @"read_followings", nil] forKey:@"scopes"];
    
    //NSLog(@"paramets %@", [parameters JSONString]);
    
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:@"/apps" parameters:nil];
    [request setValue:@"application/vnd.tent.v0+json" forHTTPHeaderField:@"content-type"];
    [request setHTTPBody:[parameters JSONData]];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got %@", JSON);
        ;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
    }];
    
    [operation start];
}
@end
