//
//  TimelineData.h
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TimelineData : NSObject

@property (strong) NSAttributedString *entity;
@property (strong) NSAttributedString *content;
@property (strong) NSString *client;
@property (strong) NSString *post_id;

@property (strong) id fullPost;

@end
