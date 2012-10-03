//
//  CocoaTentEssay.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@interface CocoaTentEssay : CocoaTentPost

/*
 title      Optional	String	The title of the post.
 excerpt	Optional	String	An excerpt of the post in HTML format to be displayed when the whole post is not available.
 body       Required	String	The body of the post in HTML format. Renderers may sanitize some HTML.
 tags       Optional	Array	Tags that describe the post.
 */
@property (strong) NSString *title;
@property (strong) NSString *excerpt;
@property (strong) NSString *body;
@property (strong) NSArray  *tags;

@end
