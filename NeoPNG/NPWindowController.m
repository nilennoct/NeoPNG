//
//  NPWindowController.m
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPWindowController.h"
#import "NPImageWrapper.h"

@interface NPWindowController ()

@end

@implementation NPWindowController

- (void)awakeFromNib {
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.movableByWindowBackground = YES;
    self.windowFrameAutosaveName = @"MainWindow";
    self.window.level = NSFloatingWindowLevel;
//    self.window.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
}


- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)openPreference:(id)sender {
    [self.window beginSheet:self.preferenceWindowController.window completionHandler:^(NSModalResponse returnCode) {
    }];
}

@end
