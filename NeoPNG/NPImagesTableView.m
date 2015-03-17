//
//  NPImagesTableView.m
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesTableView.h"
#import "NPImagesController.h"
#import "NPImageWrapper.h"

@implementation NPImagesTableView

- (void)awakeFromNib {
    self.doubleAction = @selector(preview:);
}

- (void)preview:(id)sender {

    if (self.clickedRow >= 0) {
        NPImagesController *imagesController = (NPImagesController *)self.delegate;
        NPImageWrapper *image = imagesController.arrangedObjects[self.clickedRow];

        [[NSWorkspace sharedWorkspace] openFile:[image.outputURL path]];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (IBAction)openDocument:(id)sender {
    [(NPImagesController *)self.delegate add:sender];
}

- (IBAction)copy:(id)sender {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    [pboard clearContents];
    NPImagesController *imagesController = (NPImagesController *)self.delegate;
    NSArray *imagesToCopy = imagesController.selectedObjects;

    [pboard writeObjects:imagesToCopy];
}

- (IBAction)paste:(id)sender {
    NSPasteboard *pboard = [NSPasteboard generalPasteboard];
    NSArray *copiedImages = [pboard readObjectsForClasses:@[[NSURL class]] options:nil];
    if ([copiedImages count] == 0) {
        return;
    }

    NSMutableArray *pathOfCopiedImages = [NSMutableArray arrayWithCapacity:[copiedImages count]];
    for (NSURL *URL in copiedImages) {
        if ([URL path] != nil) {
            [pathOfCopiedImages addObject:[URL path]];
        }
    }

    NPImagesController *imagesController = (NPImagesController *)self.delegate;
    NSInteger numberOfImagesToAdd = [imagesController dropFiles:pathOfCopiedImages];
    if (numberOfImagesToAdd > 0) {
        [imagesController commitChanges];
    }
}

- (IBAction)delete:(id)sender {
    [(NPImagesController *)self.delegate remove:sender];
}

- (IBAction)clear:(id)sender {
    [(NPImagesController *)self.delegate clear:sender];
}

@end
