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

@interface AppDelegate : NSObject <NSApplicationDelegate,CocoaTentDelegate,NSTextFieldDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) CocoaTent *cocoaTent;
@property (strong) CocoaTentApp *cocoaTentApp;
@property (weak) NSMutableArray *timelineData;
@property (strong) NSTimer *timelineDataRefreshTimer;

@property (strong) NSArray *mentionList;
@property (strong) NSDictionary *replyingTo;


@property (strong) id testing;

- (IBAction)saveTentEntityURL:(id)sender;
- (IBAction)doThing:(id)sender;
- (IBAction)registerWithTentServer:(id)sender;
- (IBAction)pushProfileInfo:(id)sender;
- (IBAction)newFollowing:(id)sender;
- (IBAction)getPosts:(id)sender;
- (IBAction)newPost:(id)sender;
- (IBAction)doReply:(id)sender;
- (IBAction)doRepost:(id)sender;
- (IBAction)cancelReply:(id)sender;

@property (weak) IBOutlet NSButton *cancelReplyButton;
@property (weak) IBOutlet NSTextField *followEntityValue;
@property (weak) IBOutlet NSTextField *statusTextValue;
@property (weak) IBOutlet NSScrollView *timelineScrollView;
@property (weak) IBOutlet NSTextField *statusMessage;
@property (weak) IBOutlet NSCollectionView *timelineCollectionView;
@property (weak) IBOutlet NSTextField *statusMessageTimelineLabel;
@property (weak) IBOutlet NSTextField *tentEntityURLTextField;
@property (weak) IBOutlet NSTextFieldCell *statusTextValueTextFieldCell;
@property (weak) IBOutlet NSButton *registerAppButton;
@property (weak) IBOutlet NSButton *saveButton;
@property (weak) IBOutlet NSArrayController *timelineArrayController;
@property (unsafe_unretained) IBOutlet NSCollectionViewItem *timelineCollectionViewItem;


@property (weak) IBOutlet NSTextField *charsLeft;

- (void) receivedProfileData:(NSNotification *) notification;
- (void) dataReceiveFailure:(NSNotification *) notification;

@end
