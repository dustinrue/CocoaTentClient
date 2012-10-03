//
//  CocoaTentAlbum.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

@interface CocoaTentAlbum : CocoaTentPost

/*
  https://tent.io/types/post/album/v0.1.0

  An album is a collection of photos. Albums may optionally list a cover photo, description, and title.


title       Optional	String	The title of the album.
description	Optional	String	The description of the album.
photos      Required	Array	The list of Post IDs of photos that the album contains.
cover       Optional	String	The Post ID of a photo that should be used as the cover/display image for the album.
 */

@property (strong) NSString *title;
@property (strong) NSString *description;
@property (strong) NSArray  *photos;
@property (strong) NSString *cover;

@end
