//
//  CocoaTentRepostFetcher.h
//  TentClient
//
//  Created by Dustin Rue on 10/5/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CocoaTent.h"

@class CocoaTentCommunication;

@interface CocoaTentRepostFetcher : NSObject <CocoaTentDelegate>

@property (strong) CocoaTent *cocoaTent;
@property (strong) CocoaTentApp *cocoaTentApp;
@property (strong) CocoaTentCommunication *cocoaTentCommunication;

@property (strong) NSString *post_id;
@property (strong) id post;

- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forPost:(id)post;

@end
