//
//  CentralTools.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/19/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "CentralTools.h"
#import "ReactionImage.h"
#import "ReactionImageList.h"
#import "FileManager.h"

@implementation CentralTools

+ (void)printMessage:(NSString *)text {
    NSLog(text);
}

+ (void)copyToClipboard:(NSString *)text {
    [self printMessage:[NSString stringWithFormat:@"Copied to clipboard \"%@\".", text]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text forType:NSStringPboardType];
}

+ (BOOL)runCommand:(NSString *)command withKeyword:(NSString *)keyword {
    if ([command isEqualToString:@"gif"]) {
        FileManager *fileManager = [FileManager sharedManager];
        ReactionImageList *imageList = fileManager.imageList;
        ReactionImage *bestImage = [imageList getBestImageFromKeyword:keyword];
        if (bestImage != NULL) {
            [self printMessage:[NSString stringWithFormat:@"Found image entitled \"%@\". Copying its URL to clipboard..", bestImage.title]];
            [self copyToClipboard:bestImage.url];
            return YES;
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
    return NO;
}

@end
