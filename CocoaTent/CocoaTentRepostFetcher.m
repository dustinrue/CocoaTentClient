//
//  CocoaTentRepostFetcher.m
//  TentClient
//
//  Created by Dustin Rue on 10/5/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentRepostFetcher.h"
#import "CocoaTent.h"
#import "CocoaTentCommunication.h"
#import "CocoaTentApp.h"
#import "AFJSONRequestOperation.h"

@implementation CocoaTentRepostFetcher

- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forPost:(id)post
{
    
    self.post = post;
    self.post_id = post_id;
    
    self.cocoaTentApp = [[CocoaTentApp alloc] init];
    
    self.cocoaTentApp.tentEntity = entity;
    
    self.cocoaTent = [[CocoaTent alloc] initWithApp:self.cocoaTentApp];
    
    [self.cocoaTent setDelegate:self];
    
    [self.cocoaTent discover];
}

- (void) cocoaTentIsReady
{
    [self.cocoaTent getPostWithId:self.post_id];
}

- (void) didReceiveRepostData:(NSDictionary *)repostData
{
    // update the already in place view with the repost data
    [self.post setContent:[repostData valueForKeyPath:@"content.text"]];
}

- (void) communicationError:(NSError *)error
{
    
}
@end
