//
//  TextInputWindowController.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "TextInputWindowController.h"
#import "AppDelegate.h"
#import "ReactionImage.h"
#import "ReactionImageList.h"
#import "FileManager.h"

@interface TextInputWindowController ()

@end

@implementation TextInputWindowController

- (void)windowDidLoad {
    [super windowDidLoad];
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)printMessage:(NSString *)text
{
    NSLog(text);
}

- (IBAction)searchEntered:(id)sender {
    NSSearchField *searchField = sender;
    NSString *searchString = [searchField stringValue]; // or self.searchField
    NSArray *searchStringTerms = [searchString componentsSeparatedByString:@" "];
    if ([searchStringTerms count] == 1) {
        if ([searchString length] == 0) {
            // this case happens when the search field is modified to be empty (for some reason)
        } else if ([searchString isEqualToString:@"help"]) {
            NSMutableString *helpMessage = [NSMutableString stringWithFormat:@"Commands:" ];
            [helpMessage appendString:[NSString stringWithFormat:@"\n\"gif <keyword>\" to copy the URL of a reaction image, like \"gif nope\""]];
            [helpMessage appendString:[NSString stringWithFormat:@"\n\"list gif\" to list all reaction images"]];
            [self printMessage:helpMessage];
        } else {
            [self printMessage:[NSString stringWithFormat:@"I don\'t know how to process search string \"%@\".", searchString]];
        }
    } else if ([searchStringTerms count] == 2) {
        NSString *command = searchStringTerms[0];
        NSString *keyword = searchStringTerms[1];
        [self printMessage:[NSString stringWithFormat:@"Attempting to run command \"%@\" with keyword \"%@\".",
                            command, keyword]];
        [self runCommand:command withKeyword:keyword];
    } else {
        [self printMessage:[NSString stringWithFormat:@"I don\'t know how to process search string \"%@\".", searchString]];
    }
}

- (void)copyToClipboard:(NSString *)text {
    [self printMessage:[NSString stringWithFormat:@"Copied to clipboard \"%@\".", text]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text forType:NSStringPboardType];
}

- (void)runCommand:(NSString *)command withKeyword:(NSString *)keyword {
    if ([command isEqualToString:@"gif"]) {
        FileManager *fileManager = [FileManager sharedManager];
        ReactionImageList *imageList = fileManager.imageList;
        ReactionImage *bestImage = [imageList getBestImageFromKeyword:keyword];
        if (bestImage != NULL) {
            [self printMessage:[NSString stringWithFormat:@"Found image entitled \"%@\". Copying its URL to clipboard..", bestImage.title]];
            [self copyToClipboard:bestImage.url];
            // now that we've served our purpose, close the window and restore focus
            [self close];
            AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
            [appDelegate restorePreviousApplication];
        } else {
            NSLog(@"Could not find image.");
        }
    } else if ([command isEqualToString:@"list"]) {
        if ([keyword isEqualToString:@"gif"]) {
            FileManager *fileManager = [FileManager sharedManager];
            ReactionImageList *imageList = fileManager.imageList;
            [self printMessage:[imageList getImageListInfo]];
        } else {
            [self printMessage:[NSString stringWithFormat:@"I don\'t know how to list \"%@\".", keyword]];
        }
    } else {
        [self printMessage:[NSString stringWithFormat:@"Could not find command \"%@\", which was given with keyword \"%@\".",
                            command, keyword]];
    }
}

@end
