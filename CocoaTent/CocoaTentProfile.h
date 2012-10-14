//
//  CocoaTentProfile.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

/*
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "CocoaTentPost.h"

#define kCocoaTentProfileActionCreate @"create"
#define kCocoaTentProfileActionUpdate @"update"
#define kCocoaTentProfileActionDelete @"delete"

#define kCocoaTentProfileType @"https://tent.io/types/post/profile/v0.1.0"


@interface CocoaTentProfile : CocoaTentPost
/*
 https://tent.io/types/post/profile/v0.1.0
 
 A profile post notifies followers about modifications to an entity's profile.
 
 types      Required	Array	The types of profile info that have been modified.
 action     Required	String	The action that was performed on the profile info. One of create, update, or delete.
 */

@property (strong) NSArray *types;
@property (strong) NSString *action;

- (id) init;
- (id) initWithDictionary:(NSDictionary *)dictionary;
- (NSMutableDictionary *) dictionary;

// builds the proper mention stanza for a post reply.  Depending on the post type the
// returned dictionary will contain up to two keys.  'mentions' will be the mentions
// data you need to set the "mentions" property of your new post.  'replyText' will
// be provided on appropriate post types and will contain the list of entities
// mentioned so you can include it in your reponse text (visible to the user)
- (NSDictionary *) buildMentionListForReplyTo:(id) post;

// builds the proper mention stanza for when reposting a post.  You can
// simply assign the value returned to the "mentions" property of your
// repost object.
- (NSDictionary *) buildMentionListForRepostOf:(id) post;

@end
