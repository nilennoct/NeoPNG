//
//  NPCompressOperation.m
//  NeoPNG
//
//  Created by Neo He on 17/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPCompressOperation.h"
#import "NPImageWrapper.h"

@implementation NPCompressOperation

+ (instancetype)operationWithImage:(NPImageWrapper *)image {
    if (image == nil) {
        return nil;
    }

    return [[self.class alloc] initWithImage:image];
}

- (instancetype)initWithImage:(NPImageWrapper *)image {
    if (self = [super init]) {
        self.image = image;
    }

    return self;
}

@end
