//
//  NPImage.h
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NPImageWrapper : NSObject

@property NSString *path;

@property NSString *filename;
@property NSInteger originalSize;
@property NSInteger compressedSize;

@property (readonly) NSNumber *reduced;

@property (readonly) BOOL compressed;

@property NSTask *task;

- (instancetype)initWithPath:(NSString *)path;

- (void)startTask;

@end
