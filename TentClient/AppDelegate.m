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
#import "CocoaTentStatus.h"
#import "TimelineData.h"
#import <AutoHyperlinks/AutoHyperlinks.h>
#import "NSString+hmac_sha_256.h"
#import "CocoaTentCoreProfile.h"

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
    [self.timelineDataRefreshTimer invalidate];
    self.timelineDataRefreshTimer = nil;
    [self.cocoaTent getRecentPosts];
    [self.statusMessage setStringValue:@"getting timeline data"];
    [self startTimelineRefreshTimer];

}

- (IBAction)newPost:(id)sender {
    CocoaTentStatus *post = [[CocoaTentStatus alloc] init];
    
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
    
    [self.cocoaTent newPost:post];
    
    [self.statusMessage setStringValue:@"posted new status"];
    [self.statusTextValue setStringValue:@""];
    [self.charsLeft setStringValue:@"256"];
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
            
            NSString *client = [NSString stringWithFormat:@"Via: %@ (%@)",[post valueForKeyPath:@"app.name"], [post valueForKey:@"type"]];
            NSString *rawEntity = [post valueForKeyPath:@"entity"];
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
            
            
            if ([[post valueForKeyPath:@"type"] isEqualToString:@"https://tent.io/types/post/repost/v0.1.0"])
            {
                [self.cocoaTent fetchRepostDataFor:[post valueForKeyPath:@"content.entity"] withID:[post valueForKeyPath:@"content.id"] forPost:tld];
                
                tld.content = [[NSAttributedString alloc] initWithString:@"Retrieving repost data..."];
            }

            
            
           
            [newTimelineData addObject:tld];
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

@end
