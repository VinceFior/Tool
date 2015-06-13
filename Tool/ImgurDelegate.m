//
//  ImgurDelegate.m
//  Tool
//
//  Created by Vincent Fiorentini on 5/19/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import "ImgurDelegate.h"
#import "CentralTools.h"
#import "FileManager.h"

@implementation ImgurDelegate


+ (id)sharedManager {
    static ImgurDelegate *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // configure the session only the first time the singleton is created
        FileManager *fileManager = [FileManager sharedManager];
        NSString *autobotClientID = fileManager.imgurAPIClientID;
        [IMGSession anonymousSessionWithClientID:autobotClientID withDelegate:self];
    }
    
    return self;
}

- (void)storeAlbumWithID:(NSString *)albumID toFilePath:(NSString *)filePath {
    [IMGAlbumRequest albumWithID:albumID success:^(IMGAlbum *album) {
        [CentralTools printMessage:[NSString stringWithFormat:@"Got the album, titled \"%@\".", album.title]];
        
        NSString *urlIdentifier = @"URL: ";
        NSString *keywordsIdentifier = @"Keywords: ";
        NSString *urlVideoSubstring = @"youtube.com";
        
        NSString *returnString = @"";
        for (IMGImage *image in album.images) {
            
            // Determine the URL, image type, and search terms.
            NSString *urlString = [image.url absoluteString];
            NSString *searchTermsString = image.title;
            NSArray* descriptionLines = [image.imageDescription componentsSeparatedByCharactersInSet:
                              [NSCharacterSet newlineCharacterSet]];
            
            // image type (if not superseded by URL)
            NSString *animatedString = @"static";
            if (image.animated) {
                animatedString = @"animated";
            }
            
            for (NSString *line in descriptionLines) {
                
                if ([line containsString:urlIdentifier]) {
                    NSRange urlIdentifierRange = [line rangeOfString:urlIdentifier];
                    urlString = [line substringFromIndex:
                                 urlIdentifierRange.location + urlIdentifierRange.length];
                    
                    if ([[urlString lowercaseString] containsString:urlVideoSubstring]) {
                        animatedString = @"youtube";
                    }
                    
                } else if ([line containsString:keywordsIdentifier]) {
                    
                    NSRange keywordsIdentifierRange = [line rangeOfString:keywordsIdentifier];
                    NSString *keywordsString = [line substringFromIndex:
                                                keywordsIdentifierRange.location + keywordsIdentifierRange.length];
                    
                    searchTermsString = [searchTermsString stringByAppendingString:
                                         [NSString stringWithFormat:@" %@", keywordsString]];
                }
                
            }
            
            NSString *imageString = [NSString stringWithFormat:@"%@,%@,%@\n",
                                     urlString,
                                     animatedString,
                                     searchTermsString];
            returnString = [returnString stringByAppendingString:imageString];
        }
        
        [returnString writeToFile:filePath atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
        [CentralTools printMessage:[NSString stringWithFormat:@"Saved album as \"%@\".", filePath]];
        
        // refresh the file manager's image list
        FileManager *fileManager = [FileManager sharedManager];
        [fileManager updateImageList];
        
    } failure:^(NSError *error) {
        NSLog(@"Failed to store album with ID \"%@\". Error: %@", albumID, error);
    }];
}

@end
