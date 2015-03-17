//
//  AppDelegate.m
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "AppDelegate.h"
#import "NPImagesController.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;

@property (weak) IBOutlet NPImagesController *imagesController;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSDictionary *defaults = @{@"Overwrite": @(NO), @"Prefix": @"", @"Suffix": @"", @"QualityMin": @(65), @"QualityMax": @(80)};
    [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag {
    if (!flag) {
        [self.window makeKeyAndOrderFront:self];
    }
    return YES;
}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    NSInteger numberOfImagesToAdd = [_imagesController dropFiles:filenames];

    if (numberOfImagesToAdd > 0) {
        [_imagesController commitChanges];
        [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
        [self.window makeKeyAndOrderFront:self];
    }

    [sender replyToOpenOrPrint:NSApplicationDelegateReplyFailure];
}

@end
