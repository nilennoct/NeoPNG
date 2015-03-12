//
//  NPSizeFormatter.m
//  NeoPNG
//
//  Created by Neo on 12/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPSizeFormatter.h"

@implementation NPSizeFormatter

- (NSString *)stringForObjectValue:(NSNumber *)obj {
    float size = [obj floatValue];
    NSArray *exts = @[@"B", @"KB", @"MB", @"GB"];
    NSInteger count = 0;
    while (size >= 1024) {
        size /= 1024;
        count++;
    }

    return [NSString stringWithFormat:@"%2f%@", size, exts[count]];
}

@end
