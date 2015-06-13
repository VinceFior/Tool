//
//  ImgurDelegate.h
//  Tool
//
//  Created by Vincent Fiorentini on 5/19/15.
//  Copyright (c) 2015 Vincent Fiorentini. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ImgurSession.h"

@interface ImgurDelegate : NSObject <IMGSessionDelegate>

@property (copy) void(^continueHandler)();

+ (id)sharedManager;
- (void)storeAlbumWithID:(NSString *)albumID toFilePath:(NSString *)fileName;

@end
