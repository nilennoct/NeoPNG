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
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender {
    return YES;
}
//
//- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
//    NSLog(@"%@", filename);
//    return YES;
//}

- (void)application:(NSApplication *)sender openFiles:(NSArray *)filenames {
    NSLog(@"%@", filenames);
    NSInteger numberOfImagesToAdd = [_imagesController dropFiles:filenames];

    if (numberOfImagesToAdd > 0) {
        [_imagesController commitChanges];
        [sender replyToOpenOrPrint:NSApplicationDelegateReplySuccess];
    }

    [sender replyToOpenOrPrint:NSApplicationDelegateReplyFailure];
}

@end
