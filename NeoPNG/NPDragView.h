//
//  NPDragView.h
//  NeoPNG
//
//  Created by Neo He on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NPImagesController.h"

@interface NPDragView : NSView {
    __weak IBOutlet NPImagesController *_imagesController;
}

@property (weak) IBOutlet NSImageView *imageView;

@property BOOL highlighted;



@end
