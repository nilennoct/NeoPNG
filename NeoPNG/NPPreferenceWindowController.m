//
//  NPPreferenceViewController.m
//  NeoPNG
//
//  Created by Neo He on 16/3/15.
//  Copyright (c) 2015 Neo He. All rights reserved.
//

#import "NPPreferenceWindowController.h"

@interface NPPreferenceWindowController () {
    NSNumberFormatter *_formatter;
    BOOL _originalOverwite;
}

@end

@implementation NPPreferenceWindowController

- (instancetype)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        _formatter = [NSNumberFormatter new];
        _formatter.allowsFloats = NO;
    }

    return self;
}
//
//- (void)cancelOperation:(id)sender {
//    [self dismissController:sender];
//}

-(void)windowWillDisplay {
    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

    _originalOverwite = [(NSNumber *)[defaultsController.values valueForKey:@"Overwrite"] boolValue];
}

- (IBAction)dismissController:(id)sender {
    [self.window makeFirstResponder:nil];

    NSUserDefaultsController *defaultsController = [NSUserDefaultsController sharedUserDefaultsController];

    BOOL overwrite = [(NSNumber *)[defaultsController.values valueForKey:@"Overwrite"] boolValue];
    if (overwrite && !_originalOverwite) {
        NSAlert *alert = [NSAlert new];
        alert.alertStyle = NSCriticalAlertStyle;
        [alert setMessageText:NSLocalizedString(@"OverwriteConfirmTitle", nil)];
        [alert setInformativeText:NSLocalizedString(@"OverwriteConfirmText", nil)];
        [alert runModal];
    }

    NSInteger qualityMin = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMin"] integerValue];
    NSInteger qualityMax = [(NSNumber *)[defaultsController.values valueForKey:@"QualityMax"] integerValue];

    if (qualityMin < 0 || qualityMin > qualityMax) {
        [self.window makeFirstResponder:[self.window.contentView viewWithTag:3]];
        return;
    }
    if (qualityMax > 100) {
        [self.window makeFirstResponder:[self.window.contentView viewWithTag:4]];
        return;
    }

    [super dismissController:sender];

    [self.window.sheetParent endSheet:self.window returnCode:NSModalResponseOK];
}

- (BOOL)control:(NSControl *)control textShouldEndEditing:(NSText *)fieldEditor {
    NSString *valString = fieldEditor.string;

    if (control.tag == 2) {
        if ([valString rangeOfString:@"/"].location != NSNotFound) {
            return NO;
        }
    }
    else if (control.tag >= 3) {
        NSNumber *val = [_formatter numberFromString:valString];
        if (val == nil) {
            return NO;
        }
    }

    return YES;
}

- (NSArray *)control:(NSControl *)control textView:(NSTextView *)textView completions:(NSArray *)words forPartialWordRange:(NSRange)charRange indexOfSelectedItem:(NSInteger *)index {
    return nil;
}

@end
