//
//  CocoaTent.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//
// References:
//   HTTP Mac
//   http://tools.ietf.org/html/draft-ietf-oauth-v2-http-mac-01#section-3.1

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

#import "CocoaTent.h"
#import "CocoaTentApp.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "JSONKit.h"
#import "NSData+hmac_sha_256.h"
#import "NSString+hmac_sha_256.h"
#import "NSString+ParseQueryString.h"
#import "NSString+Random.h"
#import "CocoaTentPost.h"
#import "NSString+URLEncoding.h"

#import "CocoaTentProfile.h"
#import "CocoaTentEntity.h"
#import "CocoaTentBasicProfile.h"
#import "CocoaTentCoreProfile.h"
#import "CocoaTentRepostFetcher.h"
#import "CocoaTentPostTypes.h"


@interface CocoaTent (Private)

- (void) saveResponseDataAndRedirectToAuthorizationURL:(id) data;
- (void) saveAuthorizationCodeFromAuthorizationURL:(NSURL *) callBackData;
- (void) getPermanentAccessToken;
- (void) savePermanentAccessToken:(id) JSON;
- (NSString *) parseAPIRootURL:(NSString *)apiRootURL;
- (void) getEntityURL:(NSString *) profileURL;
- (void) createCocoaTentCommunicationObjectWithBaseURL:(NSURL *) url;
- (void) removeObserversAndStopReachabilityStatusUpdatesForCocoaTentCommunication;
- (void) switchToTentEntityServerAddress:(NSURL *)server;

@end


@implementation CocoaTent

- (id) initWithApp:(CocoaTentApp *) cocoaTentApp
{
    self = [super init];
    
    if (!self)
        return self;
    
    
    self.cocoaTentApp = cocoaTentApp;
    
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
    [self registerForURLScheme];
#endif

    return self;
}

- (id) initWithEntity:(CocoaTentEntity *) entity
{
    self = [super init];
    
    if (!self)
        return self;
    
    self.entity = entity;
    
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
    [self registerForURLScheme];

#endif
    
    return self;
}

- (void) createCocoaTentCommunicationObjectWithBaseURL:(NSURL *) url
{
    self.cocoaTentCommunication = [[CocoaTentCommunication alloc] initWithBaseURL:url];
    
    // configure the communication layer with this apps key info
    [self.cocoaTentCommunication setMac_key:self.cocoaTentApp.mac_key];
    [self.cocoaTentCommunication setMac_key_id:self.cocoaTentApp.mac_key_id];
    [self.cocoaTentCommunication setAccess_token:self.cocoaTentApp.access_token];
    
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
    __weak CocoaTent *reachabilityDelegate = self;
    [self.cocoaTentCommunication setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        [reachabilityDelegate reachabilityStatusHasChanged:(AFNetworkReachabilityStatus) status];
    }];
#endif
    
    // if they change, we need to be notified
    [self.cocoaTentCommunication addObserver:self forKeyPath:@"mac_key"       options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentCommunication addObserver:self forKeyPath:@"mac_key_id"    options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentCommunication addObserver:self forKeyPath:@"access_token"  options:NSKeyValueObservingOptionNew context:nil];
}



- (void) removeObserversAndStopReachabilityStatusUpdatesForCocoaTentCommunication
{
    [self.cocoaTentCommunication removeObserver:self forKeyPath:@"mac_key"];
    [self.cocoaTentCommunication removeObserver:self forKeyPath:@"mac_key_id"];
    [self.cocoaTentCommunication removeObserver:self forKeyPath:@"access_token"];
}

- (void) switchToTentEntityServerAddress:(NSURL *)server
{
    [self removeObserversAndStopReachabilityStatusUpdatesForCocoaTentCommunication];
    [self createCocoaTentCommunicationObjectWithBaseURL:server];
    
    [self.delegate cocoaTentIsReady:self];
}


#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)registerForURLScheme
{

    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}
#endif

#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]];
    
    // blindly assume that we've received an authorization code
    [self saveAuthorizationCodeFromAuthorizationURL:url];
}
#endif


#pragma mark -
#pragma mark Discover
/**
 After initWithEntity, run this to discover the proper server address
 */
- (void) discover {
    
    // on app startup, we use the user's Tent Entity URL and then discover
    // there their API root is, we'll switch to that later
    NSDictionary *coreProfile = [self.entity.core dictionary];
    NSURL *tentEntityUrl = [NSURL URLWithString:[coreProfile valueForKeyPath:@"entity"]];
    
    [self createCocoaTentCommunicationObjectWithBaseURL:tentEntityUrl];
    

    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"HEAD" pathWithoutLeadingSlash:@"" HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self getEntityURL:[self parseAPIRootURL:[[response allHeaderFields] valueForKey:@"Link"]]];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

- (NSString *) parseAPIRootURL:(NSString *)apiRootURL
{
    NSArray *exploded = [apiRootURL componentsSeparatedByString:@";"];
    
    NSString *theBetterHalf = [exploded objectAtIndex:0];
    
    NSString *thePartIWant = [theBetterHalf substringWithRange:NSMakeRange(1, [theBetterHalf length] - 2)];
    
    return thePartIWant;
}

- (void) getEntityURL:(NSString *) profileURL
{
    // profileURL is going to be a full URL and we're about to pass it in as the path,
    // AFJSONRequestOperation would appear to deal with this by magic and build the request
    // appropriately so this *will* build a proper request.
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:profileURL HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSDictionary *basicDictionary = [JSON valueForKey:kCocoaTentBasicProfile];
        NSDictionary *coreDictionary  = [JSON valueForKey:kCocoaTentCoreProfile];

        CocoaTentBasicProfile *basicProfile;
        CocoaTentCoreProfile  *coreProfile;
        @try {
            basicProfile = [[CocoaTentBasicProfile alloc] initWithDictionary:basicDictionary];
            coreProfile  = [[CocoaTentCoreProfile alloc] initWithDictionary:coreDictionary];
        }
        @catch (NSException *exception) {
            NSLog(@"failed to get profile info for the entity, most likely because the tent server is not compliant with version 0.1.0");
            @throw exception;
        }

        
        // TODO: remove the hardcoded bits here
        self.entity.basic = basicProfile;
        self.entity.core = coreProfile;
    
        if ([self.delegate respondsToSelector:@selector(didReceiveBasicInfo:)])
            [self.delegate didReceiveBasicInfo:basicProfile];
        
        if ([self.delegate respondsToSelector:@selector(didReceiveCoreInfo:)])
            [self.delegate didReceiveCoreInfo:coreProfile];
        
        // TODO: deal with multiple servers
        [self switchToTentEntityServerAddress:[NSURL URLWithString:[[self.entity.core valueForKey:@"servers"] objectAtIndex:0]]];
             
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //NSLog(@"failed to get something, \nrequest:\n%@\nreponse\n%@\nJSON\n%@ on URL: %@", [request allHTTPHeaderFields], [response allHeaderFields], JSON, [request URL]);
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}


#pragma mark -
#pragma mark OAuth2 registration steps
/*
 * STEP 1: Tell tentd that we exist and it'll respond with:
 *   an id for our app (id)
 *   the id for our key (mac_key_id)
 *   the shared key (mac_key)
 *   the algorithm used (mac_algorithm)
 */
- (void) registerWithTentServer {
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"POST" pathWithoutLeadingSlash:@"apps" HTTPBody:[self.cocoaTentApp dictionary] sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self saveResponseDataAndRedirectToAuthorizationURL:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        //NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

/*
 * STEP 2
 * Take the data from doRegister and store it then perform auth request
 */
- (void) saveResponseDataAndRedirectToAuthorizationURL:(NSDictionary *) data {
    [self.cocoaTentCommunication setMac_algorithm:[data valueForKey:@"mac_algorithm"]];
    [self.cocoaTentCommunication setMac_key:[data valueForKey:@"mac_key"]];
    [self.cocoaTentCommunication setMac_key_id:[data valueForKey:@"mac_key_id"]];
    [self.cocoaTentApp setApp_id:[data valueForKey:@"id"]];
    
    [self.cocoaTentCommunication setState:[NSString randomizedString]];
    
    NSString *params = [NSString stringWithFormat:@"client_id=%@&tent_profile_info_types=%@&tent_post_types=%@&redirect_uri=cocoatentclient://oauth&state=%@&scope=%@",
                        [self.cocoaTentApp app_id],
                        [[self.cocoaTentApp.tent_profile_info_types allKeys] componentsJoinedByString:@","],
                        [[self.cocoaTentApp.tent_post_types allKeys] componentsJoinedByString:@","],
                        self.cocoaTentCommunication.state,
                        [[self.cocoaTentApp.scopes allKeys] componentsJoinedByString:@","]];
    
    NSString *fullParams = [NSString stringWithFormat:@"%@/%@?%@", [[self.entity.core valueForKey:@"servers"] objectAtIndex:0], @"oauth/authorize", params];
    
    NSURL *url = [NSURL URLWithString:fullParams];
    
    NSLog(@"opening URL %@", url);
    
#ifndef __IPHONE_OS_VERSION_MIN_REQUIRED
	[[NSWorkspace sharedWorkspace] openURL:url];
#endif
}


/*
 * Store the code and state
 */
- (void) saveAuthorizationCodeFromAuthorizationURL:(NSURL *) callBackData
{
    NSDictionary *data = [[callBackData query] explodeToDictionaryInnerGlue:@"=" outterGlue:@"&"];
    
    self.cocoaTentCommunication.code = [data valueForKey:@"code"];
    if ([self.cocoaTentCommunication.state isEqualToString:[data valueForKey:@"state"]])
        [self getPermanentAccessToken];
    
    // we just don't do anything if the state values aren't the same
}

/**
 * STEP 3: get our permanent access token using the code we just got
 * Builds the URL/request to exchange a code for an access token
 */
- (void) getPermanentAccessToken
{
    
    NSDictionary *httpBody = [NSDictionary dictionaryWithObjectsAndKeys:self.cocoaTentCommunication.code, @"code", @"mac", @"token_type", nil];
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"POST" pathWithoutLeadingSlash:[NSString stringWithFormat:@"apps/%@/authorizations", [self.cocoaTentApp app_id]] HTTPBody:httpBody sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self savePermanentAccessToken:JSON];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        //NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

- (void) savePermanentAccessToken:(id) JSON
{
    [self.cocoaTentCommunication setAccess_token:[JSON valueForKey:@"access_token"]];
    [self.cocoaTentCommunication setMac_key:[JSON valueForKey:@"mac_key"]];
}

#pragma mark -
#pragma mark User Profile
- (void) getUserProfile {
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:@"profile" HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"didReceiveProfileData" object:nil userInfo:JSON];
        if ([self.delegate respondsToSelector:@selector(didReceiveBasicInfo:)])
        {
            [self.delegate didReceiveBasicInfo:[[CocoaTentBasicProfile alloc] initWithDictionary:[JSON valueForKey:kCocoaTentBasicProfile]]];
        }
        ;
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        //NSLog(@"failure, %@", error);
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}


- (void) pushProfileInfo:(id) profile
{
 
    // we might receive a full tent entity object which consists of
    // a Basic Profile and Core Profile.  We'll build as many requests as
    // required here
    
    NSArray *allKeys = [[profile dictionary] allKeys];
    
    for (NSString *key in allKeys)
    {
        NSLog(@"pushing profile for key %@\n%@", key, [profile valueForKey:key]);
    }
    /*
    NSString *type = [[[profile dictionary] allKeys] objectAtIndex:0];
    
    if (![type isEqualToString:kCocoaTentBasicProfile] && ![type isEqualToString:kCocoaTentCoreProfile])
    {
        NSLog(@"You need to send me a basic or core profile object");
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", @"profile", type];
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"PUT" pathWithoutLeadingSlash:path HTTPBody:[profile dictionary] sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self.delegate didUpdateProfile:self];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self.delegate communicationError:error];
    }];
    
    [operation start];
     */
}

#pragma mark -
#pragma mark Followings
- (void) getFollowings
{
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:@"followings" HTTPBody:nil sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got followings %@", JSON);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveDataFailure" object:nil];
        //NSLog(@"failure, %@ \n\nwith request %@", error, [request allHTTPHeaderFields]);
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}



- (void) followEntity:(NSString *)newEntity
{
    NSMutableDictionary *followingInfo = [NSMutableDictionary dictionaryWithCapacity:0];
    
    [followingInfo setValue:newEntity forKey:@"entity"];
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"POST" pathWithoutLeadingSlash:@"followings" HTTPBody:followingInfo sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"worked %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failed \nrequest: %@\n%@\n\nresponse: %@\n\nJSON: %@\n\n error: %@", [request allHTTPHeaderFields], [request HTTPBody], [response allHeaderFields], JSON, error);
    }];
    
    [operation start];
}

#pragma mark -
#pragma mark Mention Finder
/**
 Find all ^mentions in a given string and return it as an array
 */
- (NSArray *) findMentionsInPostContent:(NSString *)content
{
    return [CocoaTent findMentionsInPostContent:content];
}

+ (NSArray *) findMentionsInPostContent:(NSString *)content
{
    NSMutableArray *explodedOnTent = [[content componentsSeparatedByString:@"^"] mutableCopy];
    
    NSMutableArray *mentionList = [NSMutableArray arrayWithCapacity:0];
    
    if ([explodedOnTent count] == 0)
        return nil;
    
    // remove the first item, we never want it.  It'll either be blank or
    // simply the content itself because there won't be a ^ in it to
    // explode on
    [explodedOnTent removeObjectAtIndex:0];
    for (NSString *line in explodedOnTent)
    {
        if ([line isEqualToString:@""])
        {
            continue;
        }
        
        [mentionList addObject:[NSDictionary dictionaryWithObjectsAndKeys:[[line componentsSeparatedByString:@" "] objectAtIndex:0], @"entity", nil]];
    }
    
    return mentionList;
}

#pragma mark -
#pragma mark Posts

- (void) getPosts
{
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:@"posts" HTTPBody:nil sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"finished getting posts, sending to %@", self.delegate);
        [self.delegate didReceiveNewPost:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

- (void) getPostWithId:(NSString *)post_id
{
    NSString *path = [NSString stringWithFormat:@"posts/%@", post_id];
    
//    NSLog(@"going to %@ %@", self.cocoaTentApp.tentEntity, path);
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:path HTTPBody:nil sign:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self.delegate didReceiveNewPost:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

- (void) getPostsSince:(NSString *)post_id
{
    NSString *path = [NSString stringWithFormat:@"posts?since_id=%@", post_id];
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:path HTTPBody:nil sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        if ([JSON count] > 0)
        {
            NSLog(@"finished getting posts, sending to %@", self.delegate);
            self.lastPostId = [[JSON objectAtIndex:0] valueForKey:@"id"];
            [self.delegate didReceiveNewPost:JSON];
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //NSLog(@"failed to get posts");
        [self.delegate communicationError:error];
    }];
    
    [operation start];
}

- (void) getRecentPosts
{
    NSString *path = [NSString stringWithFormat:@"posts?since_id=%@&since_id_entity=%@", self.lastPostId, [self.lastEntityId urlEncoded]];
    
    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"GET" pathWithoutLeadingSlash:path HTTPBody:nil sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        if ([JSON count] > 0)
        {
            self.lastPostId = [[JSON objectAtIndex:0] valueForKey:@"id"];
            self.lastEntityId = [[JSON objectAtIndex:0] valueForKey:@"entity"];
            self.lastPostTimeStamp = [[JSON objectAtIndex:0] valueForKey:@"published_at"];
            
        }

        [self.delegate didReceiveNewPost:JSON];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        //NSLog(@"failed to get posts");
        [self.delegate communicationError:error];
    }];

    [operation start];
}

// not entirely sure this is necessary, maybe CocoaTent should just pass
// back the raw JSON and if the client wants to convert it to an object
// they can?
- (id) buildObjectForPost:(id)post
{
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentAlbumType])
        return [[CocoaTentAlbum alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentDeleteType])
        return [[CocoaTentDelete alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentEssayType])
        return [[CocoaTentEssay alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentPhotoType])
        return [[CocoaTentPhoto alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentProfileType])
        return [[CocoaTentProfile alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentRepostType])
        return [[CocoaTentRepost alloc] initWithDictionary:post];
    
    if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentStatusType])
        return [[CocoaTentStatus alloc] initWithDictionary:post];
    
    return post;
}

- (void) clearLastPostCounters
{
    self.lastEntityId = nil;
    self.lastPostId = nil;
    self.lastPostTimeStamp = nil;
}

- (void) newPost:(id)post
{

    AFJSONRequestOperation *operation = [self.cocoaTentCommunication newJSONRequestOperationWithMethod:@"POST" pathWithoutLeadingSlash:@"posts" HTTPBody:[post dictionary] sign:YES success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        [self.delegate didSubmitNewPost];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"failed with\n%@\n%@\n%@", [request allHTTPHeaderFields], [response allHeaderFields], JSON);
    }];
    
    [operation start];
}

- (void) fetchRepostDataFor:(NSString *)entity withID:(NSString *)post_id forSender:(id) sender context:(id)context
{
    CocoaTentRepostFetcher *repostFetcher = [[CocoaTentRepostFetcher alloc] init];
    
    [repostFetcher fetchRepostDataFor:entity withID:post_id forSender:sender context:context];
}

#ifdef _SYSTEMCONFIGURATION_H
- (void) reachabilityStatusHasChanged:(AFNetworkReachabilityStatus) status
{
    //NSLog(@"reachability changed with %i", status);
}
#endif
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    
    if ([keyPath isEqualToString:@"access_token"])
    {
        [self.cocoaTentApp setAccess_token:[change valueForKey:@"new"]];
    }
    
    if ([keyPath isEqualToString:@"mac_key_id"])
    {
        [self.cocoaTentApp setMac_key_id:[change valueForKey:@"new"]];
    }
    
    if ([keyPath isEqualToString:@"mac_key"])
    {
        [self.cocoaTentApp setMac_key:[change valueForKey:@"new"]];
    }
}
@end
