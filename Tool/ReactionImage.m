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
    if ([self.title containsString:keyword]) {
        return 1.0;
    } else {
        return 0.0;
    }
}

// Returns a string representing the important information about this image.
- (NSString *) getInfo {
    NSString *animatedString = @"no";
    if (self.animated) {
        animatedString = @"yes";
    }
    return [NSString stringWithFormat:@"Title: \"%@\", animated: \"%@\", url: \"%@\".",
            self.title, animatedString, self.url];
}

@end
