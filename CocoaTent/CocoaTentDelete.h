//
//  CocoaTentDelete.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@interface CocoaTentDelete : CocoaTentPost
/*
 Delete
 
 https://tent.io/types/post/delete/v0.1.0
 
 Delete informs followers that a post was deleted.
 
 id     Required	String	The identifier of the post that was deleted.
 */

@property (strong) NSString *post_id;

@end
