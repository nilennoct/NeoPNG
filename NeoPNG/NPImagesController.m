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

- (void)pushObject:(id)object {
    if (object != nil && [self.arrangedObjects indexOfObject:object] == NSNotFound) {
        [_tStorage addObject:object];
    }
}

- (void)commitChanges {
    if ([_tStorage count] > 0) {
        [_tStorage enumerateObjectsUsingBlock:^(NPImageWrapper *obj, NSUInteger idx, BOOL *stop) {
            [obj startTask];
        }];

        [self addObjects:_tStorage];
        [_tStorage removeAllObjects];
    }
}

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

        for (NSString *path in files) {
            if ([[path pathExtension] isEqualToString:@"png"]) {
                NPImageWrapper *image = [[NPImageWrapper alloc] initWithPath:path];
                [self pushObject:image];

            }
        }

        [self commitChanges];
    }

    return YES;
}

@end
