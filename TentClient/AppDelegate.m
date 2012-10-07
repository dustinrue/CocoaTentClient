//
//  AppDelegate.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AppDelegate.h"
#import "CocoaTent.h"
#import "CocoaTentApp.h"
#import "CocoaTentPost.h"
#import "TimelineData.h"
#import <AutoHyperlinks/AutoHyperlinks.h>
#import "NSString+hmac_sha_256.h"
#import "CocoaTentCoreProfile.h"
#import "CocoaTentPostTypes.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // the example tent client communicates back to us via notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appInfoDidChange:)
                                                 name:@"appInfoDidChange"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedProfileData:)
                                                 name:@"didReceiveProfileData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataReceiveFailure:)
                                                 name:@"receiveDataFailure"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(userDefaultsChanged:)
												 name:NSUserDefaultsDidChangeNotification
											   object:nil];
    
    

    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithCapacity:1];

    
    // default app information. Typically you wouldn't set all of these via NSUserDefaults
    // because this would allow a user to override values by editing the preferences file
    // for this app.
    [appDefaults setValue:@"Cocoa Tent Client"                                 forKey:@"name"];
    [appDefaults setValue:@"An example client written in Objective-C"          forKey:@"description"];
    [appDefaults setValue:@"https://github.com/dustinrue/CocoaTentClient"      forKey:@"url"];
    [appDefaults setValue:@"http://example.com/icon.png"                       forKey:@"icon"];
    [appDefaults setValue:[NSArray arrayWithObject:@"cocoatentclient://oauth"] forKey:@"redirect_uris"];
    
    [appDefaults setValue:[NSDictionary dictionaryWithObjectsAndKeys:
                           @"Uses an app profile section to describe foos", @"write_profile",
                           @"Calculates foos based on your followings",     @"read_followings",
                           @"read_profile",                                 @"read_profile",
                           @"read_followers",                               @"read_followers",
                           @"write_followers",                              @"write_followers",
                           @"read_followings",                              @"read_followings",
                           @"write_followings",                             @"write_followings",
                           @"read_posts",                                   @"read_posts",
                           @"write_posts",                                  @"write_posts", nil]  forKey:@"scopes"];
    
    // What post types will this app post?  This is the full list as of v0.1.
    // You could also simply set it to "all."  In reality this only needs to be a list of
    // of the URLs, I've included the type name for clarity.  That said, the CocoaTentLibrary
    // does expect a dictionry of values.
    [appDefaults setValue:[NSDictionary dictionaryWithObjectsAndKeys:
                           @"Status",  @"https://tent.io/types/post/status/v0.1.0",
                           //@"Essay",   @"https://tent.io/types/post/essay/v0.1.0",
                           //@"Photo",   @"https://tent.io/types/post/photo/v0.1.0",
                           //@"Album",   @"https://tent.io/types/post/album/v0.1.0",
                           @"Repost",  @"https://tent.io/types/post/repost/v0.1.0",
                           @"Profile", @"https://tent.io/types/post/profile/v0.1.0",
                           //@"Delete",  @"https://tent.io/types/post/delete/v0.1.0",
                           nil] forKey:@"tent_post_types"];
    
    // What profile info types will this app deal with?  This is the full list as of v0.1.
    // You could also simply set it to "all."  Like tent_post_types all that is really needed
    // is an array of URLs, I've included the type name for clarity.  That said, the CocoaTentLibrary
    // does expect a dictionry of values.

    [appDefaults setValue:[NSDictionary dictionaryWithObjectsAndKeys:
                           @"Core",    @"https://tent.io/types/info/core/v0.1.0",
                           @"Basic",   @"https://tent.io/types/info/basic/v0.1.0", nil] forKey:@"tent_profile_info_types"];
    
    
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    self.cocoaTentApp = [[CocoaTentApp alloc] init];
    

    
    // some of this data should be stored in KeyChain and NOT in a plain text file
    [self.cocoaTentApp setName:[[NSUserDefaults standardUserDefaults] valueForKey:@"name"]];
    [self.cocoaTentApp setDescription:[[NSUserDefaults standardUserDefaults] valueForKey:@"description"]];
    [self.cocoaTentApp setUrl:[[NSUserDefaults standardUserDefaults] valueForKey:@"url"]];
    [self.cocoaTentApp setIcon:[[NSUserDefaults standardUserDefaults] valueForKey:@"icon"]];
    [self.cocoaTentApp setRedirect_uris:[[NSUserDefaults standardUserDefaults] valueForKey:@"redirect_uris"]];
    
    [self.cocoaTentApp setScopes:[[NSUserDefaults standardUserDefaults] valueForKey:@"scopes"]];
    [self.cocoaTentApp setTent_post_types:[[NSUserDefaults standardUserDefaults] valueForKey:@"tent_post_types"]];
    [self.cocoaTentApp setTent_profile_info_types:[[NSUserDefaults standardUserDefaults] valueForKey:@"tent_profile_info_types"]];
     
    [self.cocoaTentApp setApp_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"app_id"]];
    [self.cocoaTentApp setMac_key:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key"]];
    [self.cocoaTentApp setMac_key_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key_id"]];
    [self.cocoaTentApp setAccess_token:[[NSUserDefaults standardUserDefaults] valueForKey:@"access_token"]];
    [self.cocoaTentApp setTentEntity:[[NSUserDefaults standardUserDefaults] valueForKey:@"tentEntity"]];
    
    // we need to know if any of these values change so it can be saved out to the preferences file
    [self.cocoaTentApp addObserver:self forKeyPath:@"app_id" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_agorithm" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key_id" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"access_token" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"tentEntity" options:NSKeyValueObservingOptionNew context:nil];
    

    [self.statusTextValue setDelegate:self];
    
    if (self.cocoaTentApp.tentEntity)
        [self.tentEntityURLTextField setStringValue:self.cocoaTentApp.tentEntity];
    
    [self.statusMessage setStringValue:@"starting up"];
    [self.charsLeft setStringValue:@"256"];
    [self start];
    
    
}

- (void) start
{
    if (!self.cocoaTentApp.tentEntity)
    {
        [self.statusMessage setStringValue:@"Please set your Tent Entity URL and click Save"];
        return;
    }
    else if ([self.cocoaTentApp.tentEntity rangeOfString:@"http"].location == NSNotFound)
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Invalid input" defaultButton:nil alternateButton:nil otherButton:nil informativeTextWithFormat:@"You must include http or https in your tent entity URL"];
        
        [alert runModal];
        return;
    }

    if (self.cocoaTentApp.access_token)
        [self.registerAppButton setEnabled:NO];
    
    [self.tentEntityURLTextField setStringValue:self.cocoaTentApp.tentEntity];
    [self.saveButton setEnabled:NO];
    [self.tentEntityURLTextField setEnabled:NO];

    self.cocoaTent = [[CocoaTent alloc] initWithApp:self.cocoaTentApp];

    [self.cocoaTent setDelegate:self];
    [self.statusMessage setStringValue:@"discovering API root"];
    [self.cocoaTent discover];
    

    
    
}

- (void) startTimelineRefreshTimer
{
    self.timelineDataRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)15
                                                                     target:self selector:@selector(getPosts:)
                                                                   userInfo:nil
                                                                    repeats:NO];
}

- (IBAction)saveTentEntityURL:(id)sender
{

        self.cocoaTentApp.tentEntity = [self.tentEntityURLTextField stringValue];
}

- (IBAction)doThing:(id)sender
{

    [self.cocoaTent getUserProfile];
}

- (IBAction)registerWithTentServer:(id)sender
{
    [self.cocoaTent registerWithTentServer];
}


- (IBAction)pushProfileInfo:(id)sender {
    
}

- (IBAction)newFollowing:(id)sender {
    NSString *newFollowee = [self.followEntityValue stringValue];
    
    if (newFollowee)
        [self.cocoaTent followEntity:newFollowee];
    
    [self.followEntityValue setStringValue:@""];
}

- (IBAction)getPosts:(id)sender {
    if ([sender class] == [NSButton class])
    {
        self.timelineData = nil;
        [self.cocoaTent clearLastPostCounters];
    }
    
    [self.timelineDataRefreshTimer invalidate];
    self.timelineDataRefreshTimer = nil;
    [self.cocoaTent getRecentPosts];
    [self.statusMessage setStringValue:@"getting timeline data"];
    [self startTimelineRefreshTimer];

}

- (IBAction)newPost:(id)sender {
    
    CocoaTentStatus *post = [[CocoaTentStatus alloc] init];
    

    NSMutableArray *postMentions = [NSMutableArray arrayWithCapacity:0];
    
    if (self.replyingTo)
        [postMentions addObjectsFromArray:[self.replyingTo valueForKey:@"mentions"]];
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    NSDictionary *app = [NSDictionary dictionaryWithObjectsAndKeys:
                         self.cocoaTentApp.name, @"name",
                         self.cocoaTentApp.url, @"url", nil];
    
    [post setApp:app];
    [post setText:[self.statusTextValue stringValue]];
    [post setPublished_at:[NSNumber numberWithInt: timestamp]];
    [post setLicenses:@[@"http://creativecommons.org/licenses/by/3.0/"]];
    [post setEntity:[self.cocoaTentApp.coreInfo valueForKey:@"entity"]];
    [post setPermissions:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"public", nil]];
    
    // check the post content for mentions and build a mention set if needed
    
    if (postMentions)
    {
        [post setMentions:postMentions];
    }
    
    
    [self.cocoaTent newPost:post];
    
    [self.statusMessage setStringValue:@"posted new status"];
    [self.statusTextValue setStringValue:@""];
    [self.charsLeft setStringValue:@"256"];
    self.mentionList = nil;
    self.replyingTo = nil;
}

- (IBAction)doReply:(id)sender
{

    // I'm cheating really badly here because I don't want implement
    // the NSControllerView properly.  I'd be delighted if someone did though 
    NSView *theViewThisButtonIsOn = [sender superview];
    NSString *postId = nil;
    NSString *entity = nil;
    NSString *content = nil;
    NSMutableArray *mentionListArray = nil;
    NSString *mentionList = @"";
    
    
    // search for the values we need to do a reply
    for (NSTextField *item in theViewThisButtonIsOn.subviews)
    {
        if ([[item identifier] isEqualToString:@"post_id"])
            postId = [item stringValue];
        
        if ([[item identifier] isEqualToString:@"entity"])
            entity = [item stringValue];
        
        if ([[item identifier] isEqualToString:@"content"])
            content = [item stringValue];
    }
    
    // manually find the post being replied to in the timeline view
    // this seriously is not the right way to do this
    
    NSArray *timelineData = [self.timelineArrayController arrangedObjects];
    
    for (NSDictionary *post in self.timelineData)
    {
        if ([[[post valueForKey:@"entity"] string] isEqualToString:entity] && [[post valueForKey:@"post_id"] isEqualToString:postId])
        {
            NSDictionary *thePostWeFound = [[timelineData objectAtIndex:[self.timelineData indexOfObject:post]] valueForKey:@"fullPost"];
            self.replyingTo =  [thePostWeFound mutableCopy];
        }
    }
    
    NSMutableArray *currentMentionList = [[self.replyingTo valueForKey:@"mentions"] mutableCopy];
    
    [currentMentionList addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                   [self.replyingTo valueForKey:@"entity"], @"entity",
                                   [self.replyingTo valueForKey:@"id"], @"post", nil]];
    
    [self.replyingTo setValue:currentMentionList forKey:@"mentions"];
    
    [self.statusMessage setStringValue:[NSString stringWithFormat:@"replying to %@ - %@", [entity substringFromIndex:8] , postId]];
    
    // build the username for the entity we are replying too, not sure
    // what the proper way to do this is, but this seems to be the
    // "normal" format on tent.is
    NSArray *explodedOnPeriod = [entity componentsSeparatedByString:@"."];
    NSString *username = [[explodedOnPeriod objectAtIndex:0] substringFromIndex:8];
    
    mentionListArray = [[self.cocoaTent findMentionsInPostContent:content] mutableCopy];
    
    if ([mentionListArray count] > 0)
    {
        for (NSDictionary *mention in mentionListArray)
        {
            // don't include our own name in the reply list, that's already in the mention list, no need to include it in
            // the text of the post as well
            if (![[mention valueForKey:@"entity"] isEqualToString:[self getShortUsernameFromEntityURL:self.cocoaTentApp.tentEntity]])
                mentionList = [NSString stringWithFormat:@"^%@ %@", [mention valueForKey:@"entity"], mentionList];
        }
        

    }
    [self.statusTextValue setStringValue:[NSString stringWithFormat:@"^%@ %@", username, mentionList]];
    [self.statusTextValue becomeFirstResponder];
    [[self.statusTextValue currentEditor] setSelectedRange:NSMakeRange([[self.statusTextValue stringValue] length], 0)];
    [mentionListArray removeAllObjects];
    
    [mentionListArray addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                                entity, @"entity",
                                postId, @"post", nil]];
    
    self.mentionList = mentionListArray;
     

}

- (IBAction)doRepost:(id)sender
{
    // I'm cheating really badly here because I don't want implement
    // the NSControllerView properly.  I'd be delighted if someone did though 
    NSView *theViewThisButtonIsOn = [sender superview];
    NSString *postId = nil;
    NSString *entity = nil;
    NSArray *repostMentionData = nil;
    
    CocoaTentRepost *repost = [[CocoaTentRepost alloc] init];
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    [repost setPublished_at:[NSNumber numberWithInt: timestamp]];
    [repost setLicenses:@[@"http://creativecommons.org/licenses/by/3.0/"]];
    [repost setEntity:[self.cocoaTentApp.coreInfo valueForKey:@"entity"]];
    [repost setPermissions:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"public", nil]];
 
    // search for the values we need to do a reply
    for (NSTextField *item in theViewThisButtonIsOn.subviews)
    {
        if ([[item identifier] isEqualToString:@"post_id"])
            postId = [item stringValue];
        
        if ([[item identifier] isEqualToString:@"entity"])
            entity = [item stringValue];
    }
    
    NSLog(@"found post_id %@ for entity %@", postId, entity);
    
    // we should have the post_id and entity from the form, now we search
    // the timeline for matching data
    NSArray *timelineData = [self.timelineArrayController arrangedObjects];
    
    for (NSDictionary *post in self.timelineData)
    {
        if ([[[post valueForKey:@"entity"] string] isEqualToString:entity] && [[post valueForKey:@"post_id"] isEqualToString:postId])
        {
            NSDictionary *thePostWeFound = [[timelineData objectAtIndex:[self.timelineData indexOfObject:post]] valueForKey:@"fullPost"];
            repostMentionData =  [thePostWeFound mutableCopy];
        }
    }
    
    
    [self.statusMessage setStringValue:[NSString stringWithFormat:@"reposting %@ - %@", [entity substringFromIndex:8] , postId]];
    
    NSLog(@"mention data %@", repostMentionData);
    repost.repostedEntity = [repostMentionData valueForKey:@"entity"];
    repost.repostedPostId = [repostMentionData valueForKey:@"id"];

    NSLog(@"repost data %@", [repost dictionary]);
    //[self.cocoaTent newPost:repost];
}

- (void) receivedProfileData:(NSNotification *) notification
{
    NSLog(@"got profile data %@", [notification userInfo]);
}

- (void) dataReceiveFailure:(NSNotification *) notification
{
    NSLog(@"failed to get some data");
}

- (void) userDefaultsChanged:(NSNotification *) notification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void) appInfoDidChange:(NSNotification *) notification
{
    // during the OAuth2 process we're going to get back some values from the tent server
    // we store those in the apps config file
    [[NSUserDefaults standardUserDefaults] setValue:[[notification userInfo] valueForKey:@"mac_algorithm" ] forKey:@"mac_algorithm"];
    [[NSUserDefaults standardUserDefaults] setValue:[[notification userInfo] valueForKey:@"mac_key"]        forKey:@"mac_key"];
    [[NSUserDefaults standardUserDefaults] setValue:[[notification userInfo] valueForKey:@"mac_key_id"]     forKey:@"mac_key_id"];
    [[NSUserDefaults standardUserDefaults] setValue:[[notification userInfo] valueForKey:@"id"]             forKey:@"id"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //NSLog(@"got updated data for %@, key: %@; value: %@", [object class], keyPath, change);
    if ([object class] == [self.cocoaTentApp class]) {
        [[NSUserDefaults standardUserDefaults] setValue:[change valueForKey:@"new"] forKey:keyPath];
        //NSLog(@"saved %@ for %@", [change valueForKey:@"new"], keyPath);
        
        // hack to "start up the app" once this is set
        if ([keyPath isEqualToString:@"tentEntity"])
            [self start];
        
        if ([keyPath isEqualToString:@"access_token"])
            [self start];
    }
}

#pragma mark -
#pragma mark CocoaTent delegate methods


// CocoaTent delegate methods
-(void) didReceiveNewPost:(id)postType withPostData:(id)postData
{
    
    if ([postData count] > 0)
        [self issueNotificationWithTitle:@"New Tent Messages" andMessage:[NSString stringWithFormat:@"Received %ld new messages", [postData count]]];
    
    NSLog(@"posts %@", postData);
    NSMutableArray *newTimelineData = nil;
    
    if (self.timelineData)
        newTimelineData = self.timelineData;
    else
        newTimelineData = [NSMutableArray arrayWithCapacity:0];
        
    
    for (NSDictionary *post in postData)
    {
        // TODO: don't filter here, instead setup the poller to ask for a configured list of post types
        if ([[post valueForKeyPath:@"type"] isEqualToString:@"https://tent.io/types/post/status/v0.1.0"] || [[post valueForKeyPath:@"type"] isEqualToString:@"https://tent.io/types/post/repost/v0.1.0"])
        {
            
            NSString *client = [NSString stringWithFormat:@"Via: %@ (%@)",[post valueForKeyPath:@"app.name"], [self getSimplePostTypeText:[post valueForKey:@"type"]]];
            
            NSString *rawEntity = nil;
            // Build a sort a nice title for the post
            if ([[self getSimplePostTypeText:[post valueForKey:@"type"]] isEqualToString:@"status"])
                rawEntity = [NSString stringWithFormat:@"%@ says:", [post valueForKeyPath:@"entity"]];
            
            else if ([[self getSimplePostTypeText:[post valueForKey:@"type"]] isEqualToString:@"repost"])
                rawEntity = [NSString stringWithFormat:@"%@ reposted:", [post valueForKeyPath:@"entity"]];
            
            NSString *rawContent = ([post valueForKeyPath:@"content.text"]) ? [post valueForKeyPath:@"content.text"]:@"";
            
            AHHyperlinkScanner *contentScanner = [[AHHyperlinkScanner alloc] initWithString:rawContent usingStrictChecking:NO];
            NSAttributedString *content = [contentScanner linkifiedString];
            
            AHHyperlinkScanner *entityScanner = [[AHHyperlinkScanner alloc] initWithString:rawEntity usingStrictChecking:NO];
            NSAttributedString *entity = [entityScanner linkifiedString];
            
            //NSLog(@"wanting to add %@ - %@", entity, content);
            TimelineData *tld = [[TimelineData alloc] init];
            tld.entity = entity;
            tld.content = content;
            tld.client = client;
            tld.post_id = [post valueForKey:@"id"];
            tld.fullPost = post;
            
            if ([[post valueForKey:@"entity"] isEqualToString:self.cocoaTentApp.tentEntity])
                NSLog(@"a post from me of type %@", [post valueForKey:@"type"]);
            
            if ([[post valueForKeyPath:@"type"] isEqualToString:@"https://tent.io/types/post/repost/v0.1.0"])
            {
                [self.cocoaTent fetchRepostDataFor:[post valueForKeyPath:@"content.entity"] withID:[post valueForKeyPath:@"content.id"] forPost:tld];
                
                tld.content = [[NSAttributedString alloc] initWithString:@"Retrieving repost data..."];
            }
         
            [newTimelineData insertObject:tld atIndex:0];
        }
    }
  
    self.timelineData = newTimelineData;


    [self.statusMessage setStringValue:@"timeline updated"];
    [self startTimelineRefreshTimer];

}

- (void) cocoaTentIsReady
{
    if (!self.cocoaTentApp.access_token)
    {
        [self.statusMessage setStringValue:@"Please click the Register App button and register your app, then click Refresh Timeline"];
    }
    else
    {
        
        
        //[self.cocoaTent pushProfileInfo:cp];
        [self.cocoaTent getUserProfile];
        [self getPosts:nil];
    }
}

- (void) didSubmitNewPost
{
    self.mentionList = nil;
    [self.statusMessage setStringValue:@"Posted successfully"];
}

- (void) didUpdateProfile:(id)sender
{
    [self.statusMessage setStringValue:@"Updated profile successfully"];
}
- (void) communicationError:(NSError *)error
{
    [self.statusMessage setStringValue:@"failed to perform last operation"];
}

#pragma mark -
#pragma mark NSTextField delegates

-(void)controlTextDidChange:(NSNotification*)notification
{
    //NSLog(@"note %@", notification);
    // cheat a bit, just assume it is the right text field :)
    [self.charsLeft setStringValue:[NSString stringWithFormat:@"%ld",256 - [[self.statusTextValue stringValue] length]]];
}
#pragma mark -
#pragma mark timeline collection view
-(void)insertObject:(TimelineData *)p inTimelineDataAtIndex:(NSUInteger)index {
    [self.timelineData insertObject:p atIndex:index];
}

-(void)removeObjectFromPersonModelArrayAtIndex:(NSUInteger)index {
    [self.timelineData removeObjectAtIndex:index];
}

- (void) issueNotificationWithTitle:(NSString *)title andMessage:(NSString *)message
{
    NSUserNotification *notificationMessage = [[NSUserNotification alloc] init];
    
    notificationMessage.title = title;
    notificationMessage.informativeText = message;
    
    NSUserNotificationCenter *unc = [NSUserNotificationCenter defaultUserNotificationCenter];
    
    [unc scheduleNotification:notificationMessage];
    
}

#pragma mark -
#pragma mark Utilities

- (NSString *) getShortUsernameFromEntityURL:(NSString *)entityURL
{
    NSString *part1 = [[entityURL componentsSeparatedByString:@"."] objectAtIndex:0];
    
    return [part1 substringFromIndex:8];
}

- (NSString *) getSimplePostTypeText:(NSString *)postType
{
    NSArray *part1 = [postType componentsSeparatedByString:@"/"];
    
    return [part1 objectAtIndex:5];
}

@end
