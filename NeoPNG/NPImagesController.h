//
//  NPImagesController.h
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NPImagesTableView.h"

@interface NPImagesController : NSArrayController <NSTableViewDelegate, NSTableViewDataSource>

@property (weak) IBOutlet NPImagesTableView *imagesTableView;

@property (readonly, getter=isEmpty) BOOL empty;
@property NSString *test;

- (NSInteger)dropFiles:(NSArray *)files;
- (void)pushObject:(id)object;
- (NSInteger)commitChanges;
- (void)revertChanges;

- (IBAction)removeWithFile:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)recompress:(id)sender;

@end
