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
    [self.imagesTableView registerForDraggedTypes:@[(NSString *)kUTTypeFileURL]];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)addFiles:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = NO;
    panel.allowedFileTypes = @[@"png"];

    [panel beginSheetModalForWindow:self.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *URLs = [panel URLs];

            for (NSURL *URL in URLs) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:URL.path];
                [self.imagesController pushObject:image];
            }

            [self.imagesController commitChanges];
        }
    }];
}

- (IBAction)removeFiles:(id)sender {
    [self.imagesController removeObjectsAtArrangedObjectIndexes:self.imagesController.selectionIndexes];
}

- (IBAction)clearFiles:(id)sender {
    [self.imagesController removeObjects:self.imagesController.arrangedObjects];
}

@end
