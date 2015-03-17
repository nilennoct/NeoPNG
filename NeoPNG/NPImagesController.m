//
//  NPImagesController.m
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesController.h"
#import "NPImageWrapper.h"
#import "NPCompressOperation.h"

@implementation NPImagesController {
    NSMutableArray *_tStorage;

    NSOperationQueue *_queue;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _tStorage = [NSMutableArray array];

        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 1;
    }

    return self;
}

- (void)awakeFromNib {
    [_imagesTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [_imagesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (BOOL)isEmpty {
    return [self.arrangedObjects count] == 0;
}

- (NSInteger)dropFiles:(NSArray *)files {
    _tStorage = [NSMutableArray arrayWithCapacity:[files count]];

    @autoreleasepool {
        for (NSString *path in files) {
            if ([[path pathExtension] isEqualToString:@"png"]) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
                [self pushObject:image];
            }
        }
    }

    return [_tStorage count];
}

- (void)pushObject:(id)object {
    if (object != nil && [self.arrangedObjects indexOfObject:object] == NSNotFound) {
        [_tStorage addObject:object];
    }
}

- (NSInteger)commitChanges {
    NSInteger count = [_tStorage count];

    if (count > 0) {
        [_tStorage enumerateObjectsUsingBlock:^(NPImageWrapper *obj, NSUInteger idx, BOOL *stop) {
//            [obj startTask];
            [_queue addOperation:[NPCompressOperation operationWithImage:obj]];
        }];

        [self addObjects:_tStorage];
        [_tStorage removeAllObjects];
    }

    return count;
}

- (void)revertChanges {
    [_tStorage removeAllObjects];
}

- (IBAction)preview:(id)sender {
    NSButton *button = sender;
    NSString *path = [(NPImageWrapper *)[(NSTableCellView *)button.superview objectValue] path];
    [[NSWorkspace sharedWorkspace] openFile:path];
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation {
    if ([[info draggingSource] isEqualTo:_imagesTableView]) {
        return NSDragOperationNone;
    }

    NSPasteboard *pboard = [info draggingPasteboard];

    if ([pboard.types containsObject:NSFilenamesPboardType]) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];

        NSInteger numberOfImagesToAdd = [self dropFiles:files];

        if (numberOfImagesToAdd > 0) {
            [tableView setDropRow:[tableView numberOfRows] dropOperation:NSTableViewDropAbove];
            return NSDragOperationGeneric;
        }
    }

    return NSDragOperationNone;
}

- (BOOL)tableView:(NSTableView *)tableView acceptDrop:(id<NSDraggingInfo>)info row:(NSInteger)row dropOperation:(NSTableViewDropOperation)dropOperation {
    NSPasteboard *pboard = [info draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];

        NSInteger numberOfImagesToAdd = [self dropFiles:files];

        if (numberOfImagesToAdd == 0) {
            return NO;
        }

        [self commitChanges];
    }

    return YES;
}

- (id<NSPasteboardWriting>)tableView:(NSTableView *)tableView pasteboardWriterForRow:(NSInteger)row {
    return self.arrangedObjects[row];
}

- (void)removeWithFile {
    NSArray *selectedImages = self.selectedObjects;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    for (NPImageWrapper *image in selectedImages) {
        [fileManager removeItemAtURL:image.outputURL error:&error];
        if (error != nil) {
            NSLog(@"Error when removing image: %@, %@", image.path, error);
            error = nil;
        }
    }

    [self removeObjectsAtArrangedObjectIndexes:self.selectionIndexes];
}

#pragma mark IBAction

- (IBAction)add:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = NO;
    panel.allowedFileTypes = @[@"png"];

    [panel beginSheetModalForWindow:self.imagesTableView.window completionHandler:^(NSInteger result) {
        if (result == NSFileHandlingPanelOKButton) {
            NSArray *URLs = [panel URLs];

            for (NSURL *URL in URLs) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:URL.path];
                [self pushObject:image];
            }

            [self commitChanges];
        }
    }];
}

- (IBAction)remove:(id)sender {
    [self removeObjectsAtArrangedObjectIndexes:self.selectionIndexes];
}

- (IBAction)removeWithFile:(id)sender {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    BOOL overwrite = [(NSNumber *)[defaultsController.values valueForKey:@"Overwrite"] boolValue];
    if (overwrite) {
        

        NSAlert *alert = [NSAlert new];
        [alert addButtonWithTitle:@"OK"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Delete these images?"];
        [alert setInformativeText:@"For overwriting is enabled, your original images will be deleted."];
        alert.alertStyle = NSCriticalAlertStyle;

        if ([alert runModal] != NSAlertFirstButtonReturn) {
            return;
        }
    }

    [self removeWithFile];
}

- (IBAction)clear:(id)sender {
    [self removeObjects:self.arrangedObjects];
}

@end
