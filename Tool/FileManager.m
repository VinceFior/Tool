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
#import "CentralTools.h"

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
        
        NSString *rootDirectory = [@"~/Library/Application Support/Tool" stringByExpandingTildeInPath];
        self.rootDirectory = rootDirectory;
        BOOL isRootDirectoryDir = NO;
        if (![[NSFileManager defaultManager] fileExistsAtPath:rootDirectory isDirectory:&isRootDirectoryDir]) {
            [CentralTools printMessage:[NSString
                                        stringWithFormat:@"Root directory does not exist, creating it now at %@",
                                        rootDirectory]];
            BOOL createdRoot = [[NSFileManager defaultManager] createDirectoryAtPath:rootDirectory
                                                         withIntermediateDirectories:YES attributes:nil
                                                                               error:nil];
            if (!createdRoot) {
                [CentralTools printMessage:@"Failed to create root directory."];
            }
        }
        
        NSString *imageFilePath = [rootDirectory stringByAppendingString:@"/image-database.txt"];
        self.imageFilePath = imageFilePath;
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
    // Todo: Use JSON instead of a CSV.
    if (![[NSFileManager defaultManager] fileExistsAtPath:imageFileRoot]) {
        [CentralTools printMessage:@"Could not find image list file. Creating placeholder now."];
        NSString *placeholderFileContents = @"http://i.imgur.com/TUJKTDF.jpg,static,I can has cheezburger haz cheeseburger";
        [placeholderFileContents writeToFile:imageFileRoot atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
    
    NSString* fileContents = [NSString stringWithContentsOfFile:imageFileRoot
                                                       encoding:NSUTF8StringEncoding error:nil];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:schoolFilePath]) {
        [CentralTools printMessage:@"Could not find school file. Creating placeholder now."];
        NSString *documentsPath = [@"~/Documents" stringByExpandingTildeInPath];
        NSString *placeholderFileContents = [NSString stringWithFormat:@"{\"default\": \"%@\",\n\"classes\": [\n{\"path\": \"FOLDERNAMEHERE\", \"keywords\": [\"KEYWORD1\", \"KEYWORD2\"], \"syllabus\": \"PDFPATHHERE\"}\n]\n}", documentsPath];
        [placeholderFileContents writeToFile:schoolFilePath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
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
    if (![[NSFileManager defaultManager] fileExistsAtPath:personalSettingsFilePath]) {
        [CentralTools printMessage:@"Could not find personal settings file. Creating placeholder now."];
        
        NSString *placeholderFileContents = @"{\n\"youtube-api-key\": \"KEYHERE\",\n\"youtube-music-playlist-id\": \"PLAYLISTIDHERE\",\n\"imgur-api-client-id\": \"IMGURAPICLIENTIDHERE\",\n\"imgur-album-id\": \"ALBUMIDHERE\"\n}";
        [placeholderFileContents writeToFile:personalSettingsFilePath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    }
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

- (void) updateImageList {
    self.imageList = [self getImageList:self.imageFilePath];
}

@end
