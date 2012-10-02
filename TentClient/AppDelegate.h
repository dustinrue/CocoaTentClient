//
//  AppDelegate.h
//  TentClient
//
//  Created by Dustin Rue on 9/23/12.
//  Copyright (c) 2012 Dustin Rue. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CocoaTent.h"

@class CocoaTent;
@class CocoaTentApp;

@interface AppDelegate : NSObject <NSApplicationDelegate,CocoaTentDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) CocoaTent *cocoaTent;
@property (strong) CocoaTentApp *cocoaTentApp;
@property (weak) NSMutableArray *timelineData;
@property (strong) NSTimer *timelineDataRefreshTimer;

- (IBAction)doThing:(id)sender;
- (IBAction)performDiscover:(id)sender;
- (IBAction)performAuthorizedAction:(id)sender;
- (IBAction)pushProfileInfo:(id)sender;
- (IBAction)newFollowing:(id)sender;
- (IBAction)getPosts:(id)sender;
- (IBAction)newPost:(id)sender;
@property (weak) IBOutlet NSTextField *followEntityValue;
@property (weak) IBOutlet NSTextField *statusTextValue;
@property (weak) IBOutlet NSScrollView *timelineScrollView;
@property (weak) IBOutlet NSTextField *statusMessage;
@property (weak) IBOutlet NSCollectionView *timelineCollectionView;
@property (weak) IBOutlet NSTextField *statusMessageTimelineLabel;

- (void) receivedProfileData:(NSNotification *) notification;
- (void) dataReceiveFailure:(NSNotification *) notification;

@end
