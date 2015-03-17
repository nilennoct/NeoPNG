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

    return [[NPCompressOperation alloc] initWithImage:image];
}

- (instancetype)initWithImage:(NPImageWrapper *)image {
    if (self = [super init]) {
        self.image = image;
    }

    return self;
}

- (void)main {
    @autoreleasepool {
        NSString *outputPath = _image.outputPath;

        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        NSInteger qualityMin = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMin"] integerValue];
        NSInteger qualityMax = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMax"] integerValue];
        NSString *quality = [NSString stringWithFormat:@"%ld-%ld", qualityMin, qualityMax];

        NSTask *task = [NSTask new];
        task.launchPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
        task.arguments = @[@"--force", @"--quality", quality, @"--out", outputPath, @"--", _image.path];

        [task launch];
        [task waitUntilExit];

        NSError *error;
        NSInteger compressedSize = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:&error].fileSize;

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"size"] = @(compressedSize);
        if (error) {
            userInfo[@"error"] = error;
        }

        [_image performSelectorOnMainThread:@selector(taskDidFinished:) withObject:userInfo waitUntilDone:YES];
    }
}

@end
