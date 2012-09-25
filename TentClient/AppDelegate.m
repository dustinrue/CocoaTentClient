//
//  AppDelegate.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AppDelegate.h"
#import "CocoaTent.h"
#import "NSString+ParseQueryString.h"

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
    
    // connection parameters
    [appDefaults setValue:@"http"      forKey:@"httpProtocol"];
    [appDefaults setValue:@"localhost" forKey:@"tentEntityHost"];
    [appDefaults setValue:@"3000"      forKey:@"tentEntityPort"];

    
    // default app information
    [appDefaults setValue:@"Cocoa Tent Client"                                 forKey:@"name"];
    [appDefaults setValue:@"An example client written in Objective-C"          forKey:@"description"];
    [appDefaults setValue:@"https://github.com/dustinrue/CocoaTentClient"      forKey:@"url"];
    [appDefaults setValue:@"http://example.com/icon.png"                       forKey:@"icon"];
    [appDefaults setValue:[NSArray arrayWithObject:@"cocoatentclient://oauth"] forKey:@"redirect_uris"];
    [appDefaults setValue:[NSDictionary dictionaryWithObjectsAndKeys:@"Uses an app profile section to describe foos", @"write_profile", @"Calculates foos based on your followings", @"read_followings", nil]  forKey:@"scopes"];
    
    
    
	[[NSUserDefaults standardUserDefaults] registerDefaults:appDefaults];
    
    self.cocoaTent = [[CocoaTent alloc] init];
    
    // very explicitely and verbosely set all of the tent parameters in an effort to expose
    // the tent protocol for others. Realistically this could be done much smarter.
    [self.cocoaTent setTentServer:[NSString stringWithFormat:@"%@://%@:%@",
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"httpProtocol"],
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"tentEntityHost"],
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"tentEntityPort"]]];
    
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"name"]
                              forKey:@"name"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"description"]
                              forKey:@"description"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"url"]
                              forKey:@"url"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"url"]
                              forKey:@"url"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"icon"]
                              forKey:@"icon"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"redirect_uris"]
                              forKey:@"redirect_uris"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"scopes"]
                              forKey:@"scopes"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"id"]
                              forKey:@"id"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_algorithm"]
                              forKey:@"mac_algorithm"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key"]
                              forKey:@"mac_key"];
    [self.cocoaTent.appInfo setValue:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key_id"]
                              forKey:@"mac_key_id"];
    
    // during the OAuth2 process we need to be able to react to a specially crafted URL
    // we register for that URL here.  The URL Scheme is defined in this app's info.plist.
    [self registerForURLScheme];
}

- (void)registerForURLScheme
{
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSURL *url = [NSURL URLWithString:[[event paramDescriptorForKeyword:keyDirectObject] stringValue]]; // Now you can parse the URL and perform whatever action is needed
    
    [self.cocoaTent OAuthCallbackData:url];
}

- (IBAction)doThing:(id)sender
{

    [self.cocoaTent getUserProfile];
}

- (IBAction)performDiscover:(id)sender
{
    [self.cocoaTent discover];
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



@end
