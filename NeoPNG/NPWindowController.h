//
//  NPWindowController.h
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NPImagesTableView.h"

@interface NPWindowController : NSWindowController

@property (weak) IBOutlet NSArrayController *imagesController;
@property (weak) IBOutlet NPImagesTableView *imagesTableView;

- (IBAction)addFiles:(id)sender;
- (IBAction)removeFiles:(id)sender;
- (IBAction)clearFiles:(id)sender;

@end
