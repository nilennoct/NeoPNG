//
//  NPImagesController.h
//  NeoPNG
//
//  Created by Neo on 13/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NPImagesController : NSArrayController <NSTableViewDelegate, NSTableViewDataSource>

- (IBAction)preview:(id)sender;

@end
