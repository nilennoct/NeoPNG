//
//  NPPNGCompressOperation.m
//  NeoPNG
//
//  Created by Neo He on 18/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPPNGCompressOperation.h"
#import "NPImageWrapper.h"

@implementation NPPNGCompressOperation

- (void)main {
    @autoreleasepool {
        NSString *outputPath = self.image.outputPath;

        NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];
        NSInteger qualityMin = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMin"] integerValue];
        NSInteger qualityMax = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMax"] integerValue];
        NSString *quality = [NSString stringWithFormat:@"%ld-%ld", qualityMin, qualityMax];

        NSTask *task = [NSTask new];
        task.launchPath = [[NSBundle mainBundle] pathForResource:@"pngquant" ofType:nil];
        task.arguments = @[@"--force", @"--quality", quality, @"-v", @"--out", outputPath, @"--", self.image.path];

        NSPipe *pipe = [NSPipe pipe];
        [task setStandardError:pipe];

        NSFileHandle *reader = [pipe fileHandleForReading];

        [task launch];
        [task waitUntilExit];

        NSData *data = [reader readDataToEndOfFile];
        NSString *outputString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

//        NSLog(@"output: %@", outputString);

        NSError *error = nil;
        NSUInteger compressedSize = 0;

        if (outputString != nil && outputString.length > 0) {
            NSString *patter = @"MSE[^(]+\\(Q=([0-9]+)\\)([^(\n]+\\([0-9]+\\))?";
            NSRegularExpression *resultTestRegexp = [NSRegularExpression regularExpressionWithPattern:patter options:0 error:&error];
            NSArray *result = [resultTestRegexp matchesInString:outputString options:0 range:NSMakeRange(0, [outputString length])];

            if (error == nil && [result count] > 0) {
                for (NSTextCheckingResult *match in result) {
                    NSRange qualityRange = [match rangeAtIndex:1];
                    self.image.quality = [outputString substringWithRange:qualityRange];

                    NSRange lastRange = [match rangeAtIndex:match.numberOfRanges - 1];
                    if (lastRange.length > 0) {
                        NSLog(@"Third component: %@", [outputString substringWithRange:lastRange]);
                        error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil];
                    }
                    else {
                        compressedSize = [[NSFileManager defaultManager] attributesOfItemAtPath:outputPath error:&error].fileSize;
                    }

                    break;
                }
            }
            else {
                if (error == nil) {
                    error = [NSError errorWithDomain:NSPOSIXErrorDomain code:EIO userInfo:nil];
                }
            }
        }

        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        userInfo[@"size"] = @(compressedSize);
        if (error) {
            userInfo[@"error"] = error;
        }

        [self.image performSelectorOnMainThread:@selector(taskDidFinished:) withObject:userInfo waitUntilDone:YES];
    }
}

@end
