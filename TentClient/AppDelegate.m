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
    
    self.cocoaTentApp = [[CocoaTentApp alloc] init];
    
    // some of this data should be stored in KeyChain and NOT in a plain text file
    [self.cocoaTentApp setName:[[NSUserDefaults standardUserDefaults] valueForKey:@"name"]];
    [self.cocoaTentApp setDescription:[[NSUserDefaults standardUserDefaults] valueForKey:@"description"]];
    [self.cocoaTentApp setUrl:[[NSUserDefaults standardUserDefaults] valueForKey:@"url"]];
    [self.cocoaTentApp setIcon:[[NSUserDefaults standardUserDefaults] valueForKey:@"icon"]];
    [self.cocoaTentApp setRedirect_uris:[[NSUserDefaults standardUserDefaults] valueForKey:@"redirect_uris"]];
    [self.cocoaTentApp setScopes:[[NSUserDefaults standardUserDefaults] valueForKey:@"scopes"]];
    [self.cocoaTentApp setApp_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"app_id"]];
    [self.cocoaTentApp setMac_algorithm:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_algorithm"]];
    [self.cocoaTentApp setMac_key:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key"]];
    [self.cocoaTentApp setMac_key_id:[[NSUserDefaults standardUserDefaults] valueForKey:@"mac_key_id"]];
    
    // we need to know if any of these values change so it can be saved out to the preferences file
    [self.cocoaTentApp addObserver:self forKeyPath:@"name" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"description" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"url" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"icon" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"redirect_uris" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"scopes" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"app_id" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_agorithm" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"mac_key_id" options:NSKeyValueObservingOptionNew context:nil];
    [self.cocoaTentApp addObserver:self forKeyPath:@"access_token" options:NSKeyValueObservingOptionNew context:nil];
    
    
    self.cocoaTent = [[CocoaTent alloc] initWithApp:self.cocoaTentApp];
    
    // very explicitely and verbosely set all of the tent parameters in an effort to expose
    // the tent protocol for others. Realistically this could be done much smarter.
    [self.cocoaTent setTentServer:[NSString stringWithFormat:@"%@://%@:%@",
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"httpProtocol"],
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"tentEntityHost"],
                                   [[NSUserDefaults standardUserDefaults] valueForKey:@"tentEntityPort"]]];

}



- (IBAction)doThing:(id)sender
{

    [self.cocoaTent getUserProfile];
}

- (IBAction)performDiscover:(id)sender
{
    [self.cocoaTent discover];
}

- (IBAction)performAuthorizedAction:(id)sender {
    [self.cocoaTent getFollowings];
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
    NSLog(@"got updated data for %@, key: %@; value: %@", [object class], keyPath, change);
    if ([object class] == [self.cocoaTentApp class]) {
        [[NSUserDefaults standardUserDefaults] setValue:[change valueForKey:@"new"] forKey:keyPath];
    }
}
@end
