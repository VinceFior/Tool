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
    
    // tell the AppDelegate what our text field is
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    appDelegate.outputTextView = self.textView;
}

- (IBAction)searchEntered:(id)sender {
    NSSearchField *searchField = sender;
    NSString *searchString = [searchField stringValue]; // or self.searchField
    NSArray *searchStringTerms = [searchString componentsSeparatedByString:@" "];
    if ([searchString length] == 0) {
        // this case happens when the search field is modified to be empty (for some reason)
    } else if ([searchStringTerms count] >= 1) {
        NSString *command = searchStringTerms[0];
        // the "keyword" is allowed to be more than one (space-separated) word
        NSString *keyword = @"";
        if ([searchStringTerms count] > 1) {
            keyword = [searchString substringFromIndex:[command length] + 1];
        }
        [CentralTools logMessage:[NSString stringWithFormat:@"Attempting to run command \"%@\" with keyword \"%@\".",
                            command, keyword]];
        CommandReturn commandReturn = [CentralTools runCommand:command withKeyword:keyword];
        if (commandReturn != CommandReturnNothing) {
            // now that we've served our purpose, close the window and restore focus, if appropriate
            // TODO: prevent application from appearing on alt+tab application switcher
            [self close];
            if (commandReturn == CommandReturnCloseReopen) {
                AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
                [appDelegate restorePreviousApplication];
            }
        }
    } else {
        [CentralTools printMessage:[NSString stringWithFormat:@"I don\'t know how to process search string \"%@\".", searchString]];
    }
}

@end
