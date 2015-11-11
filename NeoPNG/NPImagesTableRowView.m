//
//  NPImagesTableRowView.m
//  NeoPNG
//
//  Created by Neo on 17/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImagesTableRowView.h"

@implementation NPImagesTableRowView

- (instancetype)initWithImage:(NPImageWrapper *)image {
    if (self = [super init]) {
        self.image = image;
    }

    return self;
}

- (NSBackgroundStyle)interiorBackgroundStyle {
    return NSBackgroundStyleRaised;
}

- (NSColor *)backgroundColor {
    if (self.image.failed) {
        return [NSColor colorWithRed:242.0/255 green:222.0/255 blue:222.0/255 alpha:1.0];
    }

    if (self.selected) {
        return [NSColor colorWithRed:231.0/255 green:240.0/255 blue:251.0/255 alpha:1.0];
    }

    return [(NSTableView *)self.superview backgroundColor];
}

-(void)drawBackgroundInRect:(NSRect)dirtyRect {
    NSColor *backgroundColor = self.backgroundColor;

    [backgroundColor setFill];
    NSRectFill(dirtyRect);
}

- (void)drawSelectionInRect:(NSRect)dirtyRect {
    NSRect leadingBorder = NSMakeRect(0, 0, 4, NSHeight(self.frame));
    NSColor *borderColor;

    if (self.image.failed) {
        borderColor = [NSColor colorWithRed:217.0/255 green:83.0/255 blue:79.0/255 alpha:1.0];
    }
    else {
        borderColor = [NSColor colorWithRed:74.0/255 green:144.0/255 blue:226.0/255 alpha:1.0];
    }

    [borderColor setFill];
    NSRectFill(NSIntersectionRect(dirtyRect, leadingBorder));
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];

}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"failed"]) {
        self.needsDisplay = YES;
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
