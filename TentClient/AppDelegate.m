//
//  AppDelegate.m
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import "AppDelegate.h"
#import "CocoaTent.h"

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedProfileData:)
                                                 name:@"didReceiveProfileData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dataReceiveFailure:)
                                                 name:@"receiveDataFailure"
                                               object:nil];
    
    self.cocoaTent = [[CocoaTent alloc] init];
    
    [self registerForURLScheme];
}

- (void)registerForURLScheme {
    [[NSAppleEventManager sharedAppleEventManager] setEventHandler:self andSelector:@selector(getUrl:withReplyEvent:) forEventClass:kInternetEventClass andEventID:kAEGetURL];
}

- (void)getUrl:(NSAppleEventDescriptor *)event withReplyEvent:(NSAppleEventDescriptor *)replyEvent {
    NSString *url = [[event paramDescriptorForKeyword:keyDirectObject] stringValue]; // Now you can parse the URL and perform whatever action is needed
    NSLog(@"got URL %@", url);
}

- (IBAction)doThing:(id)sender {

    [self.cocoaTent getUserProfile];
}

- (IBAction)performDiscover:(id)sender {
    [self.cocoaTent discover];
}

- (void) receivedProfileData:(NSNotification *) notification {
    NSLog(@"got profile data %@", [notification userInfo]);
}

- (void) dataReceiveFailure:(NSNotification *) notification {
    NSLog(@"failed to get some data");
}


@end
