//
//  FileManager.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/16/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "FileManager.h"
#import "ReactionImage.h"
#import "ReactionImageList.h"

@implementation FileManager

+ (id)sharedManager {
    static FileManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // load data (only once per shared lifetime)
        NSString *imageFilePath = @"/Users/vincent/Desktop/image-database.txt";
        self.imageList = [self getImageList:imageFilePath];
    }
    
    return self;
}

// Returns a ReactionImageList based on the given file path root.
// Expects the given imageFile to be a CSV of the form "URL,animated,keywords".
- (ReactionImageList *) getImageList:(NSString *)imageFileRoot {
    // TODO: Improve †he flexibility of the input file and actually use CSV stuff.
    NSMutableArray *images = [[NSMutableArray alloc] init];
    
    NSString* fileContents = [NSString stringWithContentsOfFile:imageFileRoot
                                                       encoding:NSUTF8StringEncoding error:nil];
    NSArray* lines = [fileContents componentsSeparatedByCharactersInSet:
                      [NSCharacterSet newlineCharacterSet]];
    for (NSString *line in lines) {
        if ([line length] == 0) {
            continue; // mainly to handle the (potential) last newline
        }
        NSArray* data = [line componentsSeparatedByString:@","];
        NSString *url = data[0];
        NSString *imageType = data[1];
        BOOL animated = false;
        if ([imageType isEqualToString:@"animated"]) {
            animated = true;
        }
        NSString *title = data[2];
        ReactionImage *reactionImage = [[ReactionImage alloc] init];
        reactionImage.url = url;
        reactionImage.title = title;
        reactionImage.animated = animated;
        [images addObject:reactionImage];
    }
    
    ReactionImageList *imageList = [[ReactionImageList alloc] init];
    imageList.imageList = images;
    return imageList;
}

@end
