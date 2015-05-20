//
//  TextInputWindowController.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "TextInputWindowController.h"
#import "CentralTools.h"
#import "AppDelegate.h"

@interface TextInputWindowController ()

@end

@implementation TextInputWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)searchEntered:(id)sender {
    NSSearchField *searchField = sender;
    NSString *searchString = [searchField stringValue]; // or self.searchField
    NSArray *searchStringTerms = [searchString componentsSeparatedByString:@" "];
    if ([searchStringTerms count] == 1) {
        if ([searchString length] == 0) {
            // this case happens when the search field is modified to be empty (for some reason)
        } else if ([searchString isEqualToString:@"help"]) {
            [CentralTools printHelpMessage];
        } else {
            [CentralTools printMessage:[NSString stringWithFormat:@"I don\'t know how to process search string \"%@\".", searchString]];
        }
    } else if ([searchStringTerms count] >= 2) {
        NSString *command = searchStringTerms[0];
        // the "keyword" is allowed to be more than one (space-separated) word
        NSString *keyword = [searchString substringFromIndex:[command length] + 1];
        [CentralTools printMessage:[NSString stringWithFormat:@"Attempting to run command \"%@\" with keyword \"%@\".",
                            command, keyword]];
        BOOL shouldClose = [CentralTools runCommand:command withKeyword:keyword];
        if (shouldClose) {
            // now that we've served our purpose, close the window and restore focus
            // TODO: prevent application from appearing on alt+tab application switcher
            [self close];
            AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
            [appDelegate restorePreviousApplication];
        }
    } else {
        [CentralTools printMessage:[NSString stringWithFormat:@"I don\'t know how to process search string \"%@\".", searchString]];
    }
}

@end
