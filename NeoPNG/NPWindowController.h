//
//  NPWindowController.h
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NPImagesController.h"
#import "NPImagesTableView.h"
#import "NPDragView.h"

@interface NPWindowController : NSWindowController

@property (weak) IBOutlet NPImagesController *imagesController;
@property (weak) IBOutlet NPImagesTableView *imagesTableView;
@property (weak) IBOutlet NPDragView *dragView;

- (IBAction)addFiles:(id)sender;
- (IBAction)removeFiles:(id)sender;
- (IBAction)clearFiles:(id)sender;

@end
