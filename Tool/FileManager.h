//
//  FileManager.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/16/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ReactionImageList;

@interface FileManager : NSObject

@property (strong, nonatomic) ReactionImageList *imageList;
@property (strong, nonatomic) NSString *schoolRoot;
@property (strong, nonatomic) NSDictionary *schoolClasses;
@property (strong, nonatomic) NSString *youTubeAPIKey;
@property (strong, nonatomic) NSString *youTubeMusicPlaylistID;
@property (strong, nonatomic) NSString *imgurAPIClientID;
@property (strong, nonatomic) NSString *imgurAlbumID;

+ (id)sharedManager;

@end
