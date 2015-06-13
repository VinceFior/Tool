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
#import "ImgurDelegate.h"
#import "AppDelegate.h"

@implementation CentralTools

+ (void)clearPrintedMessages {
    AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
    [appDelegate.outputTextView setString:@""];
}

+ (void)logMessage:(NSString *)text {
    [CentralTools printMessage:text withImportance:NO];
}

+ (void)printMessage:(NSString *)text {
    [CentralTools printMessage:text withImportance:YES];
}

+ (void)printMessage:(NSString *)text withImportance:(BOOL)important {
    NSLog(text);
    if (important) {
        AppDelegate *appDelegate = [[NSApplication sharedApplication] delegate];
        NSString *newText;
        if ([appDelegate.outputTextView.string length] == 0) {
            newText = text;
        } else {
            newText = [NSString stringWithFormat:@"%@\n%@", text, appDelegate.outputTextView.string];
        }
        [appDelegate.outputTextView setString:newText];
    }
    
}

+ (void)copyToClipboard:(NSString *)text {
    [CentralTools printMessage:[NSString stringWithFormat:@"Copied to clipboard \"%@\".", text]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text forType:NSStringPboardType];
}

+ (void)printHelpMessage {
    NSMutableString *helpMessage = [NSMutableString stringWithFormat:@"Commands:" ];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"settings\" or \"config\" to open settings folder"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"gif <keyword>\" to copy the URL of a reaction image, like \"gif nope\""]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"list gif\" to list all reaction images"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"getalbum <album ID>\" to generate a list of reaction images for the given album"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"updatealbum\" to update the image-database.txt file"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"dict <word>\" to open Dictionary.com to the given word"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"xkcd <keyword>\" to open the first xkcd.com result for the given keyword"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"ytmusic <keyword>\" to open the first matching video on my YouTube \'Music\' playlist"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"youtube <keyword>\" to search YouTube for the given keyword"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"music <keyword>\" to search my Google Play Music library for the given keyword"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"google <keyword>\" to search Google for the given keyword"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"school <class>\" to open the folder for my given class in Finder"]];
    [helpMessage appendString:[NSString stringWithFormat:@"\n\"syl <class>\" to open the syllabus for my given class in Finder"]];
    [CentralTools printMessage:helpMessage];
}

+ (CommandReturn)runCommand:(NSString *)command withKeyword:(NSString *)keyword {
    
    [CentralTools clearPrintedMessages];
    
    if ([command isEqualToString:@"help"]) {
        
        [CentralTools printHelpMessage];
        return CommandReturnNothing;
        
    } else if ([command isEqualToString:@"settings"] || [command isEqualToString:@"config"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        [[NSWorkspace sharedWorkspace] selectFile:fileManager.rootDirectory inFileViewerRootedAtPath:@""];
        return CommandReturnClose;
    
    } else if ([command isEqualToString:@"gif"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        ReactionImageList *imageList = fileManager.imageList;
        ReactionImage *bestImage = [imageList getBestImageFromKeyword:keyword];
        if (bestImage != NULL) {
            [CentralTools printMessage:[NSString stringWithFormat:@"Found image entitled \"%@\". Copying its URL to clipboard..", bestImage.title]];
            [CentralTools copyToClipboard:bestImage.url];
            return CommandReturnCloseReopen;
        } else {
            [CentralTools printMessage:@"Could not find image."];
            return CommandReturnNothing;
        }
        
    } else if ([command isEqualToString:@"list"]) {
        
        if ([keyword isEqualToString:@"gif"]) {
            FileManager *fileManager = [FileManager sharedManager];
            ReactionImageList *imageList = fileManager.imageList;
            [CentralTools printMessage:[imageList getImageListInfo]];
        } else {
            [CentralTools printMessage:[NSString stringWithFormat:@"I don\'t know how to list \"%@\".", keyword]];
        }
        return CommandReturnNothing;
        
    } else if ([command isEqualToString:@"getalbum"]) {
        
        [CentralTools printMessage:[NSString stringWithFormat:@"Getting album with ID %@..", keyword]];

        NSArray *paths = NSSearchPathForDirectoriesInDomains (NSDesktopDirectory, NSUserDomainMask, YES);
        NSString *desktopDirectory = [paths objectAtIndex:0];
        NSString *filenamePath = [NSString stringWithFormat:@"%@/%@", desktopDirectory, @"image-database.txt"];

        ImgurDelegate *imgurDelegate = [ImgurDelegate sharedManager];
        [imgurDelegate storeAlbumWithID:keyword toFilePath:filenamePath];
        return CommandReturnNothing;
        
    } else if ([command isEqualToString:@"updatealbum"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        NSString *imgurAlbumID = fileManager.imgurAlbumID;
        [CentralTools printMessage:[NSString stringWithFormat:@"Updating album (with ID %@)..", imgurAlbumID]];
        
        ImgurDelegate *imgurDelegate = [ImgurDelegate sharedManager];
        [imgurDelegate storeAlbumWithID:imgurAlbumID toFilePath:fileManager.imageFilePath];
        return CommandReturnNothing;
    
    } else if ([command isEqualToString:@"dict"]) {
        
        // Open the Dictionary.com page with the keyword
        [CentralTools openUrlWithString:[NSString stringWithFormat:@"http://dictionary.reference.com/browse/%@", keyword]];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"xkcd"]) {
        
        // Google the keyword under "site:xkcd.com" with 'I'm feeling lucky' (first result)
        [CentralTools openUrlWithString:[NSString stringWithFormat:@"http://www.google.com/webhp?gws_rd=ssl#q=%@+site:xkcd.com&btnI=I", keyword]];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"ytmusic"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        NSString *apiKey = fileManager.youTubeAPIKey;
        NSString *playlistID = fileManager.youTubeMusicPlaylistID;
        [CentralTools printMessage:[NSString stringWithFormat:@"Searching YouTube playlist for \"%@\".", keyword]];
        [CentralTools getYoutubeMusicVideoForPlaylist:playlistID withKeyword:keyword withAPIKey:apiKey
                                        withPageToken:nil shouldOpen:YES];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"youtube"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://www.youtube.com/results?search_query=%@", keyword];
        [CentralTools openUrlWithString:searchURL];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"music"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://play.google.com/music/listen?u=0#/sr/%@", keyword];
        [CentralTools openUrlWithString:searchURL];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"google"]) {
        
        NSString *searchURL = [NSString stringWithFormat:@"https://www.google.com/search?q=%@", keyword];
        [CentralTools openUrlWithString:searchURL];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"school"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        NSString *schoolPath = fileManager.schoolRoot;
        if ([keyword length] > 0) {
            BOOL hasAddedPath = NO;
            for (NSDictionary *classDict in fileManager.schoolClasses) {
                if (hasAddedPath) {
                    break;
                }
                for (NSString *classKeyword in classDict[@"keywords"]) {
                    if ([[classKeyword lowercaseString] containsString:[keyword lowercaseString]]
                        || [[keyword lowercaseString] containsString:[classKeyword lowercaseString]]) {
                        NSString *extraPath = classDict[@"path"];
                        schoolPath = [schoolPath stringByAppendingString:[NSString stringWithFormat:@"/%@",
                                                                          extraPath]];
                        break;
                    }
                }
            }
        }
        [[NSWorkspace sharedWorkspace] selectFile:schoolPath inFileViewerRootedAtPath:@""];
        return CommandReturnClose;
        
    } else if ([command isEqualToString:@"syl"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        if ([keyword length] > 0) {
            for (NSDictionary *classDict in fileManager.schoolClasses) {
                for (NSString *classKeyword in classDict[@"keywords"]) {
                    if ([[classKeyword lowercaseString] containsString:[keyword lowercaseString]]
                        || [[keyword lowercaseString] containsString:[classKeyword lowercaseString]]) {
                        NSString *schoolPath = fileManager.schoolRoot;
                        NSString *classExtraPath = classDict[@"path"];
                        NSString *syllabusExtraPath = classDict[@"syllabus"];
                        if (syllabusExtraPath == nil) {
                            // if the syllabus isn't specified, just show the folder
                            syllabusExtraPath = @"";
                        }
                        NSString *syllabusFullPath = [NSString stringWithFormat:@"%@/%@/%@", schoolPath, classExtraPath, syllabusExtraPath];
                        
                        BOOL openedFile = [[NSWorkspace sharedWorkspace] openFile:syllabusFullPath];
                        if (openedFile) {
                            return CommandReturnClose;
                        } else {
                            [CentralTools printMessage:
                             [NSString stringWithFormat:@"Could not open syllabus of path: %@", syllabusFullPath]];
                            return CommandReturnNothing;
                        }
                        
                    }
                }
            }
        }
        return CommandReturnNothing;
    
    } else {
        [CentralTools printMessage:[NSString stringWithFormat:@"Could not find command \"%@\", which was given with keyword \"%@\".",
                            command, keyword]];
        return CommandReturnNothing;
    }
}

/*
 * Searches the titles of the videos in the given playlist for the given keyword, using apiKey.
 * The pageToken is used to determine the offset of results.
 * Only actually opens the video if shouldOpen is true.
 */
+ (void)getYoutubeMusicVideoForPlaylist:(NSString *)playlistID withKeyword:(NSString *)keyword
                             withAPIKey:(NSString *)apiKey withPageToken:(NSString *)pageToken
                             shouldOpen:(BOOL)shouldOpen {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    int maxResults = 50; // max allowed by YouTube API v3
    NSString *playlistRequestURLString;
    if (pageToken == nil || [pageToken length] == 0) {
        playlistRequestURLString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%i&playlistId=%@&key=%@", maxResults, playlistID, apiKey];
    } else {
        playlistRequestURLString = [NSString stringWithFormat:@"https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=%i&playlistId=%@&pageToken=%@&key=%@", maxResults, playlistID, pageToken, apiKey];
    }
    [manager GET:playlistRequestURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        id payload = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:nil];
        NSString *keywordLower = [keyword lowercaseString];
        NSDictionary *playlistInfo = payload;
        NSArray *items = playlistInfo[@"items"];
        BOOL hasOpened = NO;
        for (NSDictionary *item in items) {
            NSDictionary *snippet = item[@"snippet"];
            NSString *title = snippet[@"title"];
            NSString *titleLower = [title lowercaseString];
            if ([titleLower containsString:keywordLower]) {
                if (!hasOpened && shouldOpen) {
                    hasOpened = YES;
                    NSDictionary *resourceID = snippet[@"resourceId"];
                    NSString *videoID = resourceID[@"videoId"];
                    NSString *videoURLString = [NSString stringWithFormat:@"https://www.youtube.com/watch?list=%@&v=%@",
                                                playlistID, videoID];
                    [CentralTools openUrlWithString:videoURLString];
                    [CentralTools printMessage:[NSString stringWithFormat:@"Opening video \"%@\".", title]];
                } else {
                    [CentralTools printMessage:[NSString stringWithFormat:@"Also found video \"%@\".", title]];
                }
            }
        }
        
        NSString *nextPageToken = playlistInfo[@"nextPageToken"];
        if (nextPageToken) {
            // we have more results
            [CentralTools getYoutubeMusicVideoForPlaylist:playlistID withKeyword:keyword withAPIKey:apiKey withPageToken:nextPageToken shouldOpen:!hasOpened];
        } else if (!hasOpened && shouldOpen) {
            // we can't find the song in this playlist
            NSString *failureMessage = [NSString stringWithFormat:@"Could not find video with keyword \"%@\" in playlist with ID \"%@\".",
                                        keyword, playlistID];
            [CentralTools printMessage:failureMessage];
            // fall back by searching for the keyword on YouTube
            [CentralTools printMessage:[NSString stringWithFormat:@"Falling back by searching YouTube for \"%@\".", keyword]];
            NSString *searchURL = [NSString stringWithFormat:@"https://www.youtube.com/results?search_query=%@", keyword];
            [CentralTools openUrlWithString:searchURL];
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)openUrlWithString:(NSString *)urlString {
    // replace spaces with '+'
    urlString = [urlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[NSWorkspace sharedWorkspace] openURL:url]) {
        [CentralTools printMessage:[NSString stringWithFormat:@"Failed to open URL \"%@\".", [url description]]];
    }
}

@end
