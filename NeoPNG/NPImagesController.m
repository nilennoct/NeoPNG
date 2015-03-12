//
//  NPImagesController.m
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesController.h"
#import "NPImageWrapper.h"

@implementation NPImagesController

- (IBAction)preview:(id)sender {
    NSButton *button = sender;
    NSString *path = [(NPImageWrapper *)[(NSTableCellView *)button.superview objectValue] path];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    [tableView setDropRow:[tableView numberOfRows] dropOperation:NSTableViewDropAbove];

    return NSDragOperationEvery;
}

- (BOOL) tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray *images = [NSMutableArray array];
        for (NSString *path in files) {
            if ([[path pathExtension] isEqualToString:@"png"]) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
                if (image != nil && [self.arrangedObjects indexOfObject:image] == NSNotFound) {
                    [images addObject:image];
                }
            }
        }

        if ([images count] > 0) {
            [self addObjects:images];
        }
    }

    return YES;
}

@end
