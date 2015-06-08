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
        
        1; // TODO: let the user set the root directory
        NSString *rootDirectory = @"/Users/vincent/Documents/tool/config";
        
        2; // TODO: check if files exist (to avoid crashing)
        NSString *imageFilePath = [rootDirectory stringByAppendingString:@"/image-database.txt"];
        self.imageList = [self getImageList:imageFilePath];

        NSString *schoolFilePath = [rootDirectory stringByAppendingString:@"/school-folders.txt"];
        [self setSchoolProperties:schoolFilePath];

        NSString *personalSettingsFilePath = [rootDirectory stringByAppendingString:@"/personal-settings.txt"];
        [self setPersonalSettings:personalSettingsFilePath];
        
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
        ReactionImageType reactionImageType = ReactionImageTypeOther;
        if ([imageType isEqualToString:@"static"]) {
            reactionImageType = ReactionImageTypeStatic;
        } else if ([imageType isEqualToString:@"animated"]) {
            reactionImageType = ReactionImageTypeAnimated;
        } else if ([imageType isEqualToString:@"youtube"]) {
            reactionImageType = ReactionImageTypeYouTube;
        }
        NSString *title = data[2];
        ReactionImage *reactionImage = [[ReactionImage alloc] init];
        reactionImage.url = url;
        reactionImage.title = title;
        reactionImage.imageType = reactionImageType;
        [images addObject:reactionImage];
    }
    
    ReactionImageList *imageList = [[ReactionImageList alloc] init];
    imageList.imageList = images;
    return imageList;
}

// Set the properties related to school files.
- (void) setSchoolProperties:(NSString *)schoolFilePath {
    NSData* fileContents = [NSData dataWithContentsOfFile:schoolFilePath];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:fileContents options:0 error:&error];
    if (error) {
        NSLog(@"Error reading school file: %@", error);
        return;
    }
    self.schoolRoot = object[@"default"];
    NSDictionary *classesDict = object[@"classes"];
    self.schoolClasses = classesDict;
}

// Sets the properties related to personal settings (per se, not more specific files).
- (void) setPersonalSettings:(NSString *)personalSettingsFilePath {
    NSData* fileContents = [NSData dataWithContentsOfFile:personalSettingsFilePath];
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:fileContents options:0 error:&error];
    if (error) {
        NSLog(@"Error reading personal settings file: %@", error);
        return;
    }
    self.youTubeAPIKey = object[@"youtube-api-key"];
    self.youTubeMusicPlaylistID = object[@"youtube-music-playlist-id"];
    self.imgurAPIClientID = object[@"imgur-api-client-id"];
    self.imgurAlbumID = object[@"imgur-album-id"];
}

@end
