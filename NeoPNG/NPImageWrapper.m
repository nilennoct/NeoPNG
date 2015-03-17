//
//  NPImage.m
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImageWrapper.h"

static const NSString *defaultPrefix = @"out/";

@implementation NPImageWrapper

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) {
        NSError *error = nil;
        _originalSize = [[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error].fileSize;
        if (error != nil) {
            NSLog(@"Error when reading image size, %@", error);
            return nil;
        }
        _path = path;
        _filename = [_path lastPathComponent];
        _compressed = NO;
    }

    return self;
}

- (void)startTask {
    @autoreleasepool {
            //    NSPipe *pipe = [NSPipe pipe];
            //    NSFileHandle *file = pipe.fileHandleForReading;

            //    NSString *ext = @".out.png";
        NSString *outputPath = self.outputPath;

        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        NSInteger qualityMin = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMin"] integerValue];
        NSInteger qualityMax = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMax"] integerValue];
        NSString *quality = [NSString stringWithFormat:@"%ld-%ld", qualityMin, qualityMax];

        _task = [[NSTask alloc] init];
        _task.launchPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
        _task.arguments = @[@"--force", @"--quality", quality, @"--out", outputPath, @"--", _path];

        dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
        dispatch_async(taskQueue, ^{
            [_task launch];

            [_task waitUntilExit];

                //        NSData *data = [file readDataToEndOfFile];
                //        [file closeFile];

                //        NSLog(@"pngquant %@: %@", _path, [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);

            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                self.compressedSize = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:&error].fileSize;
                if (error != nil) {
                    NSLog(@"Error when reading compressed image size, %@", error);
                }
                
                [self setCompressed:YES];
                
            });
        });
    }
}

//- (void)setCompressed:(BOOL)compressed {
//    [self willChangeValueForKey:@"compressed"];
//    [self willChangeValueForKey:@"reduced"];
//
//    _compressed = compressed;
//
//    [self didChangeValueForKey:@"compressed"];
//    [self didChangeValueForKey:@"reduced"];
//}

- (NSNumber *)reduced {
    if (!_compressed) {
        return @(0);
    }

    return @((_compressedSize - _originalSize) * 1.0 / _originalSize);
}

- (NSString *)outputPath {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

    BOOL overwrite = [(NSNumber *)[defaultsController.values valueForKey:@"Overwrite"] boolValue];
    if (!overwrite) {
        NSString *prefix = [defaultsController.values valueForKey:@"Prefix"];
        NSString *suffix = [defaultsController.values valueForKey:@"Suffix"];

        if (prefix.length == 0 && suffix.length == 0) {
            prefix = [defaultPrefix copy];
        }

        if (![self createDirectory:prefix]) {
            prefix = [prefix stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        }

        NSString *ouputFilename = [[NSString stringWithFormat:@"%@%@%@", prefix, [_filename stringByDeletingPathExtension], suffix] stringByAppendingPathExtension:@"png"];
        NSString *outputPath = [[_path stringByDeletingLastPathComponent] stringByAppendingPathComponent:ouputFilename];

        _outputURL = [NSURL fileURLWithPath:outputPath];

        return outputPath;
    }
    else {
        _outputURL = [NSURL fileURLWithPath:_path];

        return _path;
    }
}

- (BOOL)createDirectory:(NSString *)prefix {
    NSRange range = [prefix rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return YES;
    }

    prefix = [prefix substringToIndex:range.location];
    NSString *directoryPath = [[_path stringByDeletingLastPathComponent] stringByAppendingPathComponent:prefix];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        NSError *error = nil;
        if (![fileManager createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
            NSLog(@"Error when creating output directory");
            return NO;
        }

        return YES;
    }
    else if (!isDirectory) {
        return NO;
    }

    return YES;
}

#pragma mark NSPasteboardWriting

- (NSPasteboardWritingOptions)writingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pasteboard {
    return [self.outputURL writingOptionsForType:type pasteboard:pasteboard];
}

- (NSArray *)writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    return [self.outputURL writableTypesForPasteboard:pasteboard];
}

- (id)pasteboardPropertyListForType:(NSString *)type {
    if (!self.compressed) {
        return nil;
    }

    return [self.outputURL pasteboardPropertyListForType:type];
}

- (BOOL)isEqual:(NPImageWrapper *)object {
    if ([super isEqual:object]) {
        return YES;
    }

    return [_path isEqualToString:object.path];
}

- (NSUInteger)hash {
    return _path.hash;
}

@end
