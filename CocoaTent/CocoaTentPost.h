//
//  CocoaTentPost.h
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CocoaTentPost : NSObject

/*
 id             Optional	String	The unique identifier of the post.
 entity         Required	String	The entity that published the post.
 published_at	Required	Integer	The date/time when the post was published in Unix time.
 received_at	Optional	Integer	The date/time when the post was received from the publishing server in Unix time.
 mentions       Optional	Array	The entities and posts that this post mentions.
 licenses       Required	Array	The licenses that the post is released under.
 type           Required	String	The post type URL.
 content        Required	Object	The post content.
 attachments    Optional	Array	Attachments to the post.
 app            Optional	Object	The application that published the post.
 views          Optional	Object	The available views of the post.
 permissions	Optional	Object	The permissions that apply to the instance.
 */
@property (strong) NSString *post_id;
@property (strong) NSString *entity;
@property (strong) NSNumber *published_at;
@property (strong) NSNumber *received_at;
@property (strong) NSArray *mentions;
@property (strong) NSArray *licenses;
@property (strong) NSString *type;
@property (strong) NSString *content;
@property (strong) NSArray *attachments;
@property (strong) NSDictionary *app;
@property (strong) NSString *views;
@property (strong) NSDictionary *permissions;


- (NSMutableDictionary *)dictionary;

@end
