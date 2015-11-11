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
#import "NPImagesTableRowView.h"

@implementation NPImagesController {
    NSMutableArray *_tStorage;

    NSOperationQueue *_queue;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _tStorage = [NSMutableArray array];

        _queue = [NSOperationQueue new];
        _queue.maxConcurrentOperationCount = 10;
    }

    return self;
}

- (void)awakeFromNib {
    [_imagesTableView registerForDraggedTypes:@[NSFilenamesPboardType]];
    [_imagesTableView setDraggingSourceOperationMask:NSDragOperationCopy forLocal:NO];
}

- (BOOL)isEmpty {
    return [self.content count] == 0;
}

- (NSInteger)dropFiles:(NSArray *)files {
    _tStorage = [NSMutableArray arrayWithCapacity:[files count]];

    @autoreleasepool {
        for (NSString *path in files) {
            NSString *extension = [[path pathExtension] lowercaseString];
            if ([extension isEqualToString:@"png"] || [extension isEqualToString:@"jpg"]) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
                [self pushObject:image];
            }
        }
    }

    return [_tStorage count];
}

- (void)pushObject:(id)object {
    if (object != nil && [self.content indexOfObject:object] == NSNotFound) {
        [_tStorage addObject:object];
    }
}

- (NSInteger)commitChanges {
    NSInteger count = [_tStorage count];

    if (count > 0) {
//        NSMutableArray *operations = [NSMutableArray arrayWithCapacity:count];
        [_tStorage enumerateObjectsUsingBlock:^(NPImageWrapper *image, NSUInteger idx, BOOL *stop) {
            [_queue addOperation:image.operation];
//            [operations addObject:[NPCompressOperation operationWithImage:obj]];
        }];

//        [_queue addOperations:operations waitUntilFinished:NO];

        [self addObjects:_tStorage];
        [_tStorage removeAllObjects];
    }

    return count;
}

- (void)revertChanges {
    [_tStorage removeAllObjects];
}

- (void)removeObjects:(NSArray *)objects {
    for (NPImageWrapper *image in objects) {
        [image.operation cancel];
    }

    [super removeObjects:objects];
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

    [self removeObjects:self.selectedObjects];
        //    [self removeObjectsAtArrangedObjectIndexes:self.selectionIndexes];
}

- (NSTableRowView *)tableView:(NSTableView *)tableView rowViewForRow:(NSInteger)row {
    NPImageWrapper *image = [self.arrangedObjects objectAtIndex:row];

    return [[NPImagesTableRowView alloc] initWithImage:image];
}

- (void)tableView:(NSTableView *)tableView didAddRowView:(NPImagesTableRowView *)rowView forRow:(NSInteger)row {
    [rowView.image addObserver:rowView forKeyPath:@"failed" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

- (void)tableView:(NSTableView *)tableView didRemoveRowView:(NPImagesTableRowView *)rowView forRow:(NSInteger)row {
    [rowView.image removeObserver:rowView forKeyPath:@"failed"];
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

#pragma mark IBAction

- (IBAction)add:(id)sender {
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    panel.allowsMultipleSelection = YES;
    panel.canChooseDirectories = NO;
    panel.allowedFileTypes = @[@"png", @"jpg"];

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
    [self removeObjects:self.selectedObjects];
}

- (IBAction)removeWithFile:(id)sender {
    NSAlert *alert = [NSAlert new];
    alert.alertStyle = NSCriticalAlertStyle;
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK")];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel")];
    [alert setMessageText:NSLocalizedString(@"RemoveTitle", @"Delete these files?")];
    [alert setInformativeText:NSLocalizedString(@"RemoveText", @"The compressed files will be deleted.")];

    if ([alert runModal] != NSAlertFirstButtonReturn) {
        return;
    }

    [self removeWithFile];
}

- (IBAction)clear:(id)sender {
    [self removeObjects:self.content];
}

- (IBAction)recompress:(id)sender {
    NSTableCellView *cellView = (NSTableCellView *)[(NSButton *)sender superview];
    NPImageWrapper *image = cellView.objectValue;
    image.compressed = NO;
    [_queue addOperation:image.operation];
}

@end
