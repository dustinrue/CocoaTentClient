//
//  CocoaTentRepost.m
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

#import "CocoaTentRepost.h"
#import "CocoaTentEntity.h"
#import "CocoaTentCoreProfile.h"

@implementation CocoaTentRepost

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = kCocoaTentRepostType;
    
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (!self)
        return self;
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"entity"])
        self.repostedEntity = [dictionary valueForKeyPath:@"content.entity"];
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"id"])
        self.repostedPostId = [dictionary valueForKeyPath:@"content.id"];
    
    return self;
}

- (id) initWithRepost:(NSDictionary *)post withEntity:(CocoaTentEntity *) entity
{
    self = [super initWithDictionary:post];
 
    
    if (!self)
        return self;
    
    // we do NOT want to post an id but super is going to set it based on
    // on the incoming post, get rid of it here
    
    self.post_id = nil;
    
    self.type = kCocoaTentRepostType;
    
    self.entity = [entity.core valueForKey:@"entity"];
    
    // store the entity and postId so we can put that into the content
    // of this repost
    
    // we have to determine if the post is a repost or not, it is dealt
    // with a bit differently than other post types
    if ([[post valueForKey:@"type"] isEqual:kCocoaTentRepostType])
    {
        self.repostedEntity = [post valueForKeyPath:@"content.entity"];
        self.repostedPostId = [post valueForKeyPath:@"content.id"];
    }
    else
    {
        self.repostedEntity = [post valueForKey:@"entity"];
        self.repostedPostId = [post valueForKey:@"id"];
    }
    
    if ([post objectForKey:@"mentions"])
        self.mentions = [post valueForKey:@"mentions"];
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSMutableDictionary *content = [NSMutableDictionary dictionary];
    
    if (self.repostedEntity)
        [content setValue:self.repostedEntity forKey:@"entity"];
    
    if (self.repostedPostId)
        [content setValue:self.repostedPostId forKey:@"id"];
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}

@end
