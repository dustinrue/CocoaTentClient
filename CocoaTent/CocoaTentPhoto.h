//
//  CocoaTentPhoto.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

/*
 *   Photo is the post type for sharing pictures. The file itself is attached to the post. Applications can add EXIF data, tags, and a caption to describe the issue, plus a list of albums that include the photo.
 */
@interface CocoaTentPhoto : CocoaTentPost

/*
 caption	Optional	String	A caption that describes the photo.
 albums     Optional	Array	A list of the Post IDs of albums that this photo belongs to.
 tags       Optional	Array	A list of tags that describe this photo.
 exif       Optional	Object	The EXIF data that describes the photo.
 */

@property (strong) NSString *caption;
@property (strong) NSArray  *albums;
@property (strong) NSArray  *tags;
@property (strong) NSDictionary *exif;

@end
