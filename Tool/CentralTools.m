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

+ (BOOL)runCommand:(NSString *)command withKeyword:(NSString *)keyword {
    if ([command isEqualToString:@"gif"]) {
        
        FileManager *fileManager = [FileManager sharedManager];
        ReactionImageList *imageList = fileManager.imageList;
        ReactionImage *bestImage = [imageList getBestImageFromKeyword:keyword];
        if (bestImage != NULL) {
            [CentralTools printMessage:[NSString stringWithFormat:@"Found image entitled \"%@\". Copying its URL to clipboard..", bestImage.title]];
            [CentralTools copyToClipboard:bestImage.url];
            return YES;
        } else {
            NSLog(@"Could not find image.");
        }
        
    } else if ([command isEqualToString:@"list"]) {
        
        if ([keyword isEqualToString:@"gif"]) {
            FileManager *fileManager = [FileManager sharedManager];
            ReactionImageList *imageList = fileManager.imageList;
            [CentralTools printMessage:[imageList getImageListInfo]];
        } else {
            [CentralTools printMessage:[NSString stringWithFormat:@"I don\'t know how to list \"%@\".", keyword]];
        }
        
    } else if ([command isEqualToString:@"getalbum"]) {
        
        ImgurDelegate *imgurDelegate = [ImgurDelegate sharedManager];
        [imgurDelegate storeAlbumWithID:keyword];
        [CentralTools printMessage:[NSString stringWithFormat:@"Getting album with ID %@..", keyword]];
        
    } else if ([command isEqualToString:@"dict"]) {
        
        // Open the Dictionary.com page with the keyword
        [CentralTools openUrlWithString:[NSString stringWithFormat:@"http://dictionary.reference.com/browse/%@", keyword]];
        
    } else if ([command isEqualToString:@"xkcd"]) {
        
        // Google the keyword under "site:xkcd.com" with 'I'm feeling lucky' (first result)
        [CentralTools openUrlWithString:[NSString stringWithFormat:@"http://www.google.com/webhp?#q=%@+site:xkcd.com&btnI=I", keyword]];
        
    } else if ([command isEqualToString:@"music"]) {
        
        NSString *playlistID = @"PL2RjSZTkAtlM1UiG59LRGWtD2s6IDOEXS"; // Vincent's music playlist
        [CentralTools getYoutubeMusicVideoForPlaylist:playlistID atIndex:1 withKeyword:keyword];
        
    } else {
        [CentralTools printMessage:[NSString stringWithFormat:@"Could not find command \"%@\", which was given with keyword \"%@\".",
                            command, keyword]];
    }
    return NO;
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
    NSURL *url = [NSURL URLWithString:urlString];
    if (![[NSWorkspace sharedWorkspace] openURL:url]) {
        [CentralTools printMessage:[NSString stringWithFormat:@"Failed to open URL \"%@\".", [url description]]];
    }
}

@end
