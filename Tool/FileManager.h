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

+ (id)sharedManager;

@end
