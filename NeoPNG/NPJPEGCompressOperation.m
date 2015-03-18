//
//  NPJPEGCompressOperation.m
//  NeoPNG
//
//  Created by Neo He on 18/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPJPEGCompressOperation.h"
#import "NPImageWrapper.h"

@implementation NPJPEGCompressOperation

- (void)main {
//    NSData *imageData = [NSData dataWithContentsOfFile:self.image.path];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:self.image.path];
    NSBitmapImageRep *imageRep = [image representations][0];

    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
    NSInteger qualityMax = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMax"] integerValue];

    NSData *imageDataCompressed = [imageRep representationUsingType:NSJPEGFileType properties:@{NSImageCompressionFactor: @(qualityMax / 100.0)}];

    NSString *outputPath = self.image.outputPath;
    [[NSFileManager defaultManager] createFileAtPath:outputPath contents:imageDataCompressed attributes:nil];
//    BOOL writeSuccess = [imageDataCompressed writeToFile:outputPath atomically:YES];
//    NSLog(@"write status: %d", writeSuccess);

    NSError *error;
    NSInteger compressedSize = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:&error].fileSize;

    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    userInfo[@"size"] = @(compressedSize);
    if (error) {
        userInfo[@"error"] = error;
    }

    [self.image performSelectorOnMainThread:@selector(taskDidFinished:) withObject:userInfo waitUntilDone:YES];
}

@end
