//
//  NPImage.m
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPImageWrapper.h"
#import "NPPNGCompressOperation.h"
#import "NPJPEGCompressOperation.h"

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

- (void)taskDidFinished:(NSDictionary *)userInfo {
    [self willChangeValueForKey:@"reduced"];

    BOOL hasError = userInfo[@"error"] != nil;
    if (hasError) {
        NSLog(@"Error when execute compress task, filename: %@, error info: %@", _filename, userInfo[@"error"]);

        NSAlert *alert = [[NSAlert alloc] init];
        alert.alertStyle = NSCriticalAlertStyle;
        alert.messageText = NSLocalizedString(@"CompressFailTitle", @"Compression failed");
        alert.informativeText = NSLocalizedString(@"CompressFailText", @"Message when compression failed.");

        [alert runModal];

        self.compressedSize = 0;
    }
    else {
        self.compressedSize = [(NSNumber *)userInfo[@"size"] integerValue];
    }

    if (hasError != _failed) {
        self.failed = hasError;
    }

    self.compressed = YES;
    [self didChangeValueForKey:@"reduced"];
}

- (NSString *)quality {
    return _quality ? [NSString stringWithFormat:@"(Q=%@)", _quality] : nil;
}

- (NPCompressOperation *)operation {
    if (!_compressed) {
        if (_operation != nil && !_operation.finished) {
            [_operation cancel];
        }

        if ([[[_filename pathExtension] lowercaseString] isEqualToString:@"jpg"]) {
            _operation = [NPJPEGCompressOperation operationWithImage:self];
        }
        else {
            _operation = [NPPNGCompressOperation operationWithImage:self];
        }
    }

    return _operation;
}

- (NSNumber *)reduced {
    if (!_compressed || _failed) {
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

        if (![self checkDirectory:prefix]) {
            prefix = [prefix stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
        }

        NSString *ouputFilename = [[NSString stringWithFormat:@"%@%@%@", prefix, [_filename stringByDeletingPathExtension], suffix] stringByAppendingPathExtension:[_filename pathExtension]];
        NSString *outputPath = [[_path stringByDeletingLastPathComponent] stringByAppendingPathComponent:ouputFilename];

        _outputURL = [NSURL fileURLWithPath:outputPath];

        return outputPath;
    }
    else {
        _outputURL = [NSURL fileURLWithPath:_path];

        return _path;
    }
}

- (BOOL)checkDirectory:(NSString *)prefix {
    NSRange range = [prefix rangeOfString:@"/" options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return YES;
    }

    prefix = [prefix substringToIndex:range.location];
    NSString *directoryPath = [[_path stringByDeletingLastPathComponent] stringByAppendingPathComponent:prefix];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    BOOL isDirectory = YES;
    if (![fileManager fileExistsAtPath:directoryPath isDirectory:&isDirectory]) {
        [self createDirectory:directoryPath];
        return YES;
    }

    if (!isDirectory) {
        return NO;
    }
    
    return YES;
}

- (BOOL)createDirectory:(NSString *)directoryPath {
    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:YES attributes:nil error:&error]) {
        NSLog(@"Error when creating output directory, %@", error);
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
