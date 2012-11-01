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
#import "CocoaTentEntity.h"
#import "CocoaTentPostTypes.h"
#import "AvatarGrabber.h"
#import "NSArray+Reverse.h"
#import "FollowingsWindowController.h"


@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //[self signTest];
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCreateOperation:)
                                                 name:@"com.dustinrue.CocoaTent.didBuildOperation"
                                               object:nil];

    NSMutableDictionary *appDefaults = [NSMutableDictionary dictionaryWithCapacity:1];

    
    self.operationCounter = 0;
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
    
    // create an object that represents us
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
    
    [self addObserver:self forKeyPath:@"replyingTo" options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:@"mentionList" options:NSKeyValueObservingOptionNew context:nil];
    
    self.replyingTo = nil;
    self.mentionList = nil;
    
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
    
    

    
    /**
     This routine will create a entity object consisting of just the core profile
     that we can pass to a Cocoa Tent object so it can begin the discover process.  
     The discover process will get the rest of our profile information automatically.
     
     This demonstrates that the tent entity URL is the smallest amount of
     information we need to interact with a tent server.  To make authorized
     requests we must also store mac_key, mac_key_id and access_token to
     some persistent store.
     */
    CocoaTentCoreProfile *coreProfile = [[CocoaTentCoreProfile alloc] init];
    
    // set the entity URL property
    coreProfile.entity = self.cocoaTentApp.tentEntity;
    
    // get an entity object
    self.cocoaTentEntity = [[CocoaTentEntity alloc] init];
    
    // set the core property to the coreProfile object;
    self.cocoaTentEntity.core = coreProfile;


    self.cocoaTent = [[CocoaTent alloc] initWithEntity:self.cocoaTentEntity];
    
    // as mentioned above, to make authorized requests we need to tell cocoatent what our
    // authorization parameters are.  We do this with a Cocoa Tent App object which in this case
    // was populated via our NSUserDefaults plist file.
    self.cocoaTent.cocoaTentApp = self.cocoaTentApp;
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
    
    NSMutableArray *moreMentionsFromText = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *postMentions = [NSMutableArray arrayWithCapacity:0];
    
    if (self.mentionList)
        [postMentions addObjectsFromArray:self.mentionList];
    
    /**
     The following routine is going to scan the content of the post to see if anyone was mentioned
     and create the mention list accordingly.  It will preserve mentions that were created
     by repost and reply while adding anyone new that was mentioned as a normal mention 
     */
    // see if there is anyone else mentioned in the post
    moreMentionsFromText = [[self.cocoaTent findMentionsInPostContent:[self.statusTextValue stringValue]] mutableCopy];
    
    NSMutableArray *mentionsToThrowAway = [NSMutableArray arrayWithCapacity:0];

    
    for (NSDictionary *username in moreMentionsFromText)
    {
        NSString *usernameExpanded = [self expandShortUsername:[username valueForKey:@"entity"]];
        for (NSDictionary *mention in postMentions)
        {
            if ([[mention valueForKey:@"entity"] isEqualToString:usernameExpanded])
                [mentionsToThrowAway addObject:username];
        }
    }
    
    [moreMentionsFromText removeObjectsInArray:mentionsToThrowAway];
    
    if ([moreMentionsFromText count] > 0)
    {
        for (NSDictionary *mention in moreMentionsFromText)
            [postMentions addObject:[NSDictionary dictionaryWithObject:[self expandShortUsername:[mention valueForKey:@"entity"]] forKey:@"entity"]];
    }
    /**
     and so ends the mention list building routine
     */
    
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
    
    
    // clear out the mentionList and replyingTo properties
    self.mentionList = nil;
    self.replyingTo = nil;
    NSLog(@"post %@", [post dictionary]);
    //[self.cocoaTent newPost:post];
    
    [self.statusMessage setStringValue:@"posted new status"];
    [self.statusTextValue setStringValue:@""];
    [self.charsLeft setStringValue:@"256"];

}

- (IBAction)doReply:(id)sender
{
    // TODO: this client app should have all of these objects/properties ready to
    // go already
    
    CocoaTentCoreProfile *core = [[CocoaTentCoreProfile alloc] init];
    core.entity = self.cocoaTentApp.tentEntity;
    CocoaTentEntity *myEntity = [[CocoaTentEntity alloc] init];
    myEntity.core = core;
    CocoaTentStatus *test = [[CocoaTentStatus alloc] initWithReplyTo:[sender valueForKey:@"fullPost"] withEntity:myEntity];
    
    [self.statusTextValue setStringValue:test.text];
    [self.statusTextValue becomeFirstResponder];
    [[self.statusTextValue currentEditor] setSelectedRange:NSMakeRange([[self.statusTextValue stringValue] length], 0)];

    self.mentionList = test.mentions;
    
}

/**
 Builds a repost request
 */
- (IBAction)doRepost:(id)sender
{
    NSDictionary *fullPost = nil;
    
    // TODO: this client app should have all of these objects/properties ready to
    // go already
    CocoaTentCoreProfile *core = [[CocoaTentCoreProfile alloc] init];
    core.entity = self.cocoaTentApp.tentEntity;
    CocoaTentEntity *myEntity = [[CocoaTentEntity alloc] init];
    myEntity.core = core;
    
    fullPost = [sender valueForKey:@"fullPost"];
    CocoaTentRepost *repost = [[CocoaTentRepost alloc] initWithRepost:fullPost withEntity:myEntity];
    
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    
    [repost setPublished_at:[NSNumber numberWithInt: timestamp]];
    [repost setLicenses:@[@"http://creativecommons.org/licenses/by/3.0/"]];
    [repost setEntity:[self.cocoaTentApp.coreInfo valueForKey:@"entity"]];
    [repost setPermissions:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"public", nil]];
 
    /*
    // find the information of the post being reposted
    fullPost = [sender valueForKey:@"fullPost"];
    NSLog(@"fullPost %@", fullPost);
    
    // store the entity and postId so we can put that into the content
    // of this repost
    
    // we have to determine if the post is a repost or not, it is dealt
    // with a bit differently than other post types
    if ([[fullPost valueForKey:@"type"] isEqual:kCocoaTentRepostType])
    {
        repost.repostedEntity = [fullPost valueForKeyPath:@"content.entity"];
        repost.repostedPostId = [fullPost valueForKeyPath:@"content.id"];
    }
    else
    {
        repost.repostedEntity = [fullPost valueForKey:@"entity"];
        repost.repostedPostId = [fullPost valueForKey:@"id"];
    }
    
    NSLog(@"postId %@", postId);
    repostMentionData = [fullPost valueForKey:@"mentions"];
    
    NSLog(@"mention data %@", repostMentionData);
    [self.statusMessage setStringValue:[NSString stringWithFormat:@"reposting %@ - %@", [repost.repostedEntity substringFromIndex:8] , postId]];
    
    
    NSLog(@"mention data %@", repostMentionData);
    
    if (repostMentionData)
        repost.mentions = repostMentionData;
    
     */

    //NSLog(@"repost data %@", [repost dictionary]);
    [self.cocoaTent newPost:repost];
}

- (IBAction)cancelReply:(id)sender {
    [self.statusTextValue setStringValue:@""];
    self.replyingTo = nil;
    self.mentionList = nil;
}

- (IBAction)showPreferences:(id)sender {
    
    
    [NSApp beginSheet:self.preferencesWindow
       modalForWindow:self.window
        modalDelegate:self
       didEndSelector:@selector(didEnd)
          contextInfo:nil];
}

- (IBAction)showFollowingsWindow:(id)sender {
    
   
    if (!self.followingsWindowController)
        self.followingsWindowController = [[FollowingsWindowController alloc] initWithWindowNibName:@"FollowingsWindowController"];
    

    [self.followingsWindowController showWindow:self];
}

- (IBAction)showFollowersWindow:(id)sender {
}

- (void) receivedProfileData:(NSNotification *) notification
{
    //NSLog(@"got profile data %@", [notification userInfo]);
}

- (void) dataReceiveFailure:(NSNotification *) notification
{
    NSLog(@"failed to get some data %@", [notification userInfo]);
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
    if ([object class] == [self.cocoaTentApp class])
    {
        [[NSUserDefaults standardUserDefaults] setValue:[change valueForKey:@"new"] forKey:keyPath];
        //NSLog(@"saved %@ for %@", [change valueForKey:@"new"], keyPath);
        
        // hack to "start up the app" once this is set
        if ([keyPath isEqualToString:@"tentEntity"])
            [self start];
        
        if ([keyPath isEqualToString:@"access_token"])
            [self start];
    }
    

    if (object == self)
    {

        if ([keyPath isEqualToString:@"mentionList"])
        {
            if ([change objectForKey:@"new"] != [NSNull null])
                [self.cancelReplyButton setEnabled:YES];
            else
                [self.cancelReplyButton setEnabled:NO];
        }
    }
}

#pragma mark -
#pragma mark Post Handling

- (void) newStatusPost:(id) postData
{
    BOOL postMentionsMe   = NO;
    BOOL postRepliesToMe  = NO;
    NSDictionary *post = postData;
    
    //NSLog(@"posts %@", postData);
    NSMutableArray *newTimelineData = nil;
    
    if (self.timelineData)
        newTimelineData = self.timelineData;
    else
        newTimelineData = [NSMutableArray arrayWithCapacity:0];
    
    
   // for (NSDictionary *post in postData)
   // {
        // TODO: don't filter here, instead setup the poller to ask for a configured list of post types
        if ([[post valueForKeyPath:@"type"] isEqualToString:kCocoaTentStatusType] || [[post valueForKeyPath:@"type"] isEqualToString:kCocoaTentRepostType])
        {
            
            NSString *client = [NSString stringWithFormat:@"Via: %@",[post valueForKeyPath:@"app.name"]];
            
            
            NSMutableParagraphStyle *rightAlign = [[NSMutableParagraphStyle alloc] init];
            [rightAlign setAlignment:NSRightTextAlignment];
            
            NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        rightAlign, NSParagraphStyleAttributeName, nil];
            
            
            NSAttributedString *clientAS = [[NSAttributedString alloc] initWithString:client attributes:attributes];
            NSString *rawEntity = nil;
            
            // Build a sort of nice title for the post
            if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentStatusType])
            {
                rawEntity = [NSString stringWithFormat:@"%@ says:", [post valueForKeyPath:@"entity"]];
            }
            else if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentRepostType])
            {
                rawEntity = [NSString stringWithFormat:@"%@ reposted %@:", [post valueForKeyPath:@"entity"], [post valueForKeyPath:@"content.entity"]];
            }
            
            NSString *rawContent = ([post valueForKeyPath:@"content.text"]) ? [post valueForKeyPath:@"content.text"]:@"";
            
            AHHyperlinkScanner *contentScanner = [[AHHyperlinkScanner alloc] initWithString:rawContent usingStrictChecking:NO];
            NSAttributedString *content = [contentScanner linkifiedString];
            
            AHHyperlinkScanner *entityScanner = [[AHHyperlinkScanner alloc] initWithString:rawEntity usingStrictChecking:NO];
            NSAttributedString *entity = [entityScanner linkifiedString];
            
            //NSLog(@"wanting to add %@ - %@", entity, content);
            TimelineData *tld = [[TimelineData alloc] init];
            tld.entity = entity;
            tld.content = content;
            tld.client = clientAS;
            tld.post_id = [post valueForKey:@"id"];
            tld.fullPost = post;
            tld.avatar = [[NSImage alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://dr49qsqhb5y4j.cloudfront.net/default1.png"]];
            
            if ([[post valueForKey:@"entity"] isEqualToString:self.cocoaTentApp.tentEntity])
                tld.isMine = YES;
            else
                tld.isMine = NO;
            
            // determine reply/mention info
            for (NSDictionary *mention in [post valueForKey:@"mentions"])
            {
                if ([[mention valueForKey:@"entity"] isEqualToString:self.cocoaTentApp.tentEntity])
                {
                    postMentionsMe = YES;
                    if ([mention objectForKey:@"post"])
                    {
                        postRepliesToMe = YES;
                        AHHyperlinkScanner *mentionedEntityScanner = [[AHHyperlinkScanner alloc] initWithString:[NSString stringWithFormat:@"In reply to: %@",  [mention valueForKey:@"entity"]] usingStrictChecking:NO];
                        NSAttributedString *mentionedEntity = [mentionedEntityScanner linkifiedString];
                        tld.inReplyTo = mentionedEntity;
                    }
                }
                else if ([mention objectForKey:@"post"] && [mention objectForKey:@"entity"])
                {
                    AHHyperlinkScanner *mentionedEntityScanner = [[AHHyperlinkScanner alloc] initWithString:[NSString stringWithFormat:@"In reply to: %@",  [mention valueForKey:@"entity"]] usingStrictChecking:NO];
                    NSAttributedString *mentionedEntity = [mentionedEntityScanner linkifiedString];
                    tld.inReplyTo = mentionedEntity;
                }
            }
            
            
            if ([[post valueForKeyPath:@"type"] isEqualToString:kCocoaTentRepostType])
            {
                [self.cocoaTent fetchRepostDataFor:[post valueForKeyPath:@"content.entity"] withID:[post valueForKeyPath:@"content.id"] forSender:self context:[NSDictionary dictionaryWithObjectsAndKeys:tld, @"timelineItem", nil]];
                
                tld.content = [[NSAttributedString alloc] initWithString:@"Retrieving repost data..."];
            }
            
            // grab the avatar if it is available
            AvatarGrabber *aGrabber = [[AvatarGrabber alloc] init];

            [aGrabber performSelectorInBackground:@selector(getAvatarInBackground:) withObject:[NSDictionary dictionaryWithObjectsAndKeys:[post valueForKey:@"entity"], @"entity", tld, @"timelineObject", nil]];
            
            [newTimelineData insertObject:tld atIndex:0];
        }
    //}
    
    self.timelineData = newTimelineData;
    
    
    [self.statusMessage setStringValue:@"timeline updated"];

}

- (void) deleteStatusPost:(id) postData
{
    TimelineData *entryToDelete = nil;
    @synchronized(self)
    {
        NSMutableArray *currentTimeLine = self.timelineData;
        
        for (TimelineData *tld in currentTimeLine)
        {
            if ([[tld.fullPost valueForKey:@"entity"] isEqualToString:[postData valueForKey:@"entity"]] &&
                [[tld.fullPost valueForKey:@"id"] isEqualToString:[postData valueForKeyPath:@"content.id"]])
            {
                entryToDelete = tld;
                NSLog(@"found record");
                break;
            }
        }
        [currentTimeLine removeObject:entryToDelete];
        self.timelineData = currentTimeLine;
    }
    

}

- (void) deletePost:(id) postData
{
    NSTimeInterval timestamp = [[NSDate date] timeIntervalSince1970];
    CocoaTentDelete *delete = [[CocoaTentDelete alloc] init];
    
    [delete setPermissions:[NSDictionary dictionaryWithObjectsAndKeys:@"true", @"public", nil]];
    [delete setPublished_at:[NSNumber numberWithInt: timestamp]];
    [delete setLicenses:@[@"http://creativecommons.org/licenses/by/3.0/"]];
    [delete setEntity:[self.cocoaTentApp.coreInfo valueForKey:@"entity"]];
    [delete setPost_id:[[postData valueForKey:@"fullPost"] valueForKey:@"id"]];
    
    //NSLog(@"delete %@", [delete dictionary]);
    [self.cocoaTent newPost:delete];
    
    
}

#pragma mark -
#pragma mark CocoaTent delegate methods


// CocoaTent delegate methods
-(void) didReceiveNewPost:(id)postData
{
    postData = [postData reversedArray];
    
    NSLog(@"post data %@", postData);
    if ([postData count] > 0)
        [self issueNotificationWithTitle:@"New Tent Messages" andMessage:[NSString stringWithFormat:@"Received %ld new messages", [postData count]]];
    
    // decide what type of post we've received
    NSLog(@"parsing");
    for (NSDictionary *post in postData)
    {
        if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentStatusType])
            [self newStatusPost:post];
        
        if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentRepostType])
            [self newStatusPost:post];
        
        if ([[post valueForKey:@"type"] isEqualToString:kCocoaTentDeleteType])
            [self deleteStatusPost:post];
    }
    NSLog(@"done parsing");
    [self startTimelineRefreshTimer];
}

- (void) didReceiveRepostData:(NSDictionary *)userInfo
{
    TimelineData *tld = [userInfo objectForKey:@"timelineItem"];
    
    tld.content = [[userInfo objectForKey:@"postData"] valueForKeyPath:@"content.text"];
}



- (void) cocoaTentIsReady:(id) sender
{
    if (!self.cocoaTentApp.access_token)
    {
        [self.statusMessage setStringValue:@"Please click the Register App button and register your app, then click Refresh Timeline"];
    }
    else
    {
        
        if (self.cocoaTentApp.access_token)
            [self.registerAppButton setEnabled:NO];
        
        [self.tentEntityURLTextField setStringValue:self.cocoaTentApp.tentEntity];
        [self.saveButton setEnabled:NO];
        [self.tentEntityURLTextField setEnabled:NO];

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

- (void) communicationError:(NSError *) error request:(NSURLRequest *)request  response:(NSHTTPURLResponse *)response json:(id) JSON
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
    
    if ([[self.statusTextValue stringValue] length] < 1)
        [self cancelReply:nil];
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

- (NSString *) expandShortUsername:(NSString *) username
{
    if ([[username substringToIndex:8] isEqualToString:@"https://"] || [[username substringToIndex:7] isEqualToString:@"http://"])
        return username;
    
    // TODO: maybe autocomplete via who we follow or who follows us
    return [NSString stringWithFormat:@"https://%@.tent.is", username];
}

- (NSDictionary *) findPostInTimelineBasedOnSendingButton:(id) sendingButton
{
    // I'm cheating really badly here because I don't want implement
    // the NSControllerView properly.  I'd be delighted if someone did though
    NSView *theViewThisButtonIsOn = [sendingButton superview];
    
    NSString *postId = nil;
    NSString *entity = nil;
    NSString *content = nil;
    
    
    NSLog(@"sub views %@", theViewThisButtonIsOn.subviews);
    
    // everything I want is inside of an NSBox, it'll be the first object
    NSBox *theBox = [theViewThisButtonIsOn.subviews objectAtIndex:0];
    
    // search for the values we need to do a reply
    // in this case, I know that the items I want to pull the info from
    // are on a subview of "theBox" at index 1
    for (id item in [[theBox.subviews objectAtIndex:1] subviews])
    {
        // there are elements on the view that aren't nstextfields,
        // skip those
        if ([item class] != [NSTextField class])
            continue;
        
        if ([[item identifier] isEqualToString:@"post_id"])
        {
            postId = [item stringValue];
        }
        
        if ([[item identifier] isEqualToString:@"entity"])
        {
            entity = [item stringValue];
        }
        
        if ([[item identifier] isEqualToString:@"content"])
        {
            content = [item stringValue];
        }
    }
    
    NSLog(@"found entity - %@ %@", entity, postId);
    
    
    // manually find the post being replied to in the timeline view
    // this seriously is not the right way to do this
    NSArray *timelineData = [self.timelineArrayController arrangedObjects];
    NSDictionary *thePostWeFound = nil;
    for (NSDictionary *post in self.timelineData)
    {
        if ([[[post valueForKey:@"entity"] string] isEqualToString:entity] && [[post valueForKey:@"post_id"] isEqualToString:postId])
        {
            thePostWeFound = [[timelineData objectAtIndex:[self.timelineData indexOfObject:post]] valueForKey:@"fullPost"];
            
        }
    }
    
    return thePostWeFound;
}

- (void) didCreateOperation:(NSNotification *)notification
{
    self.operationCounter++;
}

- (void) signTest
{
    /*
    1350446572
    82C6442A5B2F4750BD4AF7D693D81FE1947980000FAB78044BDD8
    GET
    /tent/posts
    dustinrue.tent.is
    443
     
     52f319a5f185e6a0adf7d51f67a6ef70
     a:2d32483f
     */
    NSString *normalizedRequestString = [NSString stringWithFormat:@"%d\n%@\n%@\n%@\n%@\n%@\n\n",
                                     1350446718,
                                     @"AF01A441BD8B4E66A79A83363963ECC6949250000FAD98369D41E",
                                     @"GET",
                                     @"/tent/posts",
                                     @"dustinrue.tent.is",
                                         @"443"];

NSLog(@"results %@", [normalizedRequestString hmac_sha_256:@"52f319a5f185e6a0adf7d51f67a6ef70"]);

}

@end
