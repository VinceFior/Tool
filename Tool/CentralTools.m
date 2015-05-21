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

@implementation CentralTools

+ (void)printMessage:(NSString *)text {
    NSLog(text);
}

+ (void)copyToClipboard:(NSString *)text {
    [CentralTools printMessage:[NSString stringWithFormat:@"Copied to clipboard \"%@\".", text]];
    [[NSPasteboard generalPasteboard] clearContents];
    [[NSPasteboard generalPasteboard] setString:text forType:NSStringPboardType];
}

+ (void)printHelpMessage {
    NSMutableString *helpMessage = [NSMutableString stringWithFormat:@"Commands:" ];
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
    
    if ([command isEqualToString:@"help"]) {
        
        [CentralTools printHelpMessage];
        return CommandReturnNothing;
        
    } else if ([command isEqualToString:@"gif"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        ReactionImageList *imageList = fileManager.imageList;
        ReactionImage *bestImage = [imageList getBestImageFromKeyword:keyword];
        if (bestImage != NULL) {
            [CentralTools printMessage:[NSString stringWithFormat:@"Found image entitled \"%@\". Copying its URL to clipboard..", bestImage.title]];
            [CentralTools copyToClipboard:bestImage.url];
            return CommandReturnCloseReopen;
        } else {
            NSLog(@"Could not find image.");
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
        ImgurDelegate *imgurDelegate = [ImgurDelegate sharedManager];
        [imgurDelegate storeAlbumWithID:keyword asFilename:@"image-database-new.txt"];
        return CommandReturnNothing;
        
    } else if ([command isEqualToString:@"updatealbum"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        NSString *imgurAlbumID = fileManager.imgurAlbumID;
        
        [CentralTools printMessage:[NSString stringWithFormat:@"Updating album (with ID %@)..", imgurAlbumID]];
        ImgurDelegate *imgurDelegate = [ImgurDelegate sharedManager];
        [imgurDelegate storeAlbumWithID:imgurAlbumID asFilename:@"image-database.txt"];
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
        NSString *playlistID = fileManager.youTubeMusicPlaylistID;
        [CentralTools printMessage:[NSString stringWithFormat:@"Searching YouTube playlist for \"%@\".", keyword]];
        [CentralTools getYoutubeMusicVideoForPlaylist:playlistID atIndex:1 withKeyword:keyword];
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

+ (void)getYoutubeMusicVideoForPlaylist:(NSString *)playlistID atIndex:(int)startIndex withKeyword:(NSString *)keyword {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    //manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"application/atom+xml"];
    
    const int maxStartIndex = 1000;
    if (startIndex > maxStartIndex) {
        // this case should not happen
        NSString *failureMessage = [NSString stringWithFormat:@"Definitely could not find video with keyword \"%@\" in playlist with ID \"%@\".",
                                    keyword, playlistID];
        [CentralTools printMessage:failureMessage];
        return;
    }
    
    int maxResults = 25;
    NSString *playlistRequestURLString = [NSString stringWithFormat:@"http://gdata.youtube.com/feeds/api/playlists/%@?start-index=%i&amp;max-results=%i", playlistID, startIndex, maxResults];
    [manager GET:playlistRequestURLString parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSData * data = (NSData *)responseObject;
        
        NSString *fetchedXML = [NSString stringWithCString:[data bytes] encoding:NSISOLatin1StringEncoding];
        
        NSString *lowercaseFetchedXML = [fetchedXML lowercaseString];
        NSString *lowercaseKeyword = [keyword lowercaseString];
        
        if ([lowercaseFetchedXML containsString:lowercaseKeyword]) {
            // naively assume that the next URL of the right format is the one we want
            NSRange keywordRange = [lowercaseFetchedXML rangeOfString:lowercaseKeyword];
            NSString *afterKeywordString = [fetchedXML substringFromIndex:keywordRange.location + keywordRange.length];
            
            NSString *videoBaseString = @"<link rel='related' type='application/atom+xml' href='http://gdata.youtube.com/feeds/api/videos/";
            NSRange watchURLRange = [afterKeywordString rangeOfString:videoBaseString];
            NSString *afterWatchURLString = [afterKeywordString substringFromIndex:watchURLRange.location + watchURLRange.length];
            
            NSString *videoBaseEndString = @"\'/>";
            NSRange videoIDRange = [afterWatchURLString rangeOfString:videoBaseEndString];
            NSString *videoID = [afterWatchURLString substringToIndex:videoIDRange.location];
            
            NSString *videoURLString = [NSString stringWithFormat:@"https://www.youtube.com/watch?v=%@", videoID];
            videoURLString = [videoURLString stringByAppendingString:[NSString stringWithFormat:@"&list=%@", playlistID]];
            
            [CentralTools openUrlWithString:videoURLString];
            [CentralTools printMessage:[NSString stringWithFormat:@"Found video with keyword \"%@\".", keyword]];
        } else {
            // since we only get one page of results, try the next page
            
            // see if the next search would be over the "totalResults" of the playlist
            NSRange totalResultsStartRange = [fetchedXML rangeOfString:@"<openSearch:totalResults>"];
            NSString *afterTotalResultsString = [fetchedXML substringFromIndex:totalResultsStartRange.location + totalResultsStartRange.length];
            NSString *totalResultsEndString = @"</openSearch:totalResults>";
            NSRange totalResultsEndRange = [afterTotalResultsString rangeOfString:totalResultsEndString];
            NSString *totalResultsString = [afterTotalResultsString substringToIndex:totalResultsEndRange.location];
            
            int totalResults = [totalResultsString intValue];
            if (startIndex + maxResults <= totalResults) {
                [CentralTools getYoutubeMusicVideoForPlaylist:playlistID atIndex:startIndex + maxResults withKeyword:keyword];
            } else {
                NSString *failureMessage = [NSString stringWithFormat:@"Could not find video with keyword \"%@\" in playlist with ID \"%@\".",
                                            keyword, playlistID];
                [CentralTools printMessage:failureMessage];
                
                // fall back on searching for the keyword (with "song") on YouTube
                [CentralTools printMessage:[NSString stringWithFormat:@"Falling back by searching YouTube for \"%@\".", keyword]];
                NSString *searchURL = [NSString stringWithFormat:@"https://www.youtube.com/results?search_query=%@", keyword];
                [CentralTools openUrlWithString:searchURL];
            }
            
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

+ (void)saveStringToDesktop:(NSString *)contentString asFile:(NSString *)fileNameString {
    // get the desktop directory:
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *desktopDirectory = [paths objectAtIndex:0];
    
    // make a file name to write the data to using the desktop directory:
    NSString *fileNamePath = [NSString stringWithFormat:@"%@/%@",
                          desktopDirectory, fileNameString];
    
    //save content to the documents directory
    [contentString writeToFile:fileNamePath atomically:NO
                      encoding:NSStringEncodingConversionAllowLossy error:nil];
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
