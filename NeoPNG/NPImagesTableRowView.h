//
//  NPImagesTableRowView.h
//  NeoPNG
//
//  Created by Neo on 17/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NPImageWrapper.h"

@interface NPImagesTableRowView : NSTableRowView

@property NPImageWrapper *image;

- (instancetype)initWithImage:(NPImageWrapper *)image;

@end
