//
//  ReactionImageList.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/15/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "ReactionImageList.h"
#import "ReactionImage.h"

@implementation ReactionImageList

// Returns the most appropriate image based on the keyword.
- (ReactionImage *) getBestImageFromKeyword:(NSString *)keyword {
    // return image with the highest keyword score, breaking ties by using the last image that set
    // the bestMatchImage
    double bestMatchScore = 0;
    ReactionImage *bestMatchImage = NULL;
    for (ReactionImage *image in self.imageList) {
        double imageScore = [image getKeywordScore:keyword];
        if (imageScore > bestMatchScore) {
            bestMatchScore = imageScore;
            bestMatchImage = image;
        }
    }
    return bestMatchImage;
}

// Returns a string that lists the info for all the images in the image list.
- (NSString *) getImageListInfo
{
    NSMutableString *info = [[NSMutableString alloc] init];
    for (ReactionImage *image in self.imageList) {
        NSString *imageInfo = [image getInfo];
        [info appendString:[NSString stringWithFormat:@"%@\n", imageInfo]];
    }
    return info;
}

@end
