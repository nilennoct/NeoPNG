//
//  NPCompressOperation.h
//  NeoPNG
//
//  Created by Neo He on 17/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NPImageWrapper;

@interface NPCompressOperation : NSOperation

@property (weak) NPImageWrapper *image;

+ (instancetype)operationWithImage:(NPImageWrapper *)image;

- (instancetype)initWithImage:(NPImageWrapper *)image;

@end
