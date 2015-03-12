//
//  NPImagesTableView.m
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesTableView.h"

@implementation NPImagesTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

//- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender {
//    NSPasteboard *pboard = [sender draggingPasteboard];
//
//    if ( [[pboard types] containsObject:NSFilenamesPboardType] ) {
//        NSArray *files = [pboard propertyListForType:NSFilenamesPboardType];
//        for (NSString *path in files) {
//            if ([[path pathExtension] isEqualToString:@"png"]) {
//
//            }
//        }
//    }
//    return YES;
//}

@end
