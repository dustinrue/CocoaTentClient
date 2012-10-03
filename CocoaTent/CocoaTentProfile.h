//
//  CocoaTentProfile.h
//  TentClient
//
//  Created by Dustin Rue on 10/2/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "CocoaTentPost.h"

#define kCocoaTentProfileActionCreate @"create"
#define kCocoaTentProfileActionUpdate @"update"
#define kCocoaTentProfileActionDelete @"delete"


@interface CocoaTentProfile : CocoaTentPost
/*
 https://tent.io/types/post/profile/v0.1.0
 
 A profile post notifies followers about modifications to an entity's profile.
 
 types      Required	Array	The types of profile info that have been modified.
 action     Required	String	The action that was performed on the profile info. One of create, update, or delete.
 */

@property (strong) NSArray *types;
@property (strong) NSString *action;

@end
