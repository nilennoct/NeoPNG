//
//  NPImagesController.m
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesController.h"
#import "NPImageWrapper.h"

@implementation NPImagesController {
    NSMutableArray *_tStorage;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        _tStorage = [NSMutableArray array];
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

    for (NSString *path in files) {
        if ([[path pathExtension] isEqualToString:@"png"]) {
            NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
            [self pushObject:image];
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
            [obj startTask];
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

//- (BOOL)tableView:(NSTableView *)tableView writeRowsWithIndexes:(NSIndexSet *)rowIndexes toPasteboard:(NSPasteboard *)pboard {
//
//    return YES;
//
//    NSArray *imagesSelected = [self.arrangedObjects objectsAtIndexes:rowIndexes];
//    NSMutableArray *filesToDrag = [NSMutableArray arrayWithCapacity:[imagesSelected count]];
//
//    for (NPImageWrapper *image in imagesSelected) {
//        if (YES || image.compressed) {
//            [filesToDrag addObject:image.outputPath];
//        }
//    }
//
//    if ([filesToDrag count] > 0) {
//        [pboard declareTypes:@[NSFilenamesPboardType] owner:nil];
//        [pboard setPropertyList:filesToDrag forType:NSFilenamesPboardType];
//
//        return YES;
//    }
//
//    return NO;
//}


@end
