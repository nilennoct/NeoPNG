//
//  NPImage.h
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NPImageWrapper : NSObject <NSPasteboardWriting>

@property NSString *path;

@property NSString *filename;
@property NSInteger originalSize;
@property NSInteger compressedSize;

@property (readonly) NSNumber *reduced;

@property BOOL compressed;

@property (readonly) NSString *outputPath;
@property (readonly) NSURL *outputURL;

//@property (readonly) NPCompressOperation *operation;

@property NSTask *task;

- (instancetype)initWithPath:(NSString *)path;

- (void)startTask;

@end
