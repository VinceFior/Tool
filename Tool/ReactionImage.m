//
//  ReactionImage.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "ReactionImage.h"

@implementation ReactionImage

// Returns a number from 0.0 to 1.0 indicating the relevance score of the given keyword.
- (double) getKeywordScore:(NSString *)keyword {
    //TODO: Use a better similarity metric than simple, boolean substring.
    if ([[self.title lowercaseString] containsString:[keyword lowercaseString]]) {
        return 1.0;
    } else {
        return 0.0;
    }
}

// Returns a string representing the important information about this image.
- (NSString *) getInfo {
    NSString *typeString;
    if (self.imageType == ReactionImageTypeStatic) {
        typeString = @"static";
    } else if (self.imageType == ReactionImageTypeAnimated) {
        typeString = @"animated";
    } else if (self.imageType == ReactionImageTypeYouTube) {
        typeString = @"video";
    } else {
        typeString = @"unknown";
    }
    return [NSString stringWithFormat:@"Title: \"%@\", type: \"%@\", url: \"%@\".",
            self.title, typeString, self.url];
}

@end
