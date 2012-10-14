//
//  CocoaTentStatus.m
//  TentClient
//
//  Created by Dustin Rue on 10/1/12.
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

#import "CocoaTentStatus.h"
#import "CocoaTent.h"
#import "CocoaTentEntity.h"
#import "CocoaTentBasicProfile.h"
#import "CocoaTentCoreProfile.h"


@implementation CocoaTentStatus

- (id) init
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = kCocoaTentStatusType;
    
    return self;
}

- (id) initWithDictionary:(NSDictionary *)dictionary
{
    self = [super initWithDictionary:dictionary];
    
    if (!self)
        return self;
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"text"])
        self.text = [dictionary valueForKeyPath:@"content.text"];
    
    if ([[dictionary objectForKey:@"content"] objectForKey:@"location"])
        self.location = [dictionary valueForKeyPath:@"content.location"];
    
    return self;
}

- (id) initWithReplyTo:(NSDictionary *) post withEntity:(CocoaTentEntity *) entity
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.type = kCocoaTentStatusType;
    
    self.entity = [entity.core valueForKey:@"entity"];
    
    NSDictionary *mentionData = [self buildMentionListForReplyTo:post];
    
    self.mentions = [mentionData valueForKey:@"mentions"];
    self.text     = [mentionData valueForKey:@"replyText"];
    
    return self;
}

- (NSMutableDictionary *)dictionary
{
    NSDictionary *content = [NSDictionary dictionaryWithObjectsAndKeys:
                             self.text, @"text",
                             self.location, @"location", nil];
    
    NSMutableDictionary *dictionaryOfPropertyValues = [super dictionary];
    
    [dictionaryOfPropertyValues setValue:content forKey:@"content"];
    
    return dictionaryOfPropertyValues;
}


- (NSDictionary *) buildMentionListForReplyTo:(id)post
{
    
    NSMutableArray *currentMentionList = [[post valueForKey:@"mentions"] mutableCopy];
    
    // the mention list might contain a reply, we strip that out because you can
    // only reply to a single post, but you can mention many people.
    
    NSMutableArray *mentionListMinusPostStanza = [NSMutableArray arrayWithCapacity:0];
    
    for (NSMutableDictionary *mention in currentMentionList)
    {
        // remove ourselves from the mention list
        if (![[mention valueForKey:@"entity"] isEqualToString:self.entity])
        {
            [mentionListMinusPostStanza addObject:[NSDictionary dictionaryWithObjectsAndKeys:[mention valueForKey:@"entity"], @"entity", nil]];
        }
    }
    
    currentMentionList = mentionListMinusPostStanza;
    
    // now we need to add this post, where "this post" is the post being replied to,
    // to the top of the list so that it matches
    [currentMentionList insertObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                      [post valueForKey:@"entity"], @"entity",
                                      [post valueForKey:@"id"], @"post", nil]
                             atIndex:0];
    

    
    // build the reply text which will consist of all the usernames
    // that were mentioned
    
    NSString *replyToText = @"";
    
    NSEnumerator *reverseEnumeratedMentionList = [currentMentionList reverseObjectEnumerator];
    
    for (NSDictionary *mention in reverseEnumeratedMentionList)
    {
        // build the username for the entity we are mentioning too, not sure
        // what the proper way to do this is, but this seems to be the
        // "normal" format on tent.is
        NSArray *explodedOnPeriod = [[mention valueForKey:@"entity"] componentsSeparatedByString:@"."];
        NSString *username = [[explodedOnPeriod objectAtIndex:0] substringFromIndex:8];
        replyToText = [NSString stringWithFormat:@"^%@ %@", username, replyToText];
        
    }

    return [NSDictionary dictionaryWithObjectsAndKeys:
            currentMentionList, @"mentions",
            replyToText, @"replyText", nil];

}

@end
