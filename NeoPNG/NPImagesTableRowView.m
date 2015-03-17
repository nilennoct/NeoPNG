//
//  NPImagesTableRowView.m
//  NeoPNG
//
//  Created by Neo on 17/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesTableRowView.h"

@implementation NPImagesTableRowView

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleRaised;
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSRect leadingBorder = NSMakeRect(0, 0, 4, NSHeight(self.frame));
//    [[NSColor colorWithWhite:0.93 alpha:1.0] setFill];
    [[NSColor colorWithRed:231.0/255 green:240.0/255 blue:251.0/255 alpha:1.0] setFill];
//    [[NSColor colorWithRed:241.0/255 green:247.0/255 blue:253.0/255 alpha:1.0] setFill];
    NSRectFill(dirtyRect);
        //    [[NSColor darkGrayColor] setFill];
        //    [[NSColor colorWithRed:43.0/255 green:84.0/255 blue:132.0/255 alpha:1.0] setFill];
    [[NSColor colorWithRed:74.0/255 green:144.0/255 blue:226.0/255 alpha:1.0] setFill];
    NSRectFill(NSIntersectionRect(dirtyRect, leadingBorder));
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
