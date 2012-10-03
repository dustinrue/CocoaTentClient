//
//  CocoaTentRepost.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@interface CocoaTentRepost : CocoaTentPost
/*
   https://tent.io/types/post/repost/v0.1.0
 
   A repost is a post that points to a post created by another entity.
 
 entity     Required	String	The entity that is being reposted.
 id         Required	String	The post identifier that is being reposted.
 */

@property (strong) NSString *entity;
@property (strong) NSString *post_id;

@end
