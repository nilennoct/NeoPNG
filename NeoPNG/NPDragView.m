//
//  NPDragView.m
//  NeoPNG
//
//  Created by Neo He on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPDragView.h"
#import "NPImageWrapper.h"

@implementation NPDragView

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        self.highlighted = NO;
        [self unregisterDraggedTypes];
        [self registerForDraggedTypes:@[NSFilenamesPboardType, NSURLPboardType]];
    }

    return self;
}

- (void)awakeFromNib {
    [self.imageView unregisterDraggedTypes];
}


- (void)drawRect:(NSRect)dirtyRect {
    if (!self.highlighted) {
        [[NSColor colorWithCalibratedWhite:0.94 alpha:1.0] setFill];
    }
    else {
        [[NSColor whiteColor] setFill];
    }
    NSRectFill(dirtyRect);

    [super drawRect:dirtyRect];
}

- (void)updateDraggingItemsForDrag:(id<NSDraggingInfo>)sender {

}

//- (BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
//    NSPasteboard *pboard = [sender draggingPasteboard];
//    if ([pboard.types containsObject:NSFilenamesPboardType]) {
//        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
//        NSMutableArray *validFiles = [NSMutableArray array];
//
//        for (NSString *path in files) {
//            if ([[path pathExtension] isEqualToString:@"png"]) {
//                [validFiles addObject:path];
//            }
//        }
//
//        if ([validFiles count] > 0) {
//            [sender setNumberOfValidItemsForDrop:[validFiles count]];
//            [pboard setPropertyList:[NSArray arrayWithArray:validFiles] forType:NSFilenamesPboardType];
//            return YES;
//        }
//    }
//
//    return NO;
//}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
//    NSPasteboard *pboard = [sender draggingPasteboard];
//
//    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
//        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
//
//        for (NSString *path in files) {
//            if ([[path pathExtension] isEqualToString:@"png"]) {
//                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
//                [_imagesController pushObject:image];
//
//            }
//        }
//
//        NSInteger numberOfImagesAdded = [_imagesController commitChanges];
//        if (numberOfImagesAdded == 0) {
//            return NO;
//        }
//    }
    NSInteger numberOfImagesAdded = [_imagesController commitChanges];
    if (numberOfImagesAdded == 0) {
        return NO;
    }

    return YES;
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];

    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
        NSInteger numberOfImagesToAdd = [_imagesController dropFiles:files];

        [sender setNumberOfValidItemsForDrop:numberOfImagesToAdd];

        if (numberOfImagesToAdd > 0) {
            self.highlighted = YES;
            self.needsDisplay = YES;

            [self updateDraggingItemsForDrag:sender];

            return NSDragOperationGeneric;
//            return [sender draggingSourceOperationMask];
        }
    }

    return NSDragOperationNone;
}

- (void)draggingExited:(id<NSDraggingInfo>)sender {
    [_imagesController revertChanges];
    self.highlighted = NO;
    self.needsDisplay = YES;
}

- (void)draggingEnded:(id<NSDraggingInfo>)sender {
    self.highlighted = NO;
    self.needsDisplay = YES;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    return YES;
}

@end
